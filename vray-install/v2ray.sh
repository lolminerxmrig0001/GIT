#!/usr/bin/env bash

# Colors
Color_Off='\033[0m'
Black='\033[0;30m' 
Red='\033[0;31m'   
Green='\033[0;32m' 
Yellow='\033[0;33m'
Blue='\033[0;34m'  
Purple='\033[0;35m'
Cyan='\033[0;36m'  
White='\033[0;37m' 

# Variables 
vray_conf_dir="/etc/v2ray"
vray_docker_compose_file="/root/docker-compose.yaml"
config_path="/etc/v2ray/config.json"
users_count_file="/etc/v2ray/users_count.txt"
users_number_in_config_file="/etc/v2ray/users_number_in_config.txt"
users_expiry_date_file="/etc/v2ray/users_expiry_date.txt"
proto_file="/etc/v2ray/proto.txt"
backup_dir="/root/vray_backup"
website_dir="/var/www/html" 
cert_group="nobody"
random_num=$((RANDOM % 12 + 4))
nginx_conf="/etc/nginx/sites-available/default"
go_version="1.19.3"

WS_PATH="/$(head -n 10 /dev/urandom | md5sum | head -c ${random_num})"
PASSWORD="$(head -n 10 /dev/urandom | md5sum | head -c 18)"

OK="${Green}[OK]"
ERROR="${Red}[ERROR]"
INFO="${Yellow}[INFO]"

SLEEP="sleep 0.2"

#print OK
function print_ok() {
    echo -e "${OK} $1 ${Color_Off}"
}

#print ERROR
function print_error() {
    echo -e "${ERROR} $1 ${Color_Off}"
}

#print INFO
function print_info() {
    echo -e "${INFO} $1 ${Color_Off}"
}

function installit() {
    apt install -y $*
}

# Check exit code of prev command
function judge() {
    if [[ 0 -eq $? ]]; then
        print_ok "$1 Finished"
        $SLEEP
    else
        print_error "$1 Failed"
        exit 1
    fi
}

# Check the shell
function check_bash() {
    is_BASH=$(readlink /proc/$$/exe | grep -q "bash")
    if [[ $is_BASH -ne "bash" ]]; then
        print_error "This installer needs to be run with bash, not sh."
        exit
    fi
}

# Check root
function check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        print_error "This installer needs to be run with superuser privileges. Login as root user and run the script again!"
        exit
    else 
        print_ok "Root user checked!" ; $SLEEP
    fi
}

# Check OS
function check_os() {
    if grep -qs "ubuntu" /etc/os-release; then
        os="ubuntu"
        os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
        print_ok "Ubuntu detected!"
    elif [[ -e /etc/debian_version ]]; then
        os="debian"
        os_version=$(cat /etc/debian_version | cut -d '.' -f 1)
        print_ok "Debian detected!"
    else
        print_error "This installer seems to be running on an unsupported distribution.
        Supported distros are ${Yellow}Debian${Color_Off} and ${Yellow}Ubuntu${Color_Off}."
        exit
    fi
    if [[ "$os" == "ubuntu" && "$os_version" -lt 2004 ]]; then
        print_error "${Yellow}Ubuntu 20.04${Color_Off} or higher is required to use this installer.
        This version of Ubuntu is too old and unsupported."
        exit
    elif [[ "$os" == "debian" && "$os_version" -lt 10 ]]; then
        print_error "${Yellow}Debian 11${Color_Off} or higher is required to use this installer.
        This version of fedora is too old and unsupported."
        exit
    fi
}

function disable_firewalls() {
    is_firewalld=$(systemctl list-units --type=service --state=active | grep -c firewalld)
    is_nftables=$(systemctl list-units --type=service --state=active | grep -c nftables)
    is_ufw=$(systemctl list-units --type=service --state=active | grep -c ufw)

    if [[ "$is_nftables" -ne 0 ]]; then
        systemctl stop nftables
        systemctl disable nftables
    fi 

    if [[ "$is_ufw" -ne 0 ]]; then
        systemctl stop ufw
        systemctl disable ufw
    fi

    if [[ "$is_firewalld" -ne 0 ]]; then
        systemctl stop firewalld
        systemctl disable firewalld
    fi
}

function install_nginx() {
    installit nginx
}

function install_deps() {
    installit lsof tar
    judge "Install lsof tar"

    installit unzip
    judge "install unzip"

    installit curl
    judge "install curl"

    installit libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
    judge "install libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev"

    installit qrencode
    judge "install qrencode"

    installit jq
    judge "install jq"

    mkdir /usr/local/bin >/dev/null 2>&1
}

function basic_optimization() {
    sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
    sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
    echo '* soft nofile 65536' >>/etc/security/limits.conf
    echo '* hard nofile 65536' >>/etc/security/limits.conf
}

function ip_check() {
    local_ipv4=$(curl -s4m8 https://icanhazip.com)
    local_ipv6=$(curl -s6m8 https://icanhazip.com)
    if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
        print_ok "Pure IPv6 server"
        SERVER_IP=$(curl -s6m8 https://icanhazip.com)
    else
        print_ok "Server hase IPv4"
        SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    fi
}

function cloudflare_dns() {
    ip_check
    if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
        echo "nameserver 2606:4700:4700::1111" > /etc/resolv.conf
        echo "nameserver 2606:4700:4700::1001" >> /etc/resolv.conf
        judge "add IPv6 DNS to resolv.conf"
    else
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "nameserver 1.0.0.1" >> /etc/resolv.conf
        judge "add IPv4 DNS to resolv.conf"
    fi
}

function domain_check() {
    read -rp "Please enter your domain name information (example: www.google.com):" domain
    echo -e "${domain}" >/usr/local/domain.txt
    #domain_ip=$(curl -sm8 ipget.net/?ip="${domain}")
    domain_ip=$(ping -c 1 ${domain} | grep -m 1 -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}')
    print_ok "Getting domain IP address information, please be wait..."
    #wgcfv4_status=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    #wgcfv6_status=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    #if [[ ${wgcfv4_status} =~ "on"|"plus" ]] || [[ ${wgcfv6_status} =~ "on"|"plus" ]]; then
    #  # Turn off wgcf-warp to prevent misjudgment of VPS IP situation
    #  wg-quick down wgcf >/dev/null 2>&1
    #  print_ok "wgcf-warp closed"
    #fi
    local_ipv4=$(curl -s4m8 https://icanhazip.com)
    local_ipv6=$(curl -s6m8 https://icanhazip.com)
    if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
        # Pure IPv6 VPS, automatically add DNS64 server for acme.sh to apply for certificate
        echo -e nameserver 2606:4700:4700::1111 > /etc/resolv.conf
        print_ok "Recognized VPS as IPv6 Only, automatically add DNS64 server"
    fi
    echo -e "DNS-resolved IP address of the domain name: ${domain_ip}"
    echo -e "Local public network IPv4 address ${local_ipv4}"
    echo -e "Local public network IPv6 address ${local_ipv6}"
    sleep 2
    if [[ ${domain_ip} == ${local_ipv4} ]]; then
        print_ok "The DNS-resolved IP address of the domain name matches the native IPv4 address"
        sleep 2
    elif [[ ${domain_ip} == ${local_ipv6} ]]; then
        print_ok "The DNS-resolved IP address of the domain name matches the native IPv6 address"
        sleep 2
    else
        print_error "Please make sure that the correct A/AAAA records are added to the domain name, otherwise V2ray will not work properly"
        print_error "The IP address of the domain name resolved through DNS does not match the native IPv4/IPv6 address, 
        do you want to continue the installation? (y/n)" && read -r install
        case $install in
        [yY][eE][sS] | [yY])
          print_ok "Continue Installation"
          sleep 2
          ;;
        *)
          print_error "Installation terminated"
          exit 2
          ;;
        esac
    fi
}

function port_exist_check() {
    if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
        print_ok "$1 Port is not in use"
        sleep 1
    else
        print_error "It is detected that port $1 is occupied, the following is the occupancy information of port $1"
        lsof -i:"$1"
        print_error "After 5s, it will try to kill the occupied process automatically"
        sleep 5
        lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
        print_ok "Kill Finished"
        sleep 1
    fi
}

function vray_tmp_config_file_check_and_use() {
    if [[ -s ${vray_conf_dir}/config_tmp.json ]]; then
        mv -f ${vray_conf_dir}/config_tmp.json ${vray_conf_dir}/config.json
    else
        print_error "can't modify V2ray config file!"
        exit 1
    fi
    touch ${vray_conf_dir}/config_tmp.json
}

function restart_nginx(){
    systemctl enable --now nginx
    judge "nginx start"
    systemctl restart nginx
    judge "Nginx restart"
}

function configure_nginx_reverse_proxy_tls() {
    rm -rf ${nginx_conf} && wget -O ${nginx_conf} https://raw.githubusercontent.com/thehxdev/vray-examples/main/nginx/nginx_reverse_proxy_tls.conf
    judge "Nginx config Download"

    sed -i "s/YOUR_DOMAIN/${domain}/g" ${nginx_conf}
    judge "Nginx config add domain"
}

function add_wsPath_to_nginx() {
    sed -i "s.wsPATH.${WS_PATH}.g" ${nginx_conf}
    judge "Nginx Websocket Path modification"
}

function setup_fake_website() {
    wget https://github.com/arcdetri/sample-blog/archive/master.zip
    unzip master.zip
    cp -rf sample-blog-master/html/* /var/www/html/
}

function send_go_and_gost() {
    read -rp "Domestic relay IP:" domestic_relay_ip
    cd /root/
    wget https://go.dev/dl/go${go_version}.linux-amd64.tar.gz
    judge "Golang Download"
    scp ./go${go_version}.linux-amd64.tar.gz root@${domestic_relay_ip}:/root/
    judge "send Golang to domestic relay"

    wget https://github.com/ginuerzh/gost/releases/download/v2.11.4/gost-linux-amd64-2.11.4.gz
    judge "Gost Download"
    scp ./gost-linux-amd64-2.11.4.gz root@${domestic_relay_ip}:/root/
    judge "send Gost to domestic relay"
}

function install_gost_and_go() {
    if [[ -e "/usr/local/go" ]]; then
        rm -rf /usr/local/go 
        if [[ -e "/root/go${go_version}.linux-amd64.tar.gz" ]]; then
            tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz
            judge "install Golang"
        else
            print_error "Can't find golang archive file"
            exit 1
        fi
    else
        print_ok "Golang Already installed"
    fi

    if [[ ! -e "/usr/local/bin/gost" ]] ;then 
        if [[ -e "gost-linux-amd64-2.11.4.gz" ]]; then
            gunzip gost-linux-amd64-2.11.4.gz
            judge "Gost extract"
            mv gost-linux-amd64-2.11.4 /usr/local/bin/gost
            judge "move Gost"
            chmod +x /usr/local/bin/gost
            judge "Make Gost executable"
        else
            print_error "Can't find golang archive file"
            exit 1
        fi
    else
        print_ok "Gost is installed"
    fi
}

function configure_gost_and_go() {
    install_gost_and_go

    read -rp "Foreign server IP:" foreign_server_ip
    read -rp "Foreign server Port:" foreign_server_port
    read -rp "Listening Port:" listening_port

    cat << EOF > /usr/lib/systemd/system/gost.service
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -L=tcp://:${listening_port}/$foreign_server_ip:${foreign_server_port}

[Install]
WantedBy=multi-user.target

EOF

    judge "adding systemd unit for gost"

    systemctl enable --now gost.service
    judge "gost service start"

    echo -e "${Blue}Listening Port = ${Green}${listening_port}${Color_Off}"
    echo -e "${Blue}Forwarding incoming traffic to ${Green}${foreign_server_ip}:${foreign_server_port}${Color_Off}"
}

function install_docker() {
    if ! command -v curl; then
        installit curl
        judge "Instlal curl"
    else
        print_ok "curl is installed"
    fi

    #curl https://get.docker.com | sh

    installit ca-certificates curl gnupg lsb-release
    judge "install ca-certificates curl gnupg lsb-release"

    if [[ ! -e "/etc/apt/keyrings" ]]; then
        mkdir -p /etc/apt/keyrings
        judge "Make apt keyring directory"
    fi

    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    judge "Add Docker repository"

    apt update
    judge "Update repositories"

    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    judge "install docker"

    installit docker-compose
    judge "Install docker-compose"
}

function vray_install() {
    if [[ ! -e "/root/config.json" ]]; then
        print_error "Can't find /roor/config.json file"
        exit 1
    fi

    install_docker

    tee ${vray_docker_compose_file} <<EOF
version: '3'
services:
  v2ray:
    image: v2fly/v2fly-core
    restart: always
    network_mode: host
    environment:
      - V2RAY_VMESS_AEAD_FORCED=false
    volumes:
        - ./config.json:/etc/v2ray/config.json:ro
EOF

    if [[ -e "${vray_docker_compose_file}" ]]; then
        cd /root/
        docker-compose up -d
        echo -e "${Cyan} Docker Proccesses:${Color_Off}"
        docker ps
    else
        print_error "Can't find v2ray docker-compose file."
        exit 1
    fi
}

function modify_port() {
    read -rp "Please enter the port number (default: 8080): " PORT
    [ -z "$PORT" ] && PORT="8080"
    if [[ $PORT -le 0 ]] || [[ $PORT -gt 65535 ]]; then
        print_error "Port must be in range of 0-65535"
        exit 1
    fi
    port_exist_check $PORT
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"port"];'${PORT}')' >${vray_conf_dir}/config_tmp.json
    vray_tmp_config_file_check_and_use
    judge "V2ray port modification"
}

function modify_UUID() {
    [ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"settings","clients",0,"id"];"'${UUID}'")' >${vray_conf_dir}/config_tmp.json
    judge "modify V2ray UUID"
    vray_tmp_config_file_check_and_use
    judge "change tmp file to main file"
}

function modify_ws() {
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"streamSettings","wsSettings","path"];"'${WS_PATH}'")' >${vray_conf_dir}/config_tmp.json
    judge "modify V2ray ws"
    vray_tmp_config_file_check_and_use
    judge "change tmp file to main file"
}

function modify_tls() {
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"streamSettings","tlsSettings","certificates",0,"certificateFile"];"'${certFile}'")' >${vray_conf_dir}/config_tmp.json
    judge "modify V2ray TLS Cert File"
    vray_tmp_config_file_check_and_use
    judge "change tmp file to main file"
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"streamSettings","tlsSettings","certificates",0,"keyFile"];"'${keyFile}'")' >${vray_conf_dir}/config_tmp.json
    judge "modify V2ray TLS Key File"
    vray_tmp_config_file_check_and_use
    judge "change tmp file to main file"
}

function modify_PASSWORD() {
    cat ${vray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"settings","clients",0,"password"];"'${PASSWORD}'")' >${vray_conf_dir}/config_tmp.json
    judge "modify V2ray Trojan Password"
    vray_tmp_config_file_check_and_use
    judge "change tmp file to main file"
}

function configure_certbot() {
    mkdir /ssl >/dev/null 2>&1
    installit certbot python3-certbot
    judge "certbot python3-certbot Installation"
    certbot certonly --standalone --preferred-challenges http --register-unsafely-without-email -d $domain
    judge "certbot ssl certification"

    cp /etc/letsencrypt/archive/$domain/fullchain1.pem /ssl/vray.crt
    judge "copy cert file"
    cp /etc/letsencrypt/archive/$domain/privkey1.pem /ssl/vray.key
    judge "copy key file"

    #chown -R nobody.$cert_group /ssl/*
    certFile="/ssl/vray.crt"
    keyFile="/ssl/vray.key"
}

function renew_certbot() {
    certbot renew --dry-run
    judge "SSL renew"
}

function vray_uninstall() {
    print_info "This option will remove V2ray!"
    read -n1 -r -p "Press any key to continue Or press Ctrl+C to exit..."
    print_info "Do you want to Disable V2ray (This will keep docker and disables v2ray contaner)? [y/n]"
    read -r disable_vray
    case $disable_vray in
    [yY][eE][sS] | [yY])
        cd /root/
        docker-compose down -v
        rm -rf $website_dir/*
        ;;
    *) ;;
    esac

    print_info "Do you want to uninstall and purge docker? [y/n]"
    read -r uninstall_docker
    case $uninstall_docker in
    [yY][eE][sS] | [yY])
        cd /root/
        rm -rf ${vray_docker_compose_file}
        judge "Remove v2ray docker-compose file"
        systemctl disable --now docker
        judge "Disable Docker Service"
        apt purge -y docker-engine docker docker-compose docker.io docker-ce docker-ce-cli docker-compose-plugin containerd containerd.io
        judge "Remove Docker"
        ;;
    *) ;;
    esac

    if ! command -v nginx; then
        print_info "Nginx is not installed"
    else
        print_info "Do you want to Disable (Not uninstall) Nginx (This will free 443 and 80 port) [y/n]?"
        read -r disable_nginx
        case $disable_nginx in
        [yY][eE][sS] | [yY])
            systemctl disable --now nginx.service
            ;;
        *) ;;
        esac

        print_info "Do you want to uninstall Nginx [y/n]?"
        read -r uninstall_nginx
        case $uninstall_nginx in
        [yY][eE][sS] | [yY])
            rm -rf /var/www/html/*
            systemctl disable --now nginx.service
            apt purge nginx -y
            ;;
        *) ;;
        esac
    fi

    print_info "Uninstall certbot (This will remove SSL Cert files too)? [y/n]?"
    read -r uninstall_certbot
    case $uninstall_certbot in
    [yY][eE][sS] | [yY])
        apt purge certbot python3-certbot -y
        rm -rf /etc/letsencrypt/
        rm -rf /var/log/letsencrypt/
        rm -rf /etc/systemd/system/*certbot*
        rm -rf /ssl/
        ;;
    *) ;;
    esac

    print_ok "Uninstall complete"
    exit 0
}

function restart_all() {
    systemctl restart nginx
    judge "Nginx restart"
    cd /root/ && docker-compose restart
    judge "v2ray restart"
}

function restart_vray() {
    cd /root/ && docker-compose restart
    judge "v2ray restart"
}

function bbr_boost() {
    wget -N --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && bash bbr.sh
}

function configure_user_management() {
    echo -e "checking..."
    if [[ ! -e "${config_path}" ]]; then
        print_error "can't find v2ray config. Seems like you don't installed v2ray"
        exit 1
    else
        print_ok "v2ray is installed"
    fi

    if grep -q -E -o "[1-9]{1,3}@" ${config_path} ; then
        print_ok "admin user found"
    else
        cp ${config_path} ${vray_conf_dir}/config.json.bak1
        judge "make backup file from config.json"
        cat ${config_path} | jq 'setpath(["inbounds",0,"settings","clients",0,"email"];"1@admin")' >${vray_conf_dir}/config_tmp.json
        judge "initialize first user"
        vray_tmp_config_file_check_and_use
    fi

    if [[ ! -e "${users_count_file}" && ! -e "${users_number_in_config_file}" ]]; then
        print_info "users_count.txt not found! Creating one..."
        touch ${users_count_file}
        judge "create user count file"
        echo -e "1" > ${users_count_file}
        touch ${users_number_in_config_file}
        judge "create user number file"
        echo -e "1" > ${users_number_in_config_file}
    else
        print_ok "rquired files exist"
    fi
}

function user_counter() {
    configure_user_management
    users_count=$(cat ${users_count_file})

    if [[ -e ${users_number_in_config_file} ]];then
        rm -rf ${users_number_in_config_file}
        judge "remove old user_number file"
        touch ${users_number_in_config_file}
        judge "create new user_number file"
    fi

    cat ${config_path} | grep "email" | grep -Eo "[1-9]{1,3}" | xargs -I INPUT echo INPUT >> ${users_number_in_config_file}
    judge "write users in users_number file"
    echo -e "\nCurrent Users Count = ${users_count}"
    echo -e "Old Users:"
    for ((i = 0; i < ${users_count}; i++)); do
        config_i=$(($i + 1))
        current_client=$(sed -n "${config_i}p" ${users_number_in_config_file})
        name=$(cat ${config_path} | jq .inbounds[0].settings.clients[${i}].email | tr -d '"' | grep "@." | tr -d "[1-9]{1,3}@")
        current_user_number=$(cat ${config_path} | jq .inbounds[0].settings.clients[${i}].email | grep -Eo "[1-9]{1,3}")
        echo -e "  ${i}) $name \t(e-n: ${current_user_number})"
    done
    echo -e ""
}

# ========== VMESS ========== #

# ==== VMESS + WS + TLS ====
function vmess_ws_tls_link_gen() {
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"ws\",\"path\": \"$WEBSOCKET_PATH\",\"port\": \"$PORT\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}

function users_vmess_ws_tls_link_gen() {
    user_counter
    read -rp "Choose User: " user_number
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[${user_number}].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"ws\",\"path\": \"$WEBSOCKET_PATH\",\"port\": \"$PORT\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}

function vmess_ws_tls() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    domain_check
    configure_certbot
    wget -O ${vray_conf_dir}/config.json https://raw.githubusercontent.com/thehxdev/vray-examples/main/VMess-Websocket-TLS-s/config.json
    judge "Download configuration"
    modify_port
    modify_UUID
    modify_ws
    modify_tls
    #restart_vray
    ln -s -f ${config_path} /root/
    vray_install
    vmess_ws_tls_link_gen
    CONFIG_PROTO="VmessWsTls"
    save_protocol
}

# ==== VMESS + WS + Nginx + TLS ====

function vmess_ws_nginx_tls_link_gen() {
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"ws\",\"path\": \"$WEBSOCKET_PATH\",\"port\": \"443\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}

function users_vmess_ws_nginx_tls_link_gen() {
    user_counter
    read -rp "Choose User: " user_number
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[${user_number}].id | tr -d '"')
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"ws\",\"path\": \"$WEBSOCKET_PATH\",\"port\": \"443\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}


function vmess_ws_nginx_tls() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    domain_check
    configure_certbot
    port_exist_check 80
    port_exist_check 443
    install_nginx
    configure_nginx_reverse_proxy_tls
    add_wsPath_to_nginx
    setup_fake_website
    restart_nginx
    wget -O ${vray_conf_dir}/config.json https://raw.githubusercontent.com/thehxdev/vray-examples/main/VMess-Websocket-Nginx-TLS-s/server_config.json
    judge "Download configuration"
    modify_UUID
    modify_ws
    #restart_all
    restart_nginx
    ln -s -f ${config_path} /root/
    vray_install
    vmess_ws_nginx_tls_link_gen
    CONFIG_PROTO="VmessWsNginxTls"
    save_protocol
}

# VMESS + TCP + TLS
function vmess_tcp_tls_link_gen() {
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    #WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"tcp\",\"path\": \"\",\"port\": \"$PORT\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}

function users_vmess_tcp_tls_link_gen() {
    user_counter
    read -rp "Choose User: " user_number
    read -rp "Choose config name: " config_name
    UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[${user_number}].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    #WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    server_link=$(echo -neE "{\"add\": \"$SERVER_IP\",\"aid\": \"0\",\"host\": \"\",\"id\": \"$UUID\",\"net\": \"tcp\",\"path\": \"\",\"port\": \"$PORT\",\"ps\": \"$config_name\",\"scy\": \"chacha20-poly1305\",\"sni\": \"$CONFIG_DOMAIN\",\"tls\": \"tls\",\"type\": \"\",\"v\": \"2\"}" | base64 | tr -d '\n')

    qrencode -t ansiutf8 -l L vmess://${server_link}
    echo -ne "${Green}VMESS Link: ${Yellow}vmess://$server_link${Color_Off}\n"
}

function vmess_tcp_tls() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    domain_check
    configure_certbot
    wget -O ${vray_conf_dir}/config.json https://raw.githubusercontent.com/thehxdev/vray-examples/main/VMess-TCP-TLS-s/config_server.json
    judge "Download configuration"
    modify_port
    modify_UUID
    modify_tls
    #restart_vray
    ln -s -f ${config_path} /root/
    vray_install
    vmess_tcp_tls_link_gen
    CONFIG_PROTO="VmessTcpTls"
    save_protocol
}

# ========== Trojan ========== #

# ==== Torojan + TCP + TLS ====

function trojan_tcp_tls_link_gen() {
    read -rp "Choose config name: " config_name
    #UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    #WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    PASSWORD=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].password | tr -d '"')
    server_link=$(echo -neE "$PASSWORD@$SERVER_IP:$PORT?sni=$CONFIG_DOMAIN&security=tls&type=tcp#$config_name")

    qrencode -t ansiutf8 -l L trojan://${server_link}
    echo -ne "${Green}Trojan Link: ${Yellow}trojan://$server_link${Color_Off}\n"
}

function users_trojan_tcp_tls_link_gen() {
    user_counter
    read -rp "Choose User: " user_number
    read -rp "Choose config name: " config_name
    #UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    #WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    PASSWORD=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[${user_number}].password | tr -d '"')
    server_link=$(echo -neE "$PASSWORD@$SERVER_IP:$PORT?sni=$CONFIG_DOMAIN&security=tls&type=tcp#$config_name")

    qrencode -t ansiutf8 -l L trojan://${server_link}
    echo -ne "${Green}Trojan Link: ${Yellow}trojan://$server_link${Color_Off}\n"
}

function trojan_tcp_tls() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    domain_check
    configure_certbot
    wget -O ${vray_conf_dir}/config.json https://raw.githubusercontent.com/thehxdev/vray-examples/main/Trojan-TCP-TLS-s/config_server.json
    judge "Download configuration"
    modify_port
    modify_PASSWORD
    modify_tls
    #restart_vray
    ln -s -f ${config_path} /root/
    vray_install
    trojan_tcp_tls_link_gen
    CONFIG_PROTO="TrojanTcpTls"
    save_protocol
}

# ==== Torojan + WS + TLS ====

function trojan_ws_tls_link_gen() {
    read -rp "Choose config name: " config_name
    #UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    PASSWORD=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].password | tr -d '"')
    server_link=$(echo -neE "$PASSWORD@$SERVER_IP:$PORT?sni=$CONFIG_DOMAIN&security=tls&type=ws&path=$WEBSOCKET_PATH#$config_name")

    qrencode -t ansiutf8 -l L trojan://${server_link}
    echo -ne "${Green}Trojan Link: ${Yellow}trojan://$server_link${Color_Off}\n"
}

function users_trojan_ws_tls_link_gen() {
    user_counter
    read -rp "Choose User: " user_number
    read -rp "Choose config name: " config_name
    #UUID=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[0].id | tr -d '"')
    PORT=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].port)
    WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
    SERVER_IP=$(curl -s4m8 https://icanhazip.com)
    CONFIG_DOMAIN=$(cat /usr/local/domain.txt)
    PASSWORD=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].settings.clients[${user_number}].password | tr -d '"')
    server_link=$(echo -neE "$PASSWORD@$SERVER_IP:$PORT?sni=$CONFIG_DOMAIN&security=tls&type=ws&path=$WEBSOCKET_PATH#$config_name")

    qrencode -t ansiutf8 -l L trojan://${server_link}
    echo -ne "${Green}Trojan Link: ${Yellow}trojan://$server_link${Color_Off}\n"
}

function trojan_ws_tls() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    domain_check
    configure_certbot
    #get_ssl_cert
    wget -O ${vray_conf_dir}/config.json https://raw.githubusercontent.com/thehxdev/vray-examples/main/Trojan-Websocket-TLS-s/config_server.json
    judge "Download configuration"
    modify_port
    modify_ws
    modify_PASSWORD
    modify_tls
    #restart_vray
    ln -s -f ${config_path} /root/
    vray_install
    trojan_ws_tls_link_gen
    CONFIG_PROTO="TrojanWsTls"
    save_protocol
}
# ================================== #

# Dokodemo
function dokodemo_door_setup() {
    check_bash
    check_root
    check_os
    disable_firewalls
    install_deps
    basic_optimization
    ip_check
    read -rp "Enter Listening Port: " LISTENING_PORT
    read -rp "Enter Foreign Server IP Address: " FOREIGN_SERVER_IP
    read -rp "Enter Foreign Server Port: " FOREIGN_SERVER_PORT
    cat << EOF > ${vray_conf_dir}/config.json
{
    "inbounds": [
        {
            "port": ${LISTENING_PORT},
            "listen": "0.0.0.0",
            "protocol": "dokodemo-door",
            "settings": {
                "address": "${FOREIGN_SERVER_IP}",
                "port": ${FOREIGN_SERVER_PORT},
                "network": "tcp,udp",
                "timeout": 0,
                "followRedirect": false,
                "userLevel": 0
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
    #restart_vray
    ln -s -f ${config_path} /root/
    vray_install
    CONFIG_PROTO="dokodemo"
    save_protocol
}

function shecan_dns() {
    ip_check
    if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
        print_error "Shecan does not support IPv6"
        exit 1
    else
        echo "nameserver 178.22.122.100" > /etc/resolv.conf
        echo "nameserver 185.51.200.2" >> /etc/resolv.conf
        judge "add IPv4 DNS to resolv.conf"
    fi
}

# ===================================== #

# Get Config Link
function save_protocol() {
    if [[ -e "/root/docker-compose.yaml" ]]; then
        echo "${CONFIG_PROTO}" > ${proto_file}
    fi
}

function check_domain_file() {
    if [[ -e "/usr/local/domain.txt" ]]; then
        print_ok "domain file found!"
    else
        echo -e "${Yellow}domain.txt file not found!${Color_Off}"
        read -rp "Enter Your domain: " user_domain
        echo -e "${user_domain}" > /usr/local/domain.txt
        judge "add user domain to domain.txt"
    fi
}

function get_config_link() {
    if [[ -e "${proto_file}" ]]; then
        CURRENT_CONFIG=$(cat ${proto_file})
        print_ok "proto.txt file found!"
    else
        get_current_protocol
        CURRENT_CONFIG=$(cat ${proto_file})
    fi

    if [[ ${CURRENT_CONFIG} == "VmessWsTls" ]]; then
        check_domain_file
        users_vmess_ws_tls_link_gen
    elif [[ ${CURRENT_CONFIG} == "VmessWsNginxTls" ]]; then
        check_domain_file
        users_vmess_ws_nginx_tls_link_gen
    elif [[ ${CURRENT_CONFIG} == "VmessTcp" ]]; then
        users_vmess_tcp_link_gen
    elif [[ ${CURRENT_CONFIG} == "VmessTcpTls" ]]; then
        check_domain_file
        users_vmess_tcp_tls_link_gen
    elif [[ ${CURRENT_CONFIG} == "TrojanTcpTls" ]]; then
        check_domain_file
        users_trojan_tcp_tls_link_gen
    elif [[ ${CURRENT_CONFIG} == "TrojanWsTls" ]]; then
        check_domain_file
        users_trojan_ws_tls_link_gen
    fi
}

# ===================================== #

# Define current protocol
function get_current_protocol() {
    if [ ! -e "${proto_file}" ]; then
        if grep -q "xtls" ${config_path} && grep -q "vless" ${config_path}; then
            echo -e "ultimate" > ${proto_file}
            judge "add ultimate to proto.txt"

        elif grep -q "vless" ${config_path} && grep -q "wsSettings" ${config_path} && grep -q "tlsSettings" ${config_path}; then
            echo -e "VlessWsTls" > ${proto_file}
            judge "add VlessWsTls to proto.txt"

        elif grep -q "vless" ${config_path} && grep -q "tcp" ${config_path} && grep -q "tlsSettings" ${config_path}; then
            echo -e "VlessTcpTls" > ${proto_file}
            judge "add VlessTcpTls to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "wsSettings" ${config_path} && ! grep -q "tlsSettings" ${config_path} && ! grep -q "127.0.0.1" ${config_path}; then
            echo -e "VmessWs" > ${proto_file}
            judge "add VmessWs to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "wsSettings" ${config_path} && grep -q "tlsSettings" ${config_path} && ! grep -q "127.0.0.1" ${config_path}; then
            echo -e "VmessWsTls" > ${proto_file}
            judge "add VmessWsTls to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "127.0.0.1" ${config_path} && ! grep -q "ssl_certificate" ${nginx_conf}; then
            echo -e "VmessWsNginx" > ${proto_file}
            judge "add VmessWsNginx to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "127.0.0.1" ${config_path} && grep -q "ssl_certificate" ${nginx_conf}; then
            echo -e "VmessWsNginxTls" > ${proto_file}
            judge "add VmessWsNginxTls to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "tcp" ${config_path} && ! grep -q "tlsSettings" ${config_path}; then
            echo -e "VmessTcp" > ${proto_file}
            judge "add VmessTcp to proto.txt"

        elif grep -q "vmess" ${config_path} && grep -q "tcp" ${config_path} && grep -q "tlsSettings" ${config_path}; then
            echo -e "VmessTcpTls" > ${proto_file}
            judge "add VmessTcpTls to proto.txt"

        elif grep -q "trojan" ${config_path} && grep -q "tcp" ${config_path}; then
            echo -e "TrojanTcpTls" > ${proto_file}
            judge "add TrojanTcpTls to proto.txt"

        elif grep -q "trojan" ${config_path} && grep -q "wsSettings"; then
            echo -e "TrojanWsTls" > ${proto_file}
            judge "add TrojanWsTls to proto.txt"

        elif grep -q "trojan" ${config_path} && grep -q "xtls" ${config_path}; then
            echo -e "TrojanTcpXtls" > ${proto_file}
            judge "add TrojanTcpXtls to proto.txt"

        else
            print_error "Can't detect your configureation"
            exit 1
        fi
    else
        print_ok "proto.txt file exist"
    fi
}

# ===================================== #

function make_backup() {
    if [ ! -e ${backup_dir} ]; then
        mkdir ${backup_dir} >/dev/null 2>&1
        judge "make bakup directory" 
    else
        print_ok "backup directory exist!"
        rm -rf /root/old_vray_backups/*
        judge "make old_vray_backups directory empty"
        mkdir /root/old_vray_backups/ >/dev/null 2>&1
        mv ${backup_dir} /root/old_vray_backups/
        judge "move existing backup to /root/old_vray_backups"
        mkdir ${backup_dir} >/dev/null 2>&1
        if [ -e "/root/vray_backup.tar.gz" ]; then
            mv /root/vray_backup.tar.gz /root/old_vray_backups/
            judge "move existing backup.tar.gz to /root/old_vray_backups"
        fi
    fi

    if [ -e ${vray_conf_dir} ]; then
        mkdir ${backup_dir}/vray >/dev/null 2>&1
        cp -r ${vray_conf_dir}/* ${backup_dir}/vray/
        judge "copy vray configurations"
        if [ -e "/usr/local/domain.txt" ]; then
            cp /usr/local/domain.txt ${backup_dir}
            judge "copy domain.txt file"
        fi
    fi

    if [ -e "/etc/nginx" ]; then
        WEBSOCKET_PATH=$(cat ${vray_conf_dir}/config.json | jq .inbounds[0].streamSettings.wsSettings.path | tr -d '"')
        WEBSOCKET_PATH_IN_NGINX=$(grep -o ${WEBSOCKET_PATH} ${nginx_conf})
        if [[ -n ${WEBSOCKET_PATH} && -n ${WEBSOCKET_PATH_IN_NGINX} ]]; then
            if [[ ${WEBSOCKET_PATH} == ${WEBSOCKET_PATH_IN_NGINX} ]]; then
                cp -r /etc/nginx/ ${backup_dir}
                judge "copy nginx configurations"
            else
                print_info "Nginx WebSocket path and V2ray WebSocket path are not same as each other."
                print_info "Probably Nginx is not used for V2ray!"
                print_info "Nginx Backup Skipped!"
            fi
        else
            print_info "Nginx WebSocket path or V2ray WebSocket path is NOT defined."
            print_info "Probably Nginx is not used for V2ray!"
            print_info "Nginx Backup Skipped!"
        fi
    else
        print_info "nginx config files not found or not installed. No Problem!"
    fi

    if [[ -e "/ssl" ]]; then
        cp -r /ssl ${backup_dir}
        judge "copy SSL certs for V2ray"
    else
        print_info "No SSL certificate found for V2ray. No problem!"
    fi

    if [[ -e "${users_expiry_date_file}" ]]; then
        cp -r ${users_expiry_date_file} ${backup_dir}
        judge "Copy users expiry date file"
    else
        print_info "Users expiry date file not found! Skipping..."
    fi

    if ! command -v gzip; then
        installit gzip tar
    else
        print_ok "gzip installed"
    fi

    tar -czf /root/vray.tar.gz -C ${backup_dir} .
    judge "Compress and put backup files if one .tar.gz file"
}

function restore_backup() {
    if [[ ! -e "${vray_docker_compose_file}" ]]; then
        print_info "V2ray is not installed" && sleep 0.5
        print_info "installing V2ray-core with docker" && sleep 1
        vray_install
    else
        print_ok "V2ray is installed"
    fi

    if [[ -e "/root/vray_backup" ]]; then
        mv /root/vray_backup /root/old_vray_backups
        judge "rename old backup dir to vray_backup_old"
        mkdir /root/vray_backup >/dev/null 2>&1
        judge "create new vray_backup"
    else
        mkdir /root/vray_backup >/dev/null 2>&1
        judge "create new vray_backup"
    fi

    if [[ -e "/root/vray_backup.tar.gz" ]]; then
        tar -xzf /root/vray_backup.tar.gz -C /root/vray_backup
        judge "extract backup file"
    else
        print_error "can't find vray_backup.tar.gz! if you have a backup file put it into /root/ directory and rename it to vray_backup.tar.gz"
        exit 1
    fi

    if [[ -e "${backup_dir}" ]]; then
        if [[ -e "${backup_dir}/nginx" ]]; then
            cp -r ${backup_dir}/nginx /etc/
            judge "restore nginx config"
            if command -v nginx; then
                systemctl restart nginx
                judge "restart nginx"
            else
                print_info "nginx is not installed"
                install_nginx
                systemctl restart nginx
                judge "restart nginx after fresh install"
            fi
        fi

        if [[ -e "${backup_dir}/vray" ]]; then
            if [[ -e "${vray_conf_dir}" ]]; then
                rm -rf ${vray_conf_dir}/*
                judge "remove old configs"
                cp -r ${backup_dir}/vray/* ${vray_conf_dir}/
                judge "restore vray files"
                systemctl restart vray
                judge "restart vray"
            else
                print_error "${vray_conf_dir} not found"
            fi
        fi

        if [[ -e "${backup_dir}/domain.txt" ]]; then
            cp ${backup_dir}/domain.txt /usr/local/domain.txt
            judge "restore domain.txt"
        fi

        if [[ -e "${backup_dir}/ssl" ]]; then
            if [[ -e "/ssl/vray.crt" && -e "/ssl/vray.key" ]]; then
                print_info "You already have SSL certificates in your /ssl/ directory. Do you want to replace them with old ones? [y/n]"
                read -r replace_old_ssl
                case $replace_old_ssl in
                [yY][eE][sS] | [yY])
                    mv /ssl /ssl_old
                    judge "rename /ssl dir"
                    cp -r ${backup_dir}/ssl /
                    judge "restore SSL certificates for vray"
                    chown -R nobody.$cert_group /ssl/*
                    ;;
                *) 
                    print_info "SSL certificates remained untouched"
                    ;;
                esac
            fi
        else
            cp -r ${backup_dir}/ssl /
            judge "restore SSL certificates for vray"
        fi

        if [[ -e "${backup_dir}/users_expiry_date.txt" ]]; then
            cp -r ${backup_dir}/${users_expiry_date_file} ${vray_conf_dir}/
            judge "Restore users expiry date file"
        else
            print_info "Users expiry date file not found! Skipping..."
        fi

        print_ok "Bakup restore Finished"
    fi
}

# ===================================== #

# Nginx Status
function nginx_status() {
    if ! command -v nginx; then
        print_info "Nginx is not installed"
        exit 1
    else
        systemd_nginx_status=$(systemctl status nginx | grep Active | grep -Eo "active|inactive")
        if [[ ${systemd_nginx_status} == "active" ]]; then
            echo -e "${Green}Active${Color_Off}"
            nginx_status_var="active"
            exit 0
        elif [[ ${systemd_nginx_status} == "inactive" ]]; then
            echo -e "${Red}Inactive${Color_Off}"
            nginx_status_var="inactive"
            exit 0
        fi
    fi
}

# ===================================== #

# Read v2ray Config

function read_current_config() {
    if [[ -e "${config_path}" ]]; then
        current_port=$(cat ${config_path} | jq .inbounds[0].port)
        current_protocol=$(cat ${config_path} | jq .inbounds[0].protocol)
        current_users_count=$(cat ${users_count_file})
        current_network=$(cat ${config_path} | jq .inbounds[0].streamSettings.network)
        current_ws_path=$(cat ${config_path} | jq .inbounds[0].streamSettings.wsSettings.path)
        current_security=$(cat ${config_path} | jq .inbounds[0].streamSettings.security)

        echo -e "========================================="
        echo -e "Users Count: ${current_users_count}"

        if [[ ${current_port} == "10000" ]]; then
            if grep -q "127.0.0.1" ${config_path}; then
                echo -e "Port: 443 (Nginx)"
            else
                echo -e "Port: ${current_port}"
            fi
        else
            echo -e "Port: ${current_port}"
        fi

        echo -e "Protocol: ${current_protocol}"
        echo -e "Network: ${current_network}"

        if [[ -n ${current_ws_path} ]]; then
            echo -e "WebSocket Path: ${current_ws_path}"
        else
            echo -e "Websocket Path: None or Not Used"
        fi

        echo -e "Security: ${current_security}"

        #if [[ -n ${current_active_connections} ]]; then
        #    echo -e "Active Connections: ${current_active_connections}"
        #fi

        echo -e "========================================="
    else
        print_error "v2ray config NOT found! Probably v2ray is not installed!"
        exit 1
    fi
}

function make_v2ray_dir() {
    if [[ ! -e "${vray_conf_dir}" ]]; then
        mkdir ${vray_conf_dir}
        judge "Make v2ray config dir"
    else
        print_ok "v2ray Directory exists"
    fi
}

# ===================================== #
function vray_setup_menu() {
    clear
    echo -e "====================  VMESS  ======================"
    echo -e "${Green}1. VMESS + WS + TLS${Color_Off}"
    echo -e "${Green}2. VMESS + WS + Nginx (With TLS)${Color_Off}"
    echo -e "${Green}3. VMESS + TCP + TLS${Color_Off}"
    echo -e "====================  TROJAN  ====================="
    echo -e "${Green}4. Trojan + TCP + TLS${Color_Off}"
    echo -e "${Green}5. Trojan + WS + TLS${Color_Off}"
    echo -e "===================================================="
    echo -e "${Yellow}6. Exit${Color_Off}\n"

    read -rp "Enter an Option: " menu_num
    case $menu_num in
    1)
        make_v2ray_dir
        vmess_ws_tls
        echo -e "1" > ${users_count_file}
        echo -e "1" > ${users_number_in_config_file}
        ;;
    2)
        make_v2ray_dir
        vmess_ws_nginx_tls
        echo -e "1" > ${users_count_file}
        echo -e "1" > ${users_number_in_config_file}
        ;;
    3)
        make_v2ray_dir
        vmess_tcp_tls
        echo -e "1" > ${users_count_file}
        echo -e "1" > ${users_number_in_config_file}
        ;;
    4)
        make_v2ray_dir
        trojan_tcp_tls
        echo -e "1" > ${users_count_file}
        echo -e "1" > ${users_number_in_config_file}
        ;;
    5)
        make_v2ray_dir
        trojan_ws_tls
        echo -e "1" > ${users_count_file}
        echo -e "1" > ${users_number_in_config_file}
        ;;
    6)
        exit 0
        ;;
    *)
        print_error "Invalid Option. Run script again!"
        exit 1
    esac
}

function forwarding_menu() {
    clear
    echo -e "=================== Forwarding ==================="
    echo -e "${Green}1. Send Golang and Gost to domestic relay${Color_Off}"
    echo -e "${Green}2. Install and configure Gost ${Cyan}(Run on domestic relay)${Color_Off}"
    echo -e "${Green}3. Install and configure V2ray Dokodemo-door ${Cyan}(Run on domestic relay)${Color_Off}"
    echo -e "${Yellow}4. Exit${Color_Off}\n"
    read -rp "Enter an Option: " menu_num
    case $menu_num in
    1)
        send_go_and_gost
        ;;
    2)
        configure_gost_and_go
        ;;
    3)
        dokodemo_door_setup
        ;;
    4)
        exit 0
        ;;
    *)
        print_error "Invalid Option. Run script again!"
        exit 1
    esac
}

function vray_and_vps_settings() {
    clear
    echo -e "========== Settings =========="
    echo -e "${Green}1. Change vps DNS to Cloudflare${Color_Off}"
    echo -e "${Green}2. Change vps DNS to Shecan${Color_Off}"
    echo -e "${Green}3. Enable BBR TCP Boost${Color_Off}"
    echo -e "${Green}4. Get Nginx Status${Color_Off}"
    echo -e "${Green}5. Get Current V2ray Config Info${Color_Off}"
    echo -e "${Yellow}6. Exit${Color_Off}\n"
    read -rp "Enter an Option: " menu_num
    case $menu_num in
    1)
        cloudflare_dns
        ;;
    2)
        shecan_dns
        ;;
    3)
        bbr_boost
        ;;
    4)
        nginx_status
        ;;
    5)
        read_current_config
        ;;
    6)
        exit 0
        ;;
    *)
        print_error "Invalid Option. Run script again!"
        exit 1
    esac
}

function user_management_and_backup_menu() {
    clear
    echo -e "=============== User Management ================"
    echo -e "${Cyan}1. Get Users Configuration Link${Color_Off}"
    echo -e "${Blue}2. User Management System${Color_Off}"
    echo -e "=================== Backup ====================="
    echo -e "${Green}3. Make Backup${Color_Off}"
    echo -e "${Green}4. Restore existing backup${Color_Off}"
    echo -e "${Yellow}5. Exit${Color_Off}\n"
    read -rp "Enter an Option: " menu_num
    case $menu_num in
    1)
        get_config_link
        ;;
    2)
        if ! command -v jq; then
            apt update && apt install jq
        fi
        bash -c "$(curl -L https://github.com/thehxdev/vray-install/raw/main/manage_vray_users.sh)"
        ;;
    3)
        make_backup
        ;;
    4)
        restore_backup
        ;;
    5)
        exit 0
        ;;
    *)
        print_error "Invalid Option. Run script again!"
        exit 1
    esac
}

function greetings_screen() {
    clear
    echo -e '
██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗    ██╗  ██╗██╗  ██╗
██║   ██║╚════██╗██╔══██╗██╔══██╗╚██╗ ██╔╝    ██║  ██║╚██╗██╔╝
██║   ██║ █████╔╝██████╔╝███████║ ╚████╔╝     ███████║ ╚███╔╝
╚██╗ ██╔╝██╔═══╝ ██╔══██╗██╔══██║  ╚██╔╝      ██╔══██║ ██╔██╗
 ╚████╔╝ ███████╗██║  ██║██║  ██║   ██║       ██║  ██║██╔╝ ██╗
  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝

=> by thehxdev
=> https://github.com/thehxdev/
'

    echo -e "${Green}1. Setup V2ray${Color_Off}"
    echo -e "${Green}2. Forwarding Tools${Color_Off}"
    echo -e "${Green}3. V2ray and VPS Settings${Color_Off}"
    echo -e "${Green}4. User Management and Backup Tools${Color_Off}"
    echo -e "${Red}5. Uninstall V2ray${Color_Off}"
    echo -e "${Yellow}6. Exit${Color_Off}\n"

    read -rp "Enter an Option: " menu_num
    case $menu_num in
    1)
        vray_setup_menu
        ;;
    2)
        forwarding_menu
        ;;
    3)
        vray_and_vps_settings
        ;;
    4)
        user_management_and_backup_menu
        ;;
    5)
        vray_uninstall
        ;;
    6)
        exit 0
        ;;
    *)
        print_error "Invalid Option. Run script again!"
        exit 1
    esac
}

greetings_screen "$@"


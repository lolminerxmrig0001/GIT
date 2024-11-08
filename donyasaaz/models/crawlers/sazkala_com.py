import re
import logging
import requests
from urllib3.exceptions import InsecureRequestWarning
import os
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
import time
import sys

def sazkala(link, headers, site):
    try:
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--no-sandbox')
        sys.path.append("C:\\Users\\USER\\donyasaaz\\chromedriver.exe")
        driver = webdriver.Chrome(executable_path="C:\\Users\\USER\\donyasaaz\\chromedriver.exe",
                                  options=chrome_options)
        driver.get(link.url)
        time.sleep(3)
        soup = BeautifulSoup(driver.page_source, "html.parser")
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.info('%s :  %s,', site, e)
        return None

    button = soup.find("button", attrs={"class": re.compile("single_add_to_cart_button button alt*")})
    not_found = soup.find_all("div", attrs={"class":"absolute-label-product outofstock-product"})
    if button and not not_found and 'wc-variation-is-unavailable' not in button.attrs['class']:
        div = soup.find("p", attrs={"class": "price"})
        if div is None:
            return -1
        p = div.find_all("span", attrs={"class": "woocommerce-Price-amount amount"})
        if len(p) == 0:
            return -1
        elif len(p) == 1:
            a = re.sub(r',', '', p[0].text).strip()
        else:
            if p[0].parent.name == 'del':
                a = re.sub(r',', '', p[1].text).strip()
            else:
                a = re.sub(r',', '', p[0].text).strip()
        b = re.findall(r'\d+', a)
        return int(b[0])
    else:
        return -1

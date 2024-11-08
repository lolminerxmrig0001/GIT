import re
import logging

import requests
from urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup


def sazforoosh(link, headers, site):
    try:
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        response = requests.get(link.url, headers=headers, verify=False)
        soup = BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.info('%s :  %s,', site, e)

        return None

    p = soup.find("div", attrs={"class": "price"})
    if soup.find("div", attrs={"id": "product"}).find('p'):
        return -1
    else:
        s = p.find("h3")
        if s is None:
            s = soup.find("label", attrs={"class": "stock-type"})
        if s is None or s.text.__contains__("کارکرده"):
            return -1
        a = re.sub(r',', '', s.text).strip()
        b = re.findall(r'\d+', a)
        return int(b[0])

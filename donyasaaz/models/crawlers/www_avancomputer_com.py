import re
import logging

import requests
from urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup


def avancomputer_com(link, headers, site):
    try:
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        response = requests.get(link.url, headers=headers, verify=False)
        soup = BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.info('%s :  %s,', site, e)

        return None

    if soup.find("button", attrs={"class": "btn btn-success product-addtocart"}):
        p = soup.find("h5", attrs={"class": "product-price"})
        if p is None:
            return -1
        if len(p) ==1:
            a = re.sub(r',', '', p[0].text).strip()
        else:
         a = re.sub(r',', '', p.text).strip()
        b = re.findall(r'\d+', a)
        if len(b) == 0:
            return -1
        else:
            return int(b[0])
    else:
        return -1

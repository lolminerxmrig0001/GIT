import re
import logging
import math
import requests
from urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup


def dourbinet(link, headers, site):
    try:
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        response = requests.get(link.url, headers=headers, verify=False)
        soup = BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.info('%s :  %s,', site, e)

        return None

    p = soup.find("span", attrs={"class": "price"})
    if p:
        p = soup.find("span", attrs={"class": "price"})
        a = re.sub(r',', '', p.text).strip()
        b = re.findall(r'\d+', a)
        if len(b) == 0:
            return -1
        return math.floor(int(b[0])/10)
    else:
        return -1

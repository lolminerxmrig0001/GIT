import re
import logging

import requests
from urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup


def pianoforte(link, headers, site):
    try:
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        response = requests.get(link.url, headers=headers, verify=False)
        soup = BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.info('%s :  %s,', site, e)

        return None

    s= soup.find("div", attrs={"class": "amount text-max f-25 yekanr"})
    if s is not None:
        a = re.sub(r',', '', s.text).strip()
        if(a.__contains__('تماس بگیرید')):
            return -1
        b = re.findall(r'\d+', a)
        if len(b) == 0:
            return -1
        return int(b[0])
    else:
        return -1

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import logging
import os
import time

from api import handle_zoomeye
from lib import data
from lib.cmd import cmdparse
from lib.data import conf
from lib.log import init_log


def set_log(verbose):
    log_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), '../log')
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    log_filename = time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime()) + ".log"
    log_file = os.path.join(log_dir, log_filename)
    level = logging.INFO
    if verbose:
        level = logging.DEBUG
    data.logger = init_log(__name__, level, log_file)


if __name__ == "__main__":
    conf.update(cmdparse().__dict__)
    print(conf)
    set_log(conf.verbose)
    res = set()
    data.logger.debug(f"dork:{conf.dork}")
    if conf.api_name == "zoomeye":
        res = handle_zoomeye(conf.dork, conf.limit, type=conf.type)
    else:
        data.logger.error("illegal api type")
    with open(conf.output, 'w', encoding='utf-8') as f:
        for i in res:
            f.write(f"{i}\n")
    data.logger.info(f"爬取到{len(res)}条数据，保存在{conf.output}中")

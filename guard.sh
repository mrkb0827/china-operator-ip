#!/bin/bash

[[ $(wc -l result/lz_all_cn_cidr.txt) < 3000 ]] && exit 1

[[ $(wc -l result/china6.txt) < 1000 ]] && exit 2

exit 0

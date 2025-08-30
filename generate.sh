#!/usr/bin/env bash

set -e
source common.sh
[[ $SKIP_DATA_PREPARATION != true ]] && prepare_data
mkdir -p result
for file in operator/*.conf; do
	operator=${file%.*}
	operator=${operator##*/}
	log_info "generating IP list of $operator ..."
	get_asn $file
	get_asn $file | xargs bgptools -b rib.txt  | cidr-merger -s | grep -Fv : | cat > result/${operator}.txt &
	get_asn $file | xargs bgptools -b rib6.txt | grep -v '^::/0$' | cidr-merger -s | grep -F  : | cat > result/${operator}6.txt &
done

wait_exit
for file in operator/*.conf; do
	operator=${file%.*}
	operator=${operator##*/}
	log_info "generating clash rule $operator ..."
        echo -e "payload:" > result/${operator}_clash.txt
	cat result/${operator}.txt | perl -ne '/(.+\/\d+)/ && print "  - |$1|\n"' | sed "s/|//g" >> result/${operator}_clash.txt
done
	echo -e "payload:" > result/china6_clash.txt
	cat result/lz_all_cn_cidr6.txt | perl -ne '/(.+\/\d+)/ && print "  - |$1|\n"' | sed "s/|//g" >> result/china6_clash.txt

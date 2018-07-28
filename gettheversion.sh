#/bin/bash
ls -lrt target/ | grep myweb | grep -v war | awk -F "-" '{print $NF}'

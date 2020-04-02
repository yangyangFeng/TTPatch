ip=`ifconfig | grep inet | grep -v inet6 | grep -v 127 | cut -d ' ' -f2 `
# TTPatchIP=$ip
echo $ip
newIP="cat '1,2' tr "," " ""
echo $newIP
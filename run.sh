size=10000
from=0

TYPE=$1

a=`date +%D  --date="-4 day"`
echo "a:$a"
t_start=`date +%s -d"$a 7:59:49"`

if [ -f "START_T" ];then
	t_start=`cat START_T_$TYPE`
fi

echo "t_start:$t_start"
b=`date +%D  --date="-3 day"`
echo "b:$b"
t_end=`date +%s -d"$b 7:59:49"`
echo "t_end:$t_end"

let t_tmp=$t_start+1200
echo "t_tmp:$t_tmp"


while (( $t_tmp <= $t_end  ))
do
	filename=${TYPE}_`date +%s`
	sed -e "s/#SIZE/$size/g" es.temp > ${TYPE}_tmp.temp
	sed -i "s/#TYPE/$TYPE/g" ${TYPE}_tmp.temp
	sed -i "s/#START_T/$t_start/g" ${TYPE}_tmp.temp
	sed -i "s/#END_T/$t_tmp/g" ${TYPE}_tmp.temp
	sed -e "s/#FROM/$from/g" ${TYPE}_tmp.temp > $filename

	echo "开始查询from:$t_start to:$t_tmp"

	t_start=$t_tmp
	let t_tmp=$t_tmp+1200

	echo $t_start > START_T_$TYPE

	#执行查询
	mkdir -p /tmp/es_data_tmp/$TYPE
	mkdir -p /tmp/es_data/$TYPE

	sh $filename > /tmp/es_data_tmp/$TYPE/$filename
	
	java -jar json-resolver.jar /tmp/es_data_tmp/$TYPE/$filename /tmp/es_data/$TYPE/$filename $TYPE

	rm $filename
	rm ${TYPE}_tmp.temp

	echo "[`date`] sleep 600"
	sleep 600
done

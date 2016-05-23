#set -e
for i in ~/airways/scans/landmarks/*.csv
do
	bn=$(basename --suffix=.csv "$i")
	for j in ~/airways/scans/segs/$bn*.stl
	do
		./cut-out-trachea.sh $j $i /tmp/$bn.stl /tmp/$bn-cl.dat
	done
done
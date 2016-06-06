#set -e
njobs=0
rm /home/anej001/airways/scans/tracheas/*.jld
~/src/julia-0.4/julia congeal-tracheas.jl
for i in /home/anej001/airways/scans/tracheas/*.jld
do
	bn=`basename --suffix=-cl.jld $i`;
	for j in /home/anej001/airways/scans/segs/simpl/$bn*.off
	do
		# first, align the ORIGINAL mesh to landmarks
		~/src/julia-0.4/julia align_to_landmarks.jl $j tmp.off /home/anej001/airways/scans/landmarks/$bn.csv

		# now, use mean trachea information to deform it
		#/tmp/$bn.off
		~/src/julia-0.4/julia deform-trachea.jl tmp.off $i  /tmp/$bn.off
		rm tmp.off

		# finally, use binvox to slice it up.
		./binvox /tmp/$bn.off -pb -t raw -d 768 -cb -bb -10 -120 -170   10 -30 5 &
		sleep 1
		njobs=$((njobs+1))

		if [ "$njobs" -eq 4 ]
		then
			wait
			njobs=0
		fi
	done
done
~/src/julia-0.4/julia avgraw.jl 768 ~/*.raw
rm /tmp/*.raw
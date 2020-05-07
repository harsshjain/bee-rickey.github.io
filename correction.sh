#curl "https://docs.google.com/spreadsheets/d/e/2PACX-1vQW1sf6ptHC1I4vLmEI6kddb_2C1T3x4062y7NFn8s_G0rq0_c7RvtHcRDpohA8hkNQxIFRy6H4OIdJ/pub?gid=1857317333&single=true&output=csv"  | grep -v "^," > siva.csv
#curl https://api.covid19india.org/csv/latest/district_wise.csv > districtwise.csv
#curl https://api.covid19india.org/csv/latest/raw_data.csv > rawdata.csv
#curl https://api.covid19india.org/csv/latest/raw_data3.csv > rawdata3.csv

>matching.txt
>notMatching.txt
>notMatching.html
> notfound.txt

echo "<html> " >> notMatching.html
echo "	<body> " >> notMatching.html

while read line
do
	district=`echo $line | awk -F, '{print $2}'`
	state=`echo $line | awk -F, '{print $1}'`
	districtFound=0
	echo $state

	grep -i "$state" districtwise.csv | while read -r matched; do 
		if [ -n "${district}" ]
		then
			districtNameFromDistrictWise=`echo $matched | awk -F, '{print $5}'`
			if [ "$districtNameFromDistrictWise" == "$district" ]
			then
				districtFound=1
				confirmedCountFromDistrictWise=`echo $matched | awk -F, '{print $6}'`
				confirmedCountFromSiva=`echo $line | awk -F, '{print $5}'`

                if [ $confirmedCountFromDistrictWise != $confirmedCountFromSiva ]
				then

					echo "<a href=\"#$district\"> $district count does not match $confirmedCountFromSiva:$confirmedCountFromDistrictWise </a><br>" >> notMatching.html
					echo "<h2 id=\"$district\">$district</h2>" >> notMatching.txt
	   				echo "<h3>RAW DATA V1</h3>:<br>" >> notMatching.txt
   					grep -i "$district" rawdata1.csv >> notMatching.txt
   					echo "<h3>RAW DATA V2</h3><br>:" >> notMatching.txt
   					grep -i "$district" rawdata2.csv >> notMatching.txt
   					echo "<h3>RAW DATA V3</h3><br>" >> notMatching.txt
   					grep -i "$district" rawdata3.csv >> notMatching.txt

				else
					echo "$district count does not match $confirmedCountFromSiva:$confirmedCountFromDistrictWise" >> matching.txt
				fi
			fi
		fi
	done

	if [ $districtFound -eq 0 ]
	then
		echo "$district Not found" >> notfound.txt
		echo "$line " >> notfound.txt
	fi


done < siva.csv

sed 's/$/ <br>/' notMatching.txt >> notMatching.html
echo "	</body> " >> notMatching.html
echo "</html> " >> notMatching.html

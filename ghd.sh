#!/bin/sh

########################################
# Schedule Optimizer 
# Version: 0.1
# Last Modified: 12/28/17
# Description: A shell script that uses public data from Tiger Grader and returns 3 "easiest" teachers/distributions
########################################

echo "Enter a departments(ex. CPSC): "

dept=$1

echo "Enter a class #(ex. 360): "

class=$2

echo "Optimizing $dept-$class...."

wget -q "http://clemson.urbad.net/courses/$dept/$class" -O dist.txt #Get course dist page

end="<h3>Detailed" 
end=$(grep -n $end dist.txt | cut -d : -f1) #find end of relevant data

sed -i ''"$end"',$d' dist.txt #cut off irrelavent data

grep --no-group-separator -A1 "/professors/" dist.txt > dist1.txt #Extract only professors and avg %A+B

#Text processing variables
profStart='">'
profEnd="</a>"
gradeStart="<td>"
gradeEnd="</td>"

counter=1
currProf="Error"
currGrade=0
fileLen=$(wc -l < dist1.txt)

#Ranking variables
prof1="Err1"
prof2="Err2"
prof3="Err3"
grade1=1
grade2=2
grade3=3

while [ $counter -lt $fileLen ];
do
    plus=$(($counter+1))

    currProf=$(cat dist1.txt | sed ''"$counter"'!d' | sed 's#^.*\('"$profStart"'.*'"$profEnd"'\).*$#\1#'| sed 's#^'"$profStart"'\(.*\)'"$profEnd"'$#\1#') #Extract Prof
   
    #echo $currProf

    currGrade=$(cat dist1.txt | sed ''"$plus"'!d' | sed 's#^'"$gradeStart"'\(.*\)'"$gradeEnd"'$#\1#') #Extract Grade

    #echo $currGrade

    # Check rankings
    if echo $currGrade $grade1 | awk '{exit !( $1 > $2)}';  then 
        prof1=$currProf
        grade1=$currGrade
    elif echo $currGrade $grade2 | awk '{exit !( $1 > $2)}'; then
        prof2=$currProf
        grade2=$currGrade
    elif echo $currGrade $grade3 | awk '{exit !( $1 > $2)}'; then
        prof3=$currProf
        grade3=$currGrade
    fi
    counter=$(($counter+2))
done
echo "Rank   Prof   %Avg-A+B"
echo "1. $prof1 $grade1"
echo "2. $prof2 $grade2"
echo "3. $prof3 $grade3"


rm dist*.txt



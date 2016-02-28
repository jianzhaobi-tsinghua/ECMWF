#!/bin/bash 
# This is a very simple example

monthnum=(31 28 31 30 31 30 31 31 30 31 30 31)
year=2011

for((i=1;i<=12;i++))
do
    if [ $i -lt 10 ]
    then
        month=0${i}
    else
        month=${i}
    fi

    for((j=1;j<=${monthnum[i-1]};j++))
    do
        if [ $j -lt 10 ]
        then
            date=${year}-${month}-0
        else
            date=${year}-${month}-
        fi
        str=${date}${j}
        echo $str
        python download.py $str
    done
done

exit 0

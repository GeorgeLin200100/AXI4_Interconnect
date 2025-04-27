#!/bin/bash 
for ((i=0; i<=3; i++))
do 
    for ((j=0; j<=63; j++))
    do 
        echo "test.DUT.sdpram_i1.sdpram_i1.mem_array\\[$i\\]\\[$j\\]"
    done 
done
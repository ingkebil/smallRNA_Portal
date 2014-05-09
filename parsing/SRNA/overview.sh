#!/bin/sh

# gets all the web generated CSV files and renames properly

for i in 1 2 3 4 5 6 7 8 9 10;
do
    wget http://gent/smallrna/abundancies/overview/limit:100000000/$i.csv
done 

mv 1.csv DFN.csv  
mv 2.csv P.csv    
mv 3.csv P+3h.csv 
mv 4.csv N.csv    
mv 5.csv N+3h.csv 
mv 6.csv FN.csv   
mv 7.csv FN2.csv  
mv 8.csv C2.csv   
mv 9.csv C3o3.csv 
mv 10.csv C3h3.csv

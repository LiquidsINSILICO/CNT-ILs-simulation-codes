#!/bin/bash

ls -lstr umbrella*.tpr > tpr-files.dat
awk '{print $NF}' tpr-files.dat > tpr-files-clean.dat
sort -V < tpr-files-clean.dat > tpr-files.dat-sorted
mv tpr-files.dat-sorted tpr-files.dat
cp tpr-files.dat pullf-files.dat
sed 's/\.tpr$/_pullf.xvg/' tpr-files.dat > pullf-files.dat
rm tpr-files-clean.dat

#====================================================================================#
# Run Command 
#--> bash check-convergence.sh
#--> gmx wham -it tpr-files.dat -if pullf-files.dat -o -hist -unit kCal
#--> ls -lstr
#------------------------------------------------------------------------------------#
# You'll generate two files namely "histo.xvg" and "profile.xvg"
#====================================================================================#

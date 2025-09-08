#!/bin/bash

ls -lstr umbrella*.tpr > tpr-files.dat
awk '{print $NF}' tpr-files.dat > tpr-files-clean.dat
sort -V < tpr-files-clean.dat > tpr-files.dat-sorted
mv tpr-files.dat-sorted tpr-files.dat
cp tpr-files.dat pullf-files.dat
sed 's/\.tpr$/_pullf.xvg/' tpr-files.dat > pullf-files.dat
rm tpr-files-clean.dat

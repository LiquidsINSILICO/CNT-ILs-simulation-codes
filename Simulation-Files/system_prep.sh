#!/bin/bash
# !!-==============================================================-!!

gmx editconf -f single-cnt_6-6_3nm.pdb -o single-cnt_6-6_3nm.gro
gmx x2top -f CNT*.gro -o topol_CNT*.top -ff opls_aa -name CNT* -noparam

sed -i~ '/\[ dihedrals \]/,/\[ system \]/s/1 *$/3/' topol_CNT*.top

# !!-==============================================================-!!
# A box was generated keeping 1nm apart from images of itself.
# !!-==============================================================-!!

command :gmx editconf -f cnt_6-6_5nm_2.gro -o cnts_newbox.gro -c -d 1.0 -bt cubic

# !!-==============================================================-!!
# First I found the center of CNT inside pbc box using vmd.
# !!-==============================================================-!!
# Values : 3.76025 3.76037 3.75975 (in nm)

# !!-==============================================================-!!
# I want to pull at distance greater than 5 nm hence box dimension was extended in the x direction to 15 nm.
# !!-==============================================================-!!

command : gmx editconf -f cnts_newbox.gro -o newbox.gro -center 3.76 3.76 3.76 -box 15.0 7.5 7.5

gmx make_ndx -f newbox.gro -o index.ndx

# !!-==============================================================-!!
# To generate position restraint file for simulations
# !!-==============================================================-!!
gmx genrestr -f newbox.gro -n index.ndx -o posre_CNT*.itp -fc 1000 1000 1000

gmx grompp -f ../mdp/minim.mdp -c newbox.gro -r newbox.gro -o min -pp min -po min
gmx mdrun -v -deffnm min
gmx energy -f min.edr -o potential.xvg << EOF
Potential
EOF
gmx grompp -f mdp/nvt.mdp -r min.gro -c min.gro -o eql -pp eql -po eql -n index.ndx
gmx mdrun -v -deffnm eql

# !!-===============================================================-!!
# keeping the COM and dimension in other two (y & z) direction same. 
# !!-===============================================================-!!

gmx grompp -f mdp/md_pull.mdp -c eql.gro -p topol.top -r eql.gro -n index.ndx -t eql.cpt -o pull.tpr
mv mdout.mdp pull.mdp
gmx mdrun -v -deffnm pull -pf pullf.xvg -px pullx.xvg

gmx grompp -f mdp/interaction-energy.mdp -c eql.gro -t eql.cpt -p topol.top -n index.ndx -o ie.tpr
mv mdout.mdp ie.mdp
gmx mdrun -v -deffnm ie -rerun 1000KJ-mol-nm2/pull.trr -nb cpu
gmx energy -f ie.edr -o interaction_energy.xvg
xmgrace -block interaction_energy.xvg -bxy 1:3
mv ie.* 1000KJ-mol-nm2/
cd 1000KJ-mol-nm2/
mkdir analysis
mv ./../interaction_energy.xvg ./analysis
mkdir confgro
gmx trjconv -s pull.tpr -f pull.xtc -o confgro/conf.gro -sep

or type
bash get_distance.sh

# !!-==============================================================-!!

# :%s/\n/ /  to convert column into row in vim-editor
# :.s/ /Ctrl+vEnter/gEnter: On the current line (.), substitute (s) spaces (/ /) with a space followed by a carriage return (SpaceCtrl+vEnter/), in all positions (g). The cursor should now be on the last letter's line (e in the example).                   to convert row to column in vim-editor

# !!-==============================================================-!!

yes | python ./../setupUmbrella.py confgro/summary_distances.dat 0.1 run-umbrella.sh &> distance-0.1.txt

# !!-===============================================================-!!
# transfer the files using the bash script copy-files.sh
# check the file path and the name of files you want to transfer
# !!-===============================================================-!!

# !!-===============================================================-!!
# create pullf-files.dat and tpr-files.dat files after U-sampling Simulation is finished
ls -l umbrella*_pullf.xvg > pullf-files.dat
ls -l umbrella*.tpr > tpr-files.dat 
# !!-===============================================================-!!

# !!-===============================================================-!!
# open and delete the unneccessary information in visual mode
# !!-===============================================================-!!

gmx wham -it tpr-files.dat -if pullf-files.dat -o -hist -unit kCal

# !!-===============================================================-!!

awk '/^[0-9]/{print $2}' pullf.xvg > forces.txt
awk '/^[0-9]/{print $2}' pullx.xvg > distance.txt
paste distance.txt forces.txt > force-vs-dist.dat

# !!-===============================================================-!!
comm -12 <(sed 's/[^0-9]*//g' 1.dat) 2.dat
# !!-===============================================================-!!
sort -n 1.dat > sorted-1.dat #! This will sort the number in numeric order
# !!-===============================================================-!!
# This is Vim script command which helps to generate a list of numbers from 1-500
 :for i in range(1,500) | put =''.i | endfor
# !!-===============================================================-!!
# This command output the sequence of numbers missing in sorted-1.dat as compared to a full sequence 1-500.dat
 diff --new-line-format="" --unchanged-line-format="" 1-500.dat sorted-1.dat > missing-numbers.dat
# !!-===============================================================-!! 

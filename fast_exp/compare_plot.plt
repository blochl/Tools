#!/usr/bin/gnuplot

set terminal pngcairo size 525,786 enhanced font 'Verdana,10'
set output 'compare.png'

set multiplot layout 2,1
set lmargin at screen 0.13

set title "Compare"
set key left

plot 'tmpdat.dat' u 1:2 w l t 'actual', \
     '' u 1:3 w l t 'approx.', \
     '' u 1:4 w l t 'diff.'

set title "Log compare"
set log y
set yrange [0.0001:]

plot 'tmpdat.dat' u 1:2 w l t 'actual', \
     '' u 1:3 w l t 'approx.', \
     '' u 1:(abs($4)) w l t 'abs(diff.)'

unset multiplot

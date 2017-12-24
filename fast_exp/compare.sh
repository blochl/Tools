#!/bin/bash

for i in `seq -5.0 0.001 0.0`
do
    ./exp $i
done > tmpdat.dat

gnuplot compare_plot.plt

display "$(dirname $0)/compare.png"

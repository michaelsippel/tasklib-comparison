#!/bin/sh

n_tasks=100
n_threads=4

array_avg() {
    awk '{sum = 0; for(i=1;i<=NF;i++) { sum += $i } } END { print sum/NF }'
}

array_min() {
    awk '{min = $1; for(i=1;i<=NF;i++) { if($i < min) { min = $i } } } END { print min }'
}

array_max() {
    awk '{max = $1; for(i=1;i<=NF;i++) { if($i > max) { max = $i } } } END { print max }'
}

gen_data() {
    tasksize=1
    while [ $tasksize -le 4096 ]
    do
	delay=$(( tasksize * 1000 ))

	echo $1 $n_tasks $delay 1>&2

	data=$($1 $n_tasks $delay | grep -Po 'total=\[ \K[0-9 ]*')
	ideal=$(bc -l <<< "$n_tasks*$delay/$n_threads")
	avg=$(bc -l <<< "$ideal / $(echo $data | array_avg)")
	min=$(bc -l <<< "$ideal / $(echo $data | array_min)")
	max=$(bc -l <<< "$ideal / $(echo $data | array_max)")

	echo $tasksize $avg $min $max

	tasksize=$((tasksize * 2))
    done
}

make_plot() {
    gen_data ./bin/redgrapes >| rgdata
    gen_data ./bin/superglue >| sgdata
    gen_data ./bin/quark     >| qkdata

    gnuplot -p \
       -e "set title \"$n_tasks independent tasks on $n_threads threads\"" \
       -e 'set xlabel "Task size (cycles*10^3)"' \
       -e 'set ylabel "Efficiency"' \
       -e 'set key right bottom' \
       -e 'set grid' \
       -e 'set logscale x 2' \
       -e 'set yrange[0:1]' \
       -e 'plot "rgdata" using 1:2:3:4 title "RedGrapes" with yerrorlines,
                "sgdata" using 1:2:3:4 title "SuperGlue" with yerrorlines,
                "qkdata" using 1:2:3:4 title "Quark" with yerrorlines'
}


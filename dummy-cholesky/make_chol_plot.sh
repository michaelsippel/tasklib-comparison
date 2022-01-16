#!/bin/sh

delay=1000000
n_threads=4

array_avg() {
    awk '{sum = 0; for(i=1;i<=NF;i++) { sum += $i } } END { printf "%d", sum/NF }'
}

array_min() {
    awk '{min = $1; for(i=1;i<=NF;i++) { if($i < min) { min = $i } } } END { printf "%d", min }'
}

array_max() {
    awk '{max = $1; for(i=1;i<=NF;i++) { if($i > max) { max = $i } } } END { printf "%d", max }'
}

gen_data() {
    dim=1
    while [ $dim -le 16 ]
    do
	n_tasks=1

	echo $1 $dim $delay 1>&2

	data=$($1 $dim $delay | grep -Po 'total=\[ \K[0-9 ]*')
	#echo $dim $(echo $data | array_avg)
	#serial=$(bc -l <<< "$n_tasks*$delay")
	avg=$(echo $data | array_avg)
	min=$(echo $data | array_min)
	max=$(echo $data | array_max)

	echo $dim $avg $min $max

	dim=$((dim + 1))
    done
}

make_plot() {
    gen_data ./bin/redgrapes >| rgdata
    gen_data ./bin/superglue >| sgdata
    #gen_data ./bin/quark     >| qkdata

    gnuplot -p \
       -e "set title \"cholesky factorization on $n_threads threads, $delay cycles delay\"" \
       -e 'set xlabel "number of tiles"' \
       -e 'set ylabel "cycles"' \
       -e 'set key right bottom' \
       -e 'set grid' \
       -e 'plot "rgdata" using 1:2:3:4 title "RedGrapes" with yerrorlines,
                "sgdata" using 1:2:3:4 title "SuperGlue" with yerrorlines'
#                "qkdata" using 1:2:3:4 title "Quark" with yerrorlines'
}





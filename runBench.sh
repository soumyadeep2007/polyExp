#!/usr/bin/env bash
runBenchmark() {
	BENCHMARK=$1
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~$BENCHMARK~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> report 2>&1
	echo "Individual options----------------------------------------------" >> report 2>&1
	optionsArray=( "-bb-vectorize" "-gvn" "-licm" "-loop-reduce" "-loop-rotate" "-loop-unroll" "-mem2reg" )
	for option in "${optionsArray[@]}"
	do
		run "$option" -DSTANDARD_DATASET "$BENCHMARK"
		run "$option" -DLARGE_DATASET "$BENCHMARK"
	done

	echo "Combo options---------------------------------------------------" >> report 2>&1
	optionsArray=( \
		"-bb-vectorize -gvn -licm -indvars -loop-unroll -mem2reg" \
		"-bb-vectorize -indvars -loop-unroll" \
		"-bb-vectorize -mem2reg" \
		"-loop-unroll -mem2reg" \
		"-bb-vectorize -gvn -licm" \
		"-licm -loop-unroll" \
		"-licm -indvars -loop-unroll" \
		"-bb-vectorize -gvn -loop-rotate -loop-unroll" \
		 )
	for option in "${optionsArray[@]}"
	do
		run "$option" -DSTANDARD_DATASET "$BENCHMARK"
		run "$option" -DLARGE_DATASET "$BENCHMARK"
	done
}

run() { 
	OPT_OPTIONS=$1
	SIZE=$2
	BENCHMARK=$3
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> report 2>&1
	echo "Running with:::::::::::::::::::::::::::::::::::::::::::::::::::" >> report 2>&1
	echo $BENCHMARK $OPT_OPTIONS $SIZE >> report 2>&1
	clang -O0 -DPOLYBENCH_TIME $SIZE -save-temps -I . ../utilities/polybench.c "./$BENCHMARK.c" -o bench_temp.out -lm
	llvm-link $BENCHMARK.bc polybench.bc -o bench.bc
	opt $OPT_OPTIONS bench.bc -o bench-opt.bc >> report 2>&1
	clang bench-opt.bc -o bench.out -lm
	./time_benchmark.sh ./bench.out >> report 2>&1
	./cleanup.sh
	echo ">>>>>>>>>>>>>>>>>>>>>>>--X-->>>>>>>>>>>>>>>>>>>>>>>" >> report 2>&1
	echo >> report 2>&1
}

#Execution
runBenchmark "jacobi-2d"
runBenchmark "gramschmidt"
runBenchmark "gemm"
runBenchmark "correlation"
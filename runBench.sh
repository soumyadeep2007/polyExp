#!/usr/bin/env bash
runBenchmarkFineGrained() {
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
		"-loop-rotate -loop-unroll" \
		"-licm -indvars -loop-unroll" \
		"-bb-vectorize -gvn -loop-rotate -loop-unroll" \
		"-loop-rotate -loop-unroll" \
		"-gvn -loop-rotate -loop-unroll" \
		"-bb-vectorize -gvn -loop-rotate" \
		 )
	for option in "${optionsArray[@]}"
	do
		run "$option" -DSTANDARD_DATASET "$BENCHMARK"
		run "$option" -DLARGE_DATASET "$BENCHMARK"
	done
}

runBenchmarkCoarseGrained() {
	FLAG=$1
	SIZE=$2
	BENCHMARK=$3
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> report 2>&1
	echo "Running with:::::::::::::::::::::::::::::::::::::::::::::::::::" >> report 2>&1
	echo $BENCHMARK $FLAG $SIZE >> report 2>&1
	clang $FLAG -DPOLYBENCH_TIME $SIZE -I . ../utilities/polybench.c "./$BENCHMARK.c" -o bench.out -lm
	./time_benchmark.sh ./bench.out >> report 2>&1
	./cleanup.sh
	echo ">>>>>>>>>>>>>>>>>>>>>>>--X-->>>>>>>>>>>>>>>>>>>>>>>" >> report 2>&1
	echo >> report 2>&1
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

Execution
runBenchmarkFineGrained "jacobi-2d"
runBenchmarkFineGrained "gramschmidt"
runBenchmarkFineGrained "gemm"
runBenchmarkFineGrained "correlation"

runBenchmarkCoarseGrained "-O0" "-DSTANDARD_DATASET" "jacobi-2d"
runBenchmarkCoarseGrained "-O0" "-DLARGE_DATASET" "jacobi-2d"
runBenchmarkCoarseGrained "-O3" "-DSTANDARD_DATASET" "jacobi-2d"
runBenchmarkCoarseGrained "-O3" "-DLARGE_DATASET" "jacobi-2d"
runBenchmarkCoarseGrained "-O0" "-DSTANDARD_DATASET" "gramschmidt"
runBenchmarkCoarseGrained "-O0" "-DLARGE_DATASET" "gramschmidt"
runBenchmarkCoarseGrained "-O3" "-DSTANDARD_DATASET" "gramschmidt"
runBenchmarkCoarseGrained "-O3" "-DLARGE_DATASET" "gramschmidt"
runBenchmarkCoarseGrained "-O0" "-DSTANDARD_DATASET" "gemm"
runBenchmarkCoarseGrained "-O0" "-DLARGE_DATASET" "gemm"
runBenchmarkCoarseGrained "-O3" "-DSTANDARD_DATASET" "gemm"
runBenchmarkCoarseGrained "-O3" "-DLARGE_DATASET" "gemm"
runBenchmarkCoarseGrained "-O0" "-DSTANDARD_DATASET" "correlation"
runBenchmarkCoarseGrained "-O0" "-DLARGE_DATASET" "correlation"
runBenchmarkCoarseGrained "-O3" "-DSTANDARD_DATASET" "correlation"
runBenchmarkCoarseGrained "-O3" "-DLARGE_DATASET" "correlation"


runBenchmarkCoarseGrained "-O3" "-DEXTRALARGE_DATASET" "jacobi-2d"
runBenchmarkCoarseGrained "-O3" "-DEXTRALARGE_DATASET" "gramschmidt"
runBenchmarkCoarseGrained "-O3" "-DEXTRALARGE_DATASET" "gemm"
runBenchmarkCoarseGrained "-O3" "-DEXTRALARGE_DATASET" "correlation"
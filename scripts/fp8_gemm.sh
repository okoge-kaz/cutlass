#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p gemm_datatypes

# Define arrays for M, N, K values
M_VALUES=(4096 8192 16384 32768)
N_VALUES=(2048 4096 8192 14336 16384)
K_VALUES=(2048 4096 8192 14336 16384)

# Define runtime input datatypes to test
DATATYPES=("e4m3" "e5m2")

# Total number of combinations to run
TOTAL=$((${#M_VALUES[@]} * ${#N_VALUES[@]} * ${#K_VALUES[@]} * ${#DATATYPES[@]}))
CURRENT=0

echo "Starting CUTLASS profiler benchmark with $TOTAL combinations..."

# Loop through all combinations of M, N, K, and datatypes
for datatype in "${DATATYPES[@]}"; do
    for m in "${M_VALUES[@]}"; do
        for n in "${N_VALUES[@]}"; do
            for k in "${K_VALUES[@]}"; do
                # Increment counter and display progress
                CURRENT=$((CURRENT + 1))
                echo "[$CURRENT/$TOTAL] Running benchmark with M=$m, N=$n, K=$k, Datatype=$datatype"

                # Define output file name
                OUTPUT_FILE="gemm_datatypes/m_${m}-k_${k}-n_${n}-datatype_${datatype}.csv"

                # Run the profiler with current parameters
                ./tools/profiler/cutlass_profiler \
                    --operation=gemm \
                    --m=$m \
                    --n=$n \
                    --k=$k \
                    --A=bf16:column \
                    --B=bf16:column \
                    --C=bf16:column \
                    --runtime_input_datatype_a=$datatype \
                    --runtime_input_datatype_b=$datatype \
                    --alpha=1.0 \
                    --beta=0.0 \
                    --providers=cutlass \
                    --kernels=tensorop \
                    --profiling-iterations=20 \
                    --output="$OUTPUT_FILE"

                # Check if the command executed successfully
                if [ $? -eq 0 ]; then
                    echo "  ✓ Successfully saved results to $OUTPUT_FILE"
                else
                    echo "  ✗ Error running benchmark for M=$m, N=$n, K=$k, Datatype=$datatype"
                fi

                # Add a small delay between runs to prevent system overload
                sleep 1
            done
        done
    done
done

echo "All benchmarks completed. Results saved in the 'gemm_datatypes' directory."

#!/bin/bash

module load cuda/12.8
module load cudnn/9.8.0.87_cuda12
module load nccl/2.26.2-1-cuda-12.8.1
module load openmpi/v4.1.x

export CUDACXX="/opt/share/modules/cuda/12.8.1/bin/nvcc"

mkdir build && cd build

# https://github.com/NVIDIA/cutlass?tab=readme-ov-file#target-architecture
# https://github.com/NVIDIA/cutlass/blob/main/media/docs/cpp/profiler.md
cmake .. -DCUTLASS_NVCC_ARCHS=90a # Hopper
cmake .. -DCUTLASS_NVCC_ARCHS="100a"  # Blackwell

# check the number of cpu core
lscpu

# build cutlass profiler
# if you set job number very small, it will be very slow and take a long time
make cutlass_profiler -j124

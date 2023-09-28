#!/bin/bash
# File:           install_tools.sh
# Last changed:   28/09/2023 16:19
# Purpose:        Install system dependencies for processes_logistic_optimization codes.         
# Usage: 
#    HowToExecute:   ./install_tools.sh  

set -e

echo "Installing python and pip3..."
sudo apt install python3 python3-pip

#---------------------------------------------------#
JULIA_VERSION="1.6.7" # any version ≥ 0.7.0
JULIA_PACKAGES="IJulia BenchmarkTools"
JULIA_PACKAGES_IF_GPU="CUDA" # or CuArrays for older Julia versions
JULIA_NUM_THREADS=2
#---------------------------------------------------#

# Install Jupyter Notebook
echo "Installing Jupyter Notebook..."
pip install jupyter

# Install Julia
JULIA_VER=`cut -d '.' -f -2 <<< "$JULIA_VERSION"`
echo "Installing Julia $JULIA_VERSION..."
BASE_URL="https://julialang-s3.julialang.org/bin/linux/x64"
URL="$BASE_URL/$JULIA_VER/julia-$JULIA_VERSION-linux-x86_64.tar.gz"
wget -nv $URL -O /tmp/julia.tar.gz # -nv means "not verbose"
tar -x -f /tmp/julia.tar.gz -C /usr/local --strip-components 1
rm /tmp/julia.tar.gz

for PKG in `echo $JULIA_PACKAGES`; do
echo "Installing Julia package $PKG..."
julia -e 'using Pkg; pkg"add '$PKG'; precompile;"' &> /dev/null
done

# Install kernel and rename it to "julia"
echo "Installing IJulia kernel..."
julia -e 'using IJulia; IJulia.installkernel("julia", env=Dict(
    "JULIA_NUM_THREADS"=>"'"$JULIA_NUM_THREADS"'"))'
KERNEL_DIR=`julia -e "using IJulia; print(IJulia.kerneldir())"`
KERNEL_NAME=`ls -d "$KERNEL_DIR"/julia*`
mv -f $KERNEL_NAME "$KERNEL_DIR"/julia

echo ''
echo "Julia `julia -v` instalado com sucesso!"
echo "vá para a seção 'Verificação da Instalação'."

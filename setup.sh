#!/bin/bash
# Copyright (c) 2022 Graphcore Ltd. All rights reserved.
# Script to be sourced on launch of the Gradient Notebook

# gc-reset

symlink_public_resources() {
    public_source_dir=${1}
    target_dir=${2}
    echo "Symlinking - ${public_source_dir} to ${target_dir}"

    # Make sure it exists otherwise you'll copy your current dir
    mkdir -p ${public_source_dir}
    cd ${public_source_dir}
    find -type d -exec mkdir -p "${target_dir}/{}" \;
    find -type f -not -name "*.lock" -exec cp -sP "${PWD}/{}" "${target_dir}/{}" \;
    cd -
}

copy_public_resources() {
    public_source_dir=${1}
    target_dir=${2}
    echo "Copying - ${public_source_dir} to ${target_dir}"

    # Make sure it exists otherwise you'll copy your current dir
    mkdir -p ${public_source_dir}
    cd ${public_source_dir}
    find -type d -exec mkdir -p "${target_dir}/{}" \;
    find -type f -exec rm -f "${target_dir}/{}" \;
    find -type f -not -name "*.lock" -exec cp "${PWD}/{}" "${target_dir}/{}" \;
    cd -
}


#  Discover system sizes
export NUM_AVAILABLE_IPU=4
export GRAPHCORE_POD_TYPE="pod4"
# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# source "${SCRIPT_DIR}/pod-config.sh" # don't need this as we're setting the env vars explicitly above

# Cache directories
export POPLAR_EXECUTABLE_CACHE_DIR="/tmp/exe_cache"
export DATASET_DIR="/tmp/datasets"
export CHECKPOINT_DIR="/tmp/checkpoints"

# Paperspace Datasets are mounted in the /datasets directory (includes poplar executables)
# symlink the poplar executables
poplar_executables_source_dir="/datasets/poplar-executables-tf2"
symlink_public_resources $poplar_executables_source_dir $POPLAR_EXECUTABLE_CACHE_DIR &

# symlink mounted datasets
for dataset in /datasets/*; do
    # don't symlink the poplar executables, that's handled above
    test "$dataset" = "$poplar_executables_source_dir" && continue
    # symlink the actual datasets
    symlink_public_resources $dataset $DATASET_DIR &
done

# Set framework specific variables
export TF_POPLAR_FLAGS='--executable_cache_path='${POPLAR_EXECUTABLE_CACHE_DIR}''

# Environment variables customised for OGB notebooks
export OGB_DATASET_DIR="${DATASET_DIR}/ogb_lsc_pcqm4mv2/datasets"
export OGB_CHECKPOINT_DIR="${CHECKPOINT_DIR}/ogb_lsc_pcqm4mv2/checkpoints"
export OGB_SUBMISSION_CODE="./pcqm4mv2_submission"

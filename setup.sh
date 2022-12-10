#!/bin/bash
# Copyright (c) 2022 Graphcore Ltd. All rights reserved.
# Script to be sourced on launch of the Gradient Notebook

# called from root folder in container
symlink-public-resources() {
    public_source_dir=${1}
    target_dir=${2}
    echo "Symlinking - ${public_source_dir} to ${target_dir}"

    # Make sure it exists otherwise you'll copy your current dir
    mkdir -p ${public_source_dir}
    cd ${public_source_dir}
    find -type d -exec mkdir -p "${target_dir}/{}" \;
    #find -type f -not -name "*.lock" -exec cp -sP "${PWD}/{}" "${target_dir}/{}" \;
    find -type f -not -name "*.lock" -print0 | xargs -0 -P 50 -I {} sh -c "cp -sP \"${PWD}/{}\" \"${target_dir}/{}\""
    cd -
}

DETECTED_NUMBER_OF_IPUS="4"

IPU_ARG=${1:-"${DETECTED_NUMBER_OF_IPUS}"}

export NUM_AVAILABLE_IPU=${IPU_ARG}
export GRAPHCORE_POD_TYPE="pod${IPU_ARG}"
export POPLAR_EXECUTABLE_CACHE_DIR="/tmp/exe_cache"
export DATASET_DIR="/tmp/dataset_cache"
export CHECKPOINT_DIR="/tmp/checkpoints"


# mounted public dataset directory (path in the container)
# in the Paperspace environment this would be ="/datasets"
export PUBLIC_DATASET_DIR="/datasets"

export TF_POPLAR_FLAGS='--executable_cache_path='${POPLAR_EXECUTABLE_CACHE_DIR}''

# Environment variables customised for OGB notebooks
export OGB_DATASET_DIR="${DATASET_DIR}/ogb_lsc_pcqm4mv2/datasets"
export OGB_CHECKPOINT_DIR="${CHECKPOINT_DIR}/ogb_lsc_pcqm4mv2/checkpoints"
export OGB_SUBMISSION_CODE="./pcqm4mv2_submission"

make_ogb_custom_ops(){
    python -m pip install -r /notebooks/ogb-competition/requirements.txt
    cd "/notebooks/ogb-competition/${OGB_SUBMISSION_CODE}"
    make -C data_utils/feature_generation
    make -C static_ops
    cd -
}

prepare_tf2_datasets(){
    # symlink exe_cache files
    symlink-public-resources "${PUBLIC_DATASET_DIR}/exe_cache" $POPLAR_EXECUTABLE_CACHE_DIR
    # symlink ogbn_arxiv dataset for cluster gcn notebook
    symlink-public-resources "${PUBLIC_DATASET_DIR}/datasets/ogbn_arxiv" "${DATASET_DIR}/ogbn_arxiv"
    # symlink OGB-specific folders
    symlink-public-resources "${PUBLIC_DATASET_DIR}/datasets/ogb_lsc_pcqm4mv2/datasets" "${OGB_DATASET_DIR}"
    symlink-public-resources "${PUBLIC_DATASET_DIR}/datasets/ogb_lsc_pcqm4mv2/checkpoints" "${OGB_CHECKPOINT_DIR}"
    make_ogb_custom_ops
}

nohup prepare_datasets & tail -f nohup.out &

#!/bin/bash

symlink-public-resources() {
    public_source_dir=${1}
    target_dir=${2}

    # need to wait until the dataset has been mounted (async on Paperspace's end)
    while [ ! -d ${public_source_dir} ]
    do
        echo "Waiting for dataset "${public_source_dir}" to be mounted..."
        sleep 1
    done

    echo "Symlinking - ${public_source_dir} to ${target_dir}"

    # Make sure it exists otherwise you'll copy your current dir
    mkdir -p ${public_source_dir}
    cd ${public_source_dir}
    find -type d -exec mkdir -p "${target_dir}/{}" \;
    #find -type f -not -name "*.lock" -exec cp -sP "${PWD}/{}" "${target_dir}/{}" \;
    find -type f -not -name "*.lock" -print0 | xargs -0 -P 50 -I {} sh -c "cp -sP \"${PWD}/{}\" \"${target_dir}/{}\""
    cd -
}

echo "Starting preparation of datasets"

# symlink exe_cache files
symlink-public-resources "${PUBLIC_DATASET_DIR}/poplar-executables-tf2" $POPLAR_EXECUTABLE_CACHE_DIR
# symlink ogbn_arxiv dataset for cluster gcn notebook
symlink-public-resources "${PUBLIC_DATASET_DIR}/ogbn-arxiv" "${DATASET_DIR}/ogbn_arxiv"
# symlink OGB-specific folders
symlink-public-resources "${PUBLIC_DATASET_DIR}/ogb_lsc_pcqm4mv2/datasets" "${OGB_DATASET_DIR}"
symlink-public-resources "${PUBLIC_DATASET_DIR}/ogb_lsc_pcqm4mv2/checkpoints" "${OGB_CHECKPOINT_DIR}"

# Make the custom ops for the OGB notebooks
python -m pip install -r /notebooks/ogb-competition/requirements.txt
cd "/notebooks/ogb-competition/${OGB_SUBMISSION_CODE}"
make -C data_utils/feature_generation
make -C static_ops
cd -


echo "Finished running setup.sh."
# Run automated test if specified
if [[ "$1" == "test" ]]; then
    #source .gradient/automated-test.sh "${@:2}"
    bash /notebooks/.gradient/automated-test.sh $2 $3 $4 $5 $6 $7 $8
elif [[ "$2" == "test" ]]; then
    #source .gradient/automated-test.sh "${@:2}"
    bash /notebooks/.gradient/automated-test.sh $3 $4 $5 $6 $7 $8 $9
fi

#!/usr/bin/env bash

instance_name="GOMAP"
img_loc="$PWD/$instance_name.simg"
mkdir -p $PWD/tmp
unset SINGULARITY_TMPDIR

if [ ! -f "$img_loc" ]
then
    echo "The GOMAP image is missing" > /dev/stderr
    echo "Please run the setup.sh before running the test" > /dev/stderr
    exit 1
fi

if [ -z $tmpdir ]
then
    tmpdir=${TMPDIR:-$PWD/tmp}
fi

export SINGULARITY_BINDPATH="GOMAP:/opt/GOMAP/,$PWD:/workdir,$tmpdir:/tmpdir"

echo "$@"

if [[ $# -eq 1 ]] 
then
	singularity run \
		-W $PWD/tmp \
		$img_loc \
		--step=$1 --config=test/config.yml
else
	singularity run $img_loc --step=seqsim --config=test/config.yml && \
	singularity run $img_loc --step=domain --config=test/config.yml && \
	singularity run $img_loc --step=fanngo --config=test/config.yml && \
	singularity run $img_loc --step=mixmeth-blast --config=test/config.yml && \
	singularity run $img_loc --step=mixmeth-preproc --config=test/config.yml && \
	singularity run $img_loc --step=mixmeth --config=test/config.yml && \
	singularity run $img_loc --step=aggregate --config=test/config.yml
fi
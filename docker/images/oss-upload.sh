#! /bin/bash

[[ $# -lt 2 ]] && echo "$0 <subdir> <files...>" && exit 1

CMD=""
if [[ ! -z "${OSS_ENDPOINT}" ]] && [[ ! -z "${OSS_ID}" ]] && [[ ! -z "${OSS_SECRET}" ]]; then
    CMD="ossutil64 -e ${OSS_ENDPOINT} -i ${OSS_ID} -k ${OSS_SECRET}"
elif [[ -f $HOME/.ossutilconfig ]]; then
    CMD="ossutil64"
elif [[ -f /run/secrets/ossutilconfig ]]; then
    CMD="ossutil64 -c /run/secrets/ossutilconfig"
else
    echo "Could not find valid oss authentication configure file."
    exit 1
fi
OSS_BASE=oss://nebula-graph
OSS_SUBDIR=$1
shift

for file in $@
do
    ${CMD} -f cp ${file} ${OSS_BASE}/${OSS_SUBDIR}/$(basename ${file})
done

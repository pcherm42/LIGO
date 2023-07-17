#!/bin/bash
echo ls $TMPDIR
ls $TMPDIR
source "${10}"/matlab/matlab_version_info.sh
#eval `/ligotools/sl6/bin/use_ligotools`
cd "${10}"/matlab/
pwd

matlabcommand="run('$1','$2','$3','$4','$5','$6','$7','$8','$9'); $qt"
echo "Matlab comamand is: " $matlabcommand
echo ./run $1 $2 $3 $4 $5 $6 $7 $8 $9

for i in 1 2 3 4 5; do
    ./run $1 $2 $3 $4 $5 $6 $7 $8 $9
    returncode=$?

    [[ $returncode -eq 0 ]] && break
done

echo "Exiting bash"
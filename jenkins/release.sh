#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/clean.sh
. $DIR/configure.sh
. $DIR/virtualenv.sh

if [[ "${PBR_RELEASE_TYPE}" == "" ]]
then 
  PBR_RELEASE_TYPE=patch
fi
if [[ "${PYPI_NAME}" == "" ]]
then 
  PYPI_NAME=pypi
fi

if [[ -e "./setup.py" ]]
then
  python setup.py tag --${PBR_RELEASE_TYPE} register -r ${PYPI_NAME} sdist bdist_egg bdist_wheel upload -r ${PYPI_NAME}
fi
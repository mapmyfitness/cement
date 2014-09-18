#!/bin/bash
venv_name=.virtualenv_release
virtualenv_activate=./${venv_name}/bin/activate

# Validate the virtualenv and activate it
if [[ ! -e $virtualenv_activate ]]
then
  virtualenv $venv_name
fi
. ${virtualenv_activate}

pip install wheel

if [[ "${RELEASE_TYPE}" == "" ]]
then 
  RELEASE_TYPE=patch
fi
if [[ "${PYPI_NAME}" == "" ]]
then 
  PYPI_NAME=mmfpypi
fi

if [[ -e "./setup.py" ]]
then
  python setup.py tag --${RELEASE_TYPE} register -r ${PYPI_NAME} sdist bdist_egg bdist_wheel upload -r ${PYPI_NAME}
fi
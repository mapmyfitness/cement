if [[ "${RELEASE_TYPE}" == "" ]]
then 
  RELEASE_TYPE=patch
fi
if [[ "${PYPI_NAME}" == "" ]]
then 
  PYPI_NAME=mmfpypi
fi

python setup.py tag --${RELEASE_TYPE} register -r ${PYPI_NAME} sdist bdist_wheel upload -r ${PYPI_NAME}
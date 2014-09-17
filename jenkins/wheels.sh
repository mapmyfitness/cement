#! /bin/bash


set +x
export PIP_CONFIG_FILE=~/.pip/pip-wheelbuilder.conf
venv_name=.virtualenv
virtualenv_activate=./${venv_name}/bin/activate

# Make sure we have the standard modules for working with packaging and virtualenvs
if ! venv_cmd="$(type -p "pip")" || [ -z "$venv_cmd" ]
then
  curl --silent --show-error --retry 5 https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python
fi

# Only try to install virtualenv if it isn't already installed
if ! venv_cmd="$(type -p "virtualenv")" || [ -z "$venv_cmd" ]
then
  pip install --upgrade virtualenv
fi

# Validate the virtualenv and activate it
if [[ ! -e $virtualenv_activate ]]
then
  virtualenv $venv_name
fi
. ${virtualenv_activate}


PIP_CONFIG_FILE=/dev/null pip install --index-url http://pypi.mapmyfitness.com/mmf/stable/+simple/ pip==1.5.4
PIP_CONFIG_FILE=/dev/null pip install --index-url http://pypi.mapmyfitness.com/mmf/stable/+simple/ setuptools==0.9.8
pip install wheel==0.22.0
pip install devpi==1.2.1

pip wheel --wheel-dir=wheelhouse/ -r dev-requirements.txt

echo "**> Working on the python libraries (not compiled binaries)"
echo "**> Signing into the devpi server so that we can upload"
devpi use http://pypi.mapmyfitness.com/mmf/platform-any/+simple/
devpi login mmf --password=Pc10XNfA16
echo "**> Uploading the wheels to our local devpi server: http://pypi.mapmyfitness.com"
find wheelhouse/ -name "*-none-any.whl" -exec devpi upload --formats bdist_wheel {} \;

echo "**> Working on the compiled binary pips"
echo "**> Signing into the devpi server so that we can upload"
devpi use http://pypi.mapmyfitness.com/mmf/$(facter | grep operatingsystem | grep -v operatingsystemmajrelease | sort | cut -d " " -f 3 | sed ':a;N;$!ba;s/\n/-/g')/+simple/
devpi login mmf --password=Pc10XNfA16
echo "**> Uploading the wheels to our local devpi server: http://pypi.mapmyfitness.com"
find wheelhouse/ -name "*.whl" -not -name "*-none-any*" -exec devpi upload --formats bdist_wheel {} \;

set -x
echo "Finished building the wheelhouse, now all builds on this server should be faster!"

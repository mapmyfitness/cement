#!/bin/bash
venv_name=.virtualenv
virtualenv_activate=./${venv_name}/bin/activate

# Validate the virtualenv and activate it
if [[ ! -e $virtualenv_activate ]]
then
  virtualenv $venv_name
fi
. ${virtualenv_activate}

if [[ -e "./setup.py" ]]
then
    python setup.py develop
fi

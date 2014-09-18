import sys
from setuptools import setup
from subprocess import call

try:
    from pbr import util
    setup(**util.cfg_to_args())
except ImportError:
    #If PBR isn't installed, then install it from the local egg and redo the python setup.py call
    call(['easy_install ./pbr-0.11.0.dev38.g0952dc0-py2.7.egg'], shell=True)
    call([' '.join(['python'] + sys.argv)], shell=True)




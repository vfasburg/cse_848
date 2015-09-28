Assuming 32 bit Python 2.7 already installed

you can check if you have 32 or 64 bit by typing:
>>python
>>import sys
>>sys.maxint

if it's 2 billion and change, you have 32 bit. If it's gigantic, you have 64 bit


install numpy and scipy:
go to http://www.lfd.uci.edu/~gohlke/pythonlibs/#scipy
find and download scipy-0.16.0-cp27-none-win32.whl
from same site, download numpy-1.10.0rc1+mkl-cp27-none-win32.whl
open a prompt to the spot you downloaded them at
type "pip install scipy-0.16.0-cp27-none-win32.whl" then
type "pip install numpy-1.10.0rc1+mkl-cp27-none-win32.whl"


install deap:
you can install using "pip install deap", but I did it the stupid way. 
1. Get deap source from https://pypi.python.org/pypi/deap
2. unpack the .gz and the inner .tar file using 7-zip. 
2. Go to the folder that has the setup.py file and type "python setup.py install"


#!/usr/bin/env python

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(name='libev',
      version='0.0.0',
      description='Python libev bindings made with cython',
      author='Jonathan Bastien-Filiatrault',
      author_email='joe@x2a.org',
      url='http://x2a.org/git/libev/',
      packages=['libev'],
      cmdclass = {'build_ext': build_ext},
      ext_package='libev',
      ext_modules = [Extension('libev',
                               ["libev/capi.pxd", "libev/loop.pyx"],
                               libraries=["ev"],
                               define_macros=[('EV_STANDALONE', '1'),
                                              ('EV_MULTIPLICITY', '1')])]
)

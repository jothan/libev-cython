#!/usr/bin/env python
# libev-cython: libev wrapper for Python
# Copyright (C) 2010  Jonathan Bastien-Filiatrault
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
      ext_modules = [Extension('_ev',
                               ["libev/capi.pxd", "libev/global.pyx"],
                               libraries=["ev"],
                               define_macros=[('EV_STANDALONE', '1'),
                                              ('EV_MULTIPLICITY', '1'),
                                              ('ev_lp', 'struct ev_loop')])]
)

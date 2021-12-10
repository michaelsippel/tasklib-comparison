#!/bin/sh

mkdir -p thirdparty
cd thirdparty
curl http://icl.cs.utk.edu/projectsfiles/quark/pubs/quark-0.9.0.tgz | tar xfz -
cd quark-0.9.0
make
prefix=install make install


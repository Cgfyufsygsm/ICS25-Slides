#!/bin/bash

REPO_NAME=$1

./apply.sh 00 $REPO_NAME
./apply.sh 01 $REPO_NAME

./update.sh $REPO_NAME

mkdir -p dist/
mv dist_tmp/* dist/
rm -rf dist_tmp
cp _redirects dist/
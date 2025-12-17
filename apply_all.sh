#!/bin/bash

REPO_NAME=$1

./apply.sh 00 $REPO_NAME
./apply.sh 01 $REPO_NAME
./apply.sh 02 $REPO_NAME
./apply.sh 03 $REPO_NAME
./apply.sh 04 $REPO_NAME
./apply.sh 05 $REPO_NAME
./apply.sh 06 $REPO_NAME
./apply.sh 07 $REPO_NAME
./apply.sh 08 $REPO_NAME
./apply.sh 09 $REPO_NAME
./apply.sh 10 $REPO_NAME

./update.sh $REPO_NAME

mkdir -p dist/
mv dist_tmp/* dist/
rm -rf dist_tmp
cp _redirects dist/
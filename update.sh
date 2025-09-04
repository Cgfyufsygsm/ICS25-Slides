#!/bin/bash

REPO_NAME=$1

cp ./pages/Index.md ./slides.md

npx slidev build --base /$REPO_NAME/

# 遍历 dist 目录，删除符合条件的文件夹
for dir in dist/[0-9]*
do
  if [ -d "$dir" ]; then
    rm -rf "$dir"
  fi
done
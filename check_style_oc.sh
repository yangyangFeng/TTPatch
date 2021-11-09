#!/bin/bash

for file in $(git status | grep -E "modified|new file" | awk -F ":" '{print $2}' | grep -E ".*\.h$|.*\.cpp$|.*\.hpp|.*\.m|.*\.mm")
do
    echo "format file: $file"
    clang-format -i $file
done


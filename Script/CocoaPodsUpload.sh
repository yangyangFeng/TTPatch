#!/bin/bash
source util.sh
cd ..
git tag "$1" 
show_result $? "tag:$1"
git push origin "$1" 
show_result $? "push"
pod trunk push ./TTPatch.podspec --allow-warnings
show_result $? "push CocoaPods $1"


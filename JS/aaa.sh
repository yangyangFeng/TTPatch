#!/bin/sh
echo '-------'
git add -A .
git commit -a -m $1
git pull
npm version patch
npm publish
git push --follow-tags




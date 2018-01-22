#!/usr/bin/env bash

# --------------------------------------------------------------------
# initialize the empty repo
# --------------------------------------------------------------------
git init
git remote add origin git@github.com:warren-bank/json-zip-code-distance-database.git

# --------------------------------------------------------------------
# push version 1.0.0 to 'master'
# --------------------------------------------------------------------
# to do: add files
git add --all .
git commit -m "v1.0.0"
git push -u origin master

git tag "v1.0.0"
git push --tags -u origin master

# --------------------------------------------------------------------
# push the uncompressed JSON data for version 1.0.0 to 'gh-pages'
# --------------------------------------------------------------------
git checkout --orphan "gh-pages"
git rm -rf .

# to do: add files
git add --all .
git commit -m "v1.0.0"
git push -u origin "gh-pages"

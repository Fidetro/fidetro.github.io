#!/bin/bash
jekyll build
git add *
git commit -m "${0}"
git push origin master

#!/bin/bash
jekyll serve
git add .
git commit -m $1
git push -u origin master
scp -r _site root@120.77.168.124:/home/www

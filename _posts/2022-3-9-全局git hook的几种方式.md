---
layout:     post
title:      "全局git hook的几种方式"
subtitle:   "git"
date:       2022-3-9
author:     "Karim"
header-img: "img/post-white-room.png"
tags:
- git
---


# 前言  
随着自己开发的个人项目越来越多，也给自己制定了一些git的规范，例如`git commit`提交日志的规范。  
因为我的个人项目都是放在GitHub上，我在给项目开发新需求的时候，会新建一个issue，GitHub会给这个issue，创建一个`#id`(不知道正确叫法是什么)，然后在开发新需求的时候，会把分支名称改成`#id`，这样就可以方便的跟踪项目后续问题回溯，同时还会在提交日志加上`#id`，类似这样的格式：  
```
#id-问题/功能描述
```  
这样的格式，可以在GitHub的页面直接跳转到对应的issue或者pull request，非常方便。  
但是每次都得手动加上`#id-`，这样会比较麻烦，所以我想到了用git-hooks，在提交日志的时候，自动加上`#id-`，这样就可以让我们不用手动加上`#id-`了。


# 正文  
关于git-hooks，我就不多说了，可以看看这里对git-hooks的[介绍](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90),如果只想把hook的规则单独使用在某个项目中，可以在项目的`.git/hooks`下创建hook脚本。  
如果想要在全局使用，有两种方式`init.templatedir`或者`core.hooksPath`。  

## init.templatedir  
这种方式会在你的项目`git init`的时候，自动创建一个hooks文件夹，然后把所有的hook脚本都放在这个文件夹下，如果是旧的项目就需要再次执行`git init`才会生效。  
```
#创建hooks文件夹
mkdir -p ~/.git-templates/hooks
#配置全局git templates
git config --global init.templatedir '~/.git-templates'  
#确保脚本可以执行
chmod a+x ~/.git-hooksPath/hooks/xxx
```
将hook的脚本放入`~/.git-templates/hooks`中即可。  

## core.hooksPath  
这种方式需要git的版本在2.9+以上才能正常使用，比第一种方式方便在旧项目不需要再次init就可以使用。
```shell
#创建hooks文件夹
mkdir -p ~/.git-hooksPath/hooks
#配置全局git hooksPath
git config --global core.hooksPath ~/.git-hooksPath/hooks  
#确保脚本可以执行
chmod a+x ~/.git-hooksPath/hooks/commit-msg
```
将hook的脚本放入`~/.git-hooksPath/hooks`中即可。  
实现上面的功能，可以参考下面的脚本：
```shell
#!/bin/sh
#
# An example hook script to check the commit log message.
# Called by "git commit" with one argument, the name of the file
# that has the commit message.  The hook should exit with non-zero
# status after issuing an appropriate message if it wants to stop the
# commit.  The hook is allowed to edit the commit message file.
#
# To enable this hook, rename this file to "commit-msg".

# Uncomment the below to add a Signed-off-by line to the message.
# Doing this in a hook is a bad idea in general, but the prepare-commit-msg
# hook is more suited to it.
#
# SOB=$(git var GIT_AUTHOR_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
# grep -qs "^$SOB" "$1" || echo "$SOB" >> "$1"

# This example catches duplicate Signed-off-by lines.

set -e
#获取当前分支
branch=$(git symbolic-ref --short HEAD)
message=$(cat $1)
commit_msg=$(cat $1)
changeCommitMsg() {    
    #根据#分割branch取最后一个
    sub_branch=${branch##*/}
	#如果有下划线，分割下划线前面
    if [[ $sub_branch == *"_"* ]];then
    	sub_branch=${sub_branch%%_*}
    fi

    
    result=$(echo $sub_branch | grep "#")
    if [[ "$result" == "" ]]; then
        sub_branch="#other"
    fi
    # echo $sub_branch
    #$sub_branch替换$message中的[branch]字符串
    commit_msg=${message//\[branch\]/$sub_branch}
    echo $commit_msg
}

if [[ $commit_msg =~ "[branch]" ]]; then
   newmsg=$(changeCommitMsg) 
   echo $newmsg
   echo "$newmsg" > "$1"
fi
```



如果有个别项目不需要使用全局的git hooks，可以在项目的根目录下重新配置git hooksPath，比如：
```
git config core.hooksPath .git/hooks 
```

# 参考  
[Applying a git post-commit hook to all current and future repositories](https://stackoverflow.com/questions/2293498/applying-a-git-post-commit-hook-to-all-current-and-future-repositories)   
[Git 钩子](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)
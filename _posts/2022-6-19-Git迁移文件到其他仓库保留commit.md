---
layout:     post
title:      "Git迁移文件到其他仓库保留commit"
subtitle:   "Git"
date:       2022-6-19
author:     "Karim"
header-img: "img/post-white-room.png"
tags:
- Git
---

在开发的过程中，往往存在架构上调整导致类需要迁移到其他的仓库，假设A仓库的目录如下：

```t
------------------
src/
    views/
        index.html
        ...
    models/
        index.js
        ...
    controllers/
        index.js
        ...
```

我们要将A仓库中models，迁移到B仓库，并保留A仓库的commit，这个时候需要用到`git filter-repo`,
macOS上的git并没有自带`filter-repo`，这时候需要用到homebrew安装：
```shell
brew install git-filter-repo
```

首先我们需要fork A仓库，因为`git-filter-repo`会只保留你迁移的文件，其他都会被移除。

```shell
#从fork_A仓库中执行下方的命令,folder_path为A仓库下保留的文件夹路径
fork_A % git filter-repo --path ${folder_path}/
#多目录可以这样使用
fork_A % git filter-repo --path ${folder_path_A}/ --path ${folder_path_B}/
```
- `--path` 会保留原来仓库目录下的文件
- `--invert-paths --path` 会删除path目录下的文件
- `--subdirectory-filter` 会仅保留根目录，同时将目录下所有文件都移动到根目录下

还有更多的参数可以参考[官方文档](https://github.com/newren/git-filter-repo/blob/main/Documentation/git-filter-repo.txt)，这里就不一一细说了。

执行上方命令后，会发现本地仓库，只剩下`${folder_path}`下的文件目录结构

然后去到我们要将`${folder_path}`文件下迁移到的B仓库目录下
```shell
#<repo_A_directory>为本地路径
B % git remote add from_repo_A <repo_A_directory>
B % git pull from_repo_A main --allow-unrelated-histories 
B % git remote rm from_repo_A
```

然后就能看到B仓库的目录结构如下：
```t
B/
    models/
        index.js
```

# 参考链接
[](https://www.jianshu.com/p/b71d901e8ffe)
[](https://www.jianshu.com/p/7b4247f2d0fd)
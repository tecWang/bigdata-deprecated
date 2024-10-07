
### 1. 安装docker

```bash
# docker 设置国内镜像
# 直接替换 docker 中的信息即可。修改位置在：docker for windows --> settings --> docker engine
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}

```

### 2. 搜索ubuntu镜像

```bash

# 需要先打开 docker for windows再执行search命令，否则会报错
# C:\Users\rumor>docker search ubuntu
# error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.47/images/search?term=ubuntu": open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.

# C:\Users\rumor>docker search ubuntu
# request returned Internal Server Error for API route and version http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.47/images/search?term=ubuntu, check if the server supports the requested API version

docker search ubuntu
# C:\Users\rumor>docker search ubuntu
# NAME                           DESCRIPTION                                      STARS     OFFICIAL
# ubuntu                         DEPRECATED; The official build of ubuntu.        7753      [OK]
# ubuntu/postgresql-10-ubuntu    PostgreSQL is an advanced 
```

### 3. 拉取镜像

```bash
C:\Users\rumor>docker pull ubuntu
# Using default tag: latest
# latest: Pulling from library/ubuntu
# a1d0c7532777: Pull complete
# Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
# Status: Downloaded newer image for ubuntu:latest
# docker.io/library/ubuntu:latest

# 可以查看目前本地有哪些镜像
C:\Users\rumor>docker images
# REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
# flink        latest    e3ce3329be5b   2 months ago   798MB
# ubuntu       latest    5d0da3dc9764   3 years ago    231MB

# 删除镜像
# docker rmi <image_id>
C:\Users\rumor>docker rmi 5d0da3dc9764
# Untagged: ubuntu:latest
# Untagged: ubuntu@sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
# Deleted: sha256:5d0da3dc976460b72c77d94c8a1ad043720b0416bfc16c52c45d4847e53fadb6
# Deleted: sha256:74ddd0ec08fa43d09f32636ba91a0a3053b02cb4627c35051aff89f853606b59

# 如果遇到没有办法删除的情况，需要强制删除
# Error response from daemon: conflict: unable to delete 61b2756d6fa9 (must be forced) - image is being used by stopped container 9be756f51062
C:\Users\rumor>docker rmi -f 61b2756d6fa9
# Untagged: ubuntu:latest
# Untagged: ubuntu@sha256:b359f1067efa76f37863778f7b6d0e8d911e3ee8efa807ad01fbf5dc1ef9006b
# Deleted: sha256:61b2756d6fa9d6242fafd5b29f674404779be561db2d0bd932aa3640ae67b9e1
```

### 4. 启动容器

`docker run --name ImageName -it <IMAGE_ID>`
> --name 指定容器名称 </br>
> -i 指定容器在启动后以交互式方式运行 </br>
> -t 指定容器分配一个伪tty设备，方便远程交互 </br>
> -p 指定端口映射，如下文，主机的8080访问容器的7777

```bash

C:\Users\rumor>docker run --name nn1 -it -p 8080:7777 ubuntu
# [root@aab51835dec2 /]#

# 可以列出来所有的容器
docker ps -a
# CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS                            PORTS     NAMES
# 9be756f51062   61b2756d6fa9   "/bin/bash"   4 minutes ago   Exited (127) About a minute ago             nn1

# 进入已经结束的container
docker start -ia <container_id>

# 进入正在运行的container
# 退出时容器会一起退出
docker attach <container_id>

# 进入正在运行的container，后边需要接 /bin/bash，其实是让docker启动了一个bash进程
# 当输入exit或者ctrl c退出时，容器不会退出
# docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
docker exec -it <container_id> /bin/bash

# 停止容器
docker stop <container_id>

```

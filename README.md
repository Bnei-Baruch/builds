# builds

1. [install docker](https://docs.docker.com/engine/install/rhel/)

2. clone the repo

```bash
git clone https://github.com/Bnei-Baruch/builds.git
```

3. build the executable and libs

```bash
cd builds
bash build.sh rockylinux:9.3 nginx '1.27.2'
```
### parametes
  1. container to build in
  2. type of artifact
  3. version

4. get artifact (nginx for example) here:

```
[root@builder-001 builds]# ls -lah /artifacts/nginx/nginx-1.27.2
total 3928
lrwxrwxrwx 1 root root      21 Nov 18 04:23 libmaxminddb.so.0 -> libmaxminddb.so.0.0.7
-rwxr-xr-x 1 root root   78048 Nov 18 04:23 libmaxminddb.so.0.0.7
-rwxr-xr-x 1 root root 3937880 Nov 18 04:24 nginx
```

5. copy nginx to `/usr/sbin/` on destination server (backup current first)

6. copy maxmind libs to `/usr/local/lib/` on desttination server


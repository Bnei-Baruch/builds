#!/bin/bash

yum -y install gcc gcc-c++ make cmake pcre-devel openssl-devel gd gd-devel git wget patch

NGINX_VER="$ARTIFACT_VER"
allModules=(
https://github.com/vozlt/nginx-module-vts.git
https://github.com/yaoweibin/nginx_upstream_check_module
https://github.com/openresty/ngx_http_redis.git
https://github.com/FRiCKLE/ngx_cache_purge.git
)


cd /usr/src
mkdir -p nginx
cd nginx
mkdir -p modules

# get nginx
rm -rf nginx-${NGINX_VER}
wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -xzf -


cd modules

# build brotli
rm -rf ngx_brotli
git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
cd ngx_brotli/deps/brotli
mkdir out && cd out
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto=auto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto=auto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
cmake --build . --config Release --target brotlienc
cd ../../../..

# get rest of modules

for MOD in ${allModules[@]}; do
  MOD_NAME=$(echo -n $MOD | awk -F "/" '{print $NF}' | cut -d '.' -f1)
  rm -rf $MOD_NAME
  git clone --single-branch $MOD
  echo $MOD
done

cd ../nginx-${NGINX_VER}

patch -p1 < ../modules/nginx_upstream_check_module/check_1.20.1+.patch

# download and apply  hpac patch  https://github.com/VirtuBox/nginx-ee/blob/master/nginx-build.sh#L779
curl -sL https://raw.githubusercontent.com/kn007/patch/master/nginx_dynamic_tls_records.patch | patch -p1

./configure \
--add-module=../modules/nginx-module-vts \
--add-module=../modules/nginx_upstream_check_module \
--add-module=../modules/ngx_http_redis \
--add-module=../modules/ngx_cache_purge \
--add-module=../modules/ngx_brotli \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-http_image_filter_module

make -j 4

mkdir -p /artifacts/nginx/${BUILD_LINUX}/nginx-${NGINX_VER}
mv  /usr/src/nginx/nginx-${NGINX_VER}/objs/nginx /artifacts/nginx/${BUILD_LINUX}/nginx-${NGINX_VER}

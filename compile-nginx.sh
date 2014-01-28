mkdir ~/sources/
cd ~/sources

wget https://github.com/pagespeed/ngx_pagespeed/archive/v1.7.30.3-beta.zip
unzip v1.7.30.3-beta.zip
cd ngx_pagespeed-1.7.30.3-beta
wget https://dl.google.com/dl/page-speed/psol/1.7.30.3.tar.gz
tar -xzvf 1.7.30.3.tar.gz

cd ~/sources/
git clone https://github.com/FRiCKLE/ngx_cache_purge.git
cd ~/sources

wget http://www.openssl.org/source/openssl-1.0.1e.tar.gz
tar -xzvf openssl-1.0.1e.tar.gz
cd ~/sources/
wget http://nginx.org/download/nginx-1.5.9.tar.gz
tar zxf nginx-1.5.9.tar.gz
cd nginx-1.5.9

wget http://nginx.org/patches/patch.spdy-v31.txt
patch -p1 < patch.spdy-v31.txt

./configure --prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
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
--user=www-data \
--group=www-data \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-http_spdy_module \
--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
--with-ipv6 \
--with-debug \
--with-openssl=$HOME/sources/openssl-1.0.1e \
--add-module=$HOME/sources/ngx_pagespeed-1.7.30.3-beta \
--add-module=$HOME/sources/ngx_cache_purge

make
checkinstall --install=no --review-control
dpkg -i nginx_1.5.9-1_amd64.deb
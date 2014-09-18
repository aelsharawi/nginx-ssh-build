########################################
#
# Todo:
#
# - add headers-more-nginx-module
# - add naxsi
# - update everything to latest versions
#
########################################


# Install dependencies
# 
# * checkinstall: package the .deb
# * libpcre3, libpcre3-dev: required for HTTP rewrite module
# * zlib1g zlib1g-dbg zlib1g-dev: required for HTTP gzip module
apt-get install checkinstall libpcre3 libpcre3-dev zlib1g zlib1g-dbg zlib1g-dev && \

OLD_DIR=`pwd` && \
WDIR=~/sources/ && \
OPENSSL_VER=1.0.1h && \
PAGESPEED_VER=1.8.31.4 && \
NGINX_VER=1.7.2 && \

mkdir -p $WDIR && \
cd $WDIR && \

# Compile against OpenSSL to enable NPN
wget http://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz && \
tar -xzvf openssl-${OPENSSL_VER}.tar.gz && \

# Download the Cache Purge module
git clone https://github.com/FRiCKLE/ngx_cache_purge.git && \

# Download the Nginx HTTP Auth Digest
# Use a patched fork because the real one compile with a warning and -Werror doesn't like that
git clone https://github.com/maneulyori/nginx-http-auth-digest.git && \

# Download PageSpeed
wget https://github.com/pagespeed/ngx_pagespeed/archive/v${PAGESPEED_VER}-beta.zip && \
unzip v${PAGESPEED_VER}-beta.zip && \
cd ngx_pagespeed-${PAGESPEED_VER}-beta && \
wget https://dl.google.com/dl/page-speed/psol/${PAGESPEED_VER}.tar.gz && \
tar -xzvf ${PAGESPEED_VER}.tar.gz && \
cd $WDIR && \

# Get the Nginx source.
#
# Best to get the latest mainline release. Of course, your mileage may
# vary depending on future changes
wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz && \
tar zxf nginx-${NGINX_VER}.tar.gz && \
cd nginx-$NGINX_VER && \

# Configure nginx.
#
# This is based on the default package in Debian. Additional flags have
# been added:
#
# * --with-debug: adds helpful logs for debugging
# * --with-openssl=$WDIR/openssl-$OPENSSL_VER: compile against newer version
#   of openssl
# * --with-http_spdy_module: include the SPDY module
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
--with-openssl=$WDIR/openssl-$OPENSSL_VER \
--add-module=$WDIR/ngx_pagespeed-${PAGESPEED_VER}-beta \
--add-module=$WDIR/nginx-http-auth-digest \
--add-module=$WDIR/ngx_cache_purge && \

# Make the package.
make && \

# Create a .deb package.
#
# Instead of running `make install`, create a .deb and install from there. This
# allows you to easily uninstall the package if there are issues.
checkinstall --install=no -y && \

# Install the package.
dpkg -i nginx_${NGINX_VER}-1_amd64.deb && \

# Restore old directory.
cd $OLD_DIR && \

# Remove downloaded sources.
rm -rf $WDIR
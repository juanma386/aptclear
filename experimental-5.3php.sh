echo '
#####################################################
#   install PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

wget http://www.dotdeb.org/dotdeb.gpg -O- |apt-key add -;

apt-get update;

apt-get install libbz2-dev libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libc-client2007e-dev libkrb5-dev libmcrypt-dev libpq-dev libmariadbclient-dev-compat build-essential libxml2-dev libcurl4-openssl-dev libpcre3-dev libbz2-dev libjpeg-dev libpng-dev libfreetype6-dev libmcrypt-dev libmhash-dev freetds-dev libmariadbclient-dev-compat unixodbc-dev libxslt1-dev libfcgi-dev libfcgi0ldbl libmcrypt-dev libssl-dev -y -f

echo '
#####################################################
#   Preparado PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

mkdir /usr/local/src/openssl
cd /usr/local/src/openssl
wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz
tar xf openssl-1.0.2l.tar.gz
cd openssl-1.0.2l
./config shared --openssldir=/usr/local/openssl/ enable-ec_nistp_64_gcc_128
make depend
make -j4
make install
ln -s /usr/local/openssl/lib /usr/local/openssl/lib/x86_64-linux-gnu

echo '
#####################################################
#   Preparado curl PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

mkdir /usr/local/src/curl
cd /usr/local/src/curl
wget https://curl.haxx.se/download/curl-7.56.0.tar.gz
tar xf curl-7.56.0.tar.gz
cd curl-7.56.0
env PKG_CONFIG_PATH=/usr/local/openssl/lib/pkgconfig LDFLAGS=-Wl,-rpath=/usr/local/openssl/lib ./configure --with-ssl=/usr/local/openssl --with-zlib --prefix=/usr/local/curl
make  -j4
make install

echo '
#####################################################
#   Preparado imap PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

mkdir /usr/local/imap
cd /usr/local/imap
wget http://http.debian.net/debian/pool/main/u/uw-imap/uw-imap_2007f\~dfsg-5.dsc
wget http://http.debian.net/debian/pool/main/u/uw-imap/uw-imap_2007f\~dfsg.orig.tar.gz
wget http://cdn-fastly.deb.debian.org/debian/pool/main/u/uw-imap/uw-imap_2007f~dfsg-5.debian.tar.xz
dpkg-source -x uw-imap_2007f~dfsg-5.dsc
cd uw-imap-2007f~dfsg/
touch {ipv6,lnxok}
## make process will fail, however it generates what we need, still
make slx SSLINCLUDE=/usr/local/openssl/include/ SSLLIB=/usr/local/openssl/lib EXTRAAUTHENTICATORS=gss
mkdir lib include
cp c-client/*.c lib/
cp c-client/*.h include/
cp c-client/c-client.a lib/libc-client.a
ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a

echo '
#####################################################
#   Preparado imap PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

mkdir /opt/php-5.3.29
mkdir /usr/local/src/php5-build
cd /usr/local/src/php5-build
wget http://de.php.net/get/php-5.3.29.tar.bz2/from/this/mirror -O php-5.3.29.tar.bz2
tar jxf php-5.3.29.tar.bz2

echo '
#####################################################
#   Suhoshin-patch PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

cd /usr/local/src/php5-build
wget https://download.suhosin.org/suhosin-patch-5.3.9-0.9.10.patch.gz
gunzip suhosin-patch-5.3.9-0.9.10.patch.gz
cd php-5.3.29
patch -p 1 -i ../suhosin-patch-5.3.9-0.9.10.patch
## the failed hunks are the visible notes it was build with suhoshin patch, no worries

cd php-5.3.29/

echo '
#####################################################
#   install-patch PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

LDFLAGS="-Wl,-rpath=/usr/local/openssl/lib,-rpath=/usr/local/curl/lib" ./configure --with-config-file-path=/etc/php/5.3/php.ini --with-config-file-scan-dir=/etc/php/5.3/mods-enabled --prefix=/opt/php-5.3.29 --with-zlib-dir --with-freetype-dir --enable-mbstring --with-xpm-dir=/usr --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl=/usr/local/curl --with-mcrypt --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl=/usr/local/openssl --with-imap=/usr/local/imap/uw-imap-2007f~dfsg --with-kerberos --with-imap-ssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=lib/x86_64-linux-gnu --enable-ftp --with-gettext --enable-fpm
LDFLAGS="-Wl,-rpath=/usr/local/openssl/lib,-rpath=/usr/local/curl/lib" make -j4
make install

mkdir -p /etc/php/5.3/fpm/pool.d
mkdir /etc/php/5.3/mods-enabled

cd /usr/local/src/php5-build/php-5.3.29
cp php.ini-production php.ini
sed -i 's/^\(short_open_tag\s*=\s*\).*$/\1On/' php.ini
sed -i 's/^\(expose_php\s*=\s*\).*$/\1Off/' php.ini
sed -i 's/^\(default_socket_timeout\s*=\s*\).*$/\110/' php.ini
sed -i 's/^\(;date\.timezone\s*=\s*\).*$/date\.timezone="Europe\/Berlin"/' php.ini
sed -i 's/^\(session\.cookie_httponly\s*=\s*\).*$/\11/' php.ini
sed -i 's/^\(session\.hash_function\s*=\s*\).*$/\11/' php.ini
sed -i 's/^\(session\.hash_bits_per_character\s*=\s*\).*$/\16/' php.ini
sed -i 's/^\(disable_functions\s*=\s*\).*$/\1pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/' php.ini
cp php.ini /etc/php/5.3/

echo '
#####################################################
#   install-acp PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';

mkdir /usr/local/src/php5-build/apc
cd /usr/local/src/php5-build/apc
wget http://pecl.php.net/get/APC -O 3.1.13.tar.gz
tar xf 3.1.13.tar.gz
cd APC-3.1.13/
/opt/php-5.3.29/bin/phpize
./configure --with-php-config=/opt/php-5.3.29/bin/php-config
make -j4
make install


cp /etc/php/5.3/mods-enabled/apc.ini .;
echo '
#####################################################
#   del config PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';
echo '' > /etc/php/5.3/mods-enabled/apc.ini;
echo '
#####################################################
#   add config PHP 5.3 | Debian 9 Squeeze		    #
#####################################################
';
echo 'extension=/opt/php-5.3.29/lib/php/extensions/no-debug-non-zts-20090626/apc.so' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.enabled=1' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.shm_size=128M' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.ttl=0' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.gc_ttl=600' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.enable_cli=1' >> /etc/php/5.3/mods-enabled/apc.ini;
echo 'apc.mmap_file_mask=/tmp/apc.XXXXXX' >> /etc/php/5.3/mods-enabled/apc.ini;

echo '
#####################################################
#   suhoshin extension PHP 5.3 | Debian 9 Squeeze #
#####################################################
';

mkdir /usr/local/src/php5-build/suhoshin
cd /usr/local/src/php5-build/suhoshin
wget https://download.suhosin.org/suhosin-0.9.37.1.tar.gz
tar xf suhosin-0.9.37.1.tar.gz
cd suhosin-0.9.37.1
/opt/php-5.3.29/bin/phpize
./configure --with-php-config=/opt/php-5.3.29/bin/php-config
make
make install
echo "extension=suhosin.so" > /etc/php/5.3/mods-enabled/suhoshin.ini


ln -s /opt/php-5.3.29/bin/php /usr/bin/php5.3
ln -s /opt/php-5.3.29/sbin/php-fpm /usr/sbin/php-fpm5.3
update-alternatives --install /usr/bin/php php /usr/bin/php5.3 0

chmod +x /etc/init.d/php5.3-fpm;
update-rc.d php5.3-fpm defaults;

update-alternatives --config php;

systemctl enable php5.3-fpm.service;
systemctl daemon-reload;
systemctl restart php5.3-fpm.service;

# Referencia del codigo
# sitio de referencia https://www.howtoforge.com/community/threads/the-perfect-server-debian-9-stretch-add-php-5-3.77549/#post-366596

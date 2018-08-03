## How to install mcrypt in php7.2
##
## https://lukasmestan.com/install-mcrypt-extension-in-php7-2/
##
## Edit: Villalba Juan Manuel Pedro
##


# 
# Check version php and pecl
# 
php -v # if default php is not 7.2 then use /usr/bin/php7.2 instead php
pecl version
 apt-get install php-pear
 apt-get install php7.2-dev

# 
# Install mcrypt extension
# see http://pecl.php.net/package-info.php?package=mcrypt&version=1.0.1
# 
 apt-get -y install gcc make autoconf libc-dev pkg-config
 apt-get -y install libmcrypt-dev
 pecl install mcrypt-1.0.1

# 
# When you are shown the prompt
# 
# libmcrypt prefix? [autodetect] :
# Press Enter to autodetect.

# 
# After success installing mcrypt trought pecl, you should add mcrypt.so extension to php.ini,
# The output will look like this:
# 
# ...
# Build process completed successfully
# Installing '/usr/lib/php/20170718/mcrypt.so'    ---->   this is our path to mcrypt extension lib
# install ok: channel://pecl.php.net/mcrypt-1.0.1
# configuration option "php_ini" is not set to php.ini location
# You should add "extension=mcrypt.so" to php.ini

# 
# Grab installing path and add to cli and apache2 php.ini 
# 
# example:
 bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/cli/conf.d/mcrypt.ini"
 bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/apache2/conf.d/mcrypt.ini"

# check that the extension was installed with this command:
php -i | grep mcrypt

# 
# The output will look like this:
# 
# /etc/php/7.2/cli/conf.d/mcrypt.ini
# Registered Stream Filters => zlib.*, string.rot13, string.toupper, string.tolower, string.strip_tags, convert.*, consumed, dechunk, convert.iconv.*, mcrypt.*, mdecrypt.*
# mcrypt
# mcrypt support => enabled
# mcrypt_filter support => enabled
# mcrypt.algorithms_dir => no value => no value
# mcrypt.modes_dir => no value => no value

# final step
 service apache2 restart

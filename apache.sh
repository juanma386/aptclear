#Bash!
/etc/init.d/webmin stop;
/etc/init.d/apache2 stop;
sudo apt-get remove --purge apache2* -y -f
/etc/init.d/webmin status verbose;
rm -rfv /var/lib/apache2;
./aptclear
/etc/init.d/webmin start;

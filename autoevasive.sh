#! /bin/bash
apt-get update
apt-get upgrade
apt-get install libapache2-mod-security2 libapache2-modsecurity libapache2-mod-evasive -y
cp /etc/modsecurity/modsecurity.conf{-recommended,}
# config with sed
# SecRuleEngine On
sed -i "s|\("^SecRuleEngine" \s* *\).*|\1On|" /etc/modsecurity/modsecurity.conf
# SecRequestBodyLimit 32768000
sed -i "s|\("^SecRequestBodyLimit" \s* *\).*|\132768000|" /etc/modsecurity/modsecurity.conf
# SecRequestBodyInMemoryLimit 32768000
sed -i "s|\("^SecRequestBodyInMemoryLimit" \s* *\).*|\132768000|" /etc/modsecurity/modsecurity.conf
# SecResponseBodyAccess Off
ln -s /usr/share/modsecurity-crs/base_rules/*.conf /usr/share/modsecurity-crs/activated_rules/
apt-get install -y git
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs.bak
mv owasp-modsecurity-crs /usr/share/modsecurity-crs
mv /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf.example /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
#  comment line 26
sed '26s/^/#/' /usr/share/modsecurity-crs/activated_rules/modsecurity_crs_35_bad_robots.conf
# comment line 169
sed '169s/^/#/' /usr/share/modsecurity-crs/activated_rules/modsecurity_crs_40_generic_attacks.conf
# comment line 101
sed '101s/^/#/' /usr/share/modsecurity-crs/activated_rules/modsecurity_crs_50_outbound.conf
# create new conf file for mod_evasive
touch /etc/apache2/mods-available/mod-evasive.conf
cat > /etc/apache2/mods-available/mod-evasive.conf <<EOF
<ifmodule mod_evasive20.c>
DOSHashTableSize 3097
DOSPageCount  10
DOSSiteCount  30
DOSPageInterval 1
DOSSiteInterval  3
DOSBlockingPeriod  3600
DOSLogDir   /var/log/apache2/mod_evasive.log
</ifmodule>
EOF
# creating new log file and set permissions
touch /var/log/apache2/mod_evasive.log
chown www-data:www-data /var/log/apache2/mod_evasive.log
# enable apache2 mods
a2enmod headers
a2enmod evasive
a2enmod security2
service apache2 restart

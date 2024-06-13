# nginx-config.sh
# configure nginx for SSL
if ! test -f default.old
then
 mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.old
 cp /etc/nginx/conf.d/nginx-ssl /etc/nginx/conf.d/default.conf
fi
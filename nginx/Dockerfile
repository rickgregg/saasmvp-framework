FROM nginx:1.21.6
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx-ssl /etc/nginx/conf.d/nginx-ssl
COPY nginx-config.sh /etc/nginx/conf.d/nginx-config.sh
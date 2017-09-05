FROM nginx:alpine

ADD frontend /usr/share/nginx/html/

COPY nginx/mqtt.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
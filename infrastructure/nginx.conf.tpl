events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    types {
        text/javascript mjs;
    }

    server {
        listen 80;
        server_name ${HOST_NAME};
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        server_name ${HOST_NAME};
        ssl_certificate /etc/letsencrypt/live/${HOST_NAME}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${HOST_NAME}/privkey.pem;
        root /var/www/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ =404;
        }
    }
}

worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name ${HOST_NAME};
        root /var/www/html;
        index index.htm index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}

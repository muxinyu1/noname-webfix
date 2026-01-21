FROM node:18-alpine

WORKDIR /app

# Initialize a standard package.json and install 'ws' dependency.
# Using ws@7 because the codebase uses `require('ws').Server`, which was removed in ws@8.
RUN npm init -y && \
    npm install ws@7

# Copy the server code
COPY game/server.js .

# Generate SSL certificates for WSS support
# We use the same configuration as the web server to support IP:10.0.0.5
RUN apk add --no-cache openssl && \
    printf "[req]\n\
distinguished_name = req_distinguished_name\n\
x509_extensions = v3_req\n\
prompt = no\n\
\n\
[req_distinguished_name]\n\
CN = noname-lobby\n\
\n\
[v3_req]\n\
subjectAltName = DNS:localhost,IP:127.0.0.1,IP:10.0.0.5,IP:123.57.245.230\n" > openssl.cnf && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout server.key \
    -out server.crt \
    -config openssl.cnf

# The server listens on port 8080
EXPOSE 8080

CMD ["node", "server.js"]

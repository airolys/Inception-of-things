FROM debian:trixie

RUN apt-get update && apt-get install -y nodejs npm

WORKDIR /app

RUN npm install express

COPY app.js .

EXPOSE 8888
CMD ["node", "app.js"]
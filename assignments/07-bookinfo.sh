#!/bin/sh

mkdir ~/bookinfo-service
git clone -b dev git@github.com:piyanatnine/itkmitl-bookinfo-ratings.git ~/bookinfo-service/ratings
git clone -b dev git@github.com:piyanatnine/itkmitl-bookinfo-details.git ~/bookinfo-service/details
git clone -b dev git@github.com:piyanatnine/itkmitl-bookinfo-reviews.git ~/bookinfo-service/reviews
git clone -b dev git@github.com:piyanatnine/itkmitl-bookinfo-productpage.git ~/bookinfo-service/productpage

cd ~/bookinfo-service/ratings
docker build -t ratings .
docker run -d --name mongodb -p 27017:27017 -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

cd ../details
docker build -t details .
docker run -d --name details -p 8081:9080 details

cd ../reviews
docker build -t reviews .
docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e ENABLE_RATINGS=true -e 'RATINGS_SERVICE=http://ratings:8080' reviews

cd ../productpage
docker build -t productpage .
docker run -d --name productpage -p 8083:9080 --link details:details --link ratings:ratings --link reviews:reviews -e 'REVIEWS_HOSTNAME=http://reviews:9080' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'DETAILS_HOSTNAME=http://details:9080' productpage
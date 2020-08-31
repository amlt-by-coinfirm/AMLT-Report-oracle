FROM ubuntu:focal
COPY . /aml-oracle
WORKDIR /aml-oracle
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential
RUN curl -o- https://deb.nodesource.com/setup_10.x|bash
RUN apt-get install -y nodejs
RUN npm install -g truffle
RUN npm install
RUN truffle test
ENTRYPOINT truffle

FROM centos:centos7

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ARG STRIPE_PUBLIC_KEYS
ARG STRIPE_SECRET_KEYS
ENV STRIPE_PUBLIC_KEYS=$STRIPE_PUBLIC_KEYS
ENV STRIPE_SECRET_KEYS=$STRIPE_SECRET_KEYS
ENV LC_ALL=en_US.UTF-8
ENV AWS_BRANCH=develop

RUN yum -y install epel-release 
RUN yum -y install dos2unix
RUN yum -y install git
RUN yum -y install unzip
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash -
RUN yum -y install nodejs
RUN yum -y install expect

RUN yum -y install make
RUN yum -y install wget
RUN yum install -y nano
RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel
RUN (cd /usr/src && wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz && tar xzf Python-3.7.4.tgz && cd Python-3.7.4 && ./configure --enable-optimizations && make altinstall)

RUN yum -y install which
RUN ln -s $(which python3.7) /usr/bin/python3
RUN ln -s $(which pip3.7) /usr/bin/pip3

RUN pip3 install awscli --upgrade
RUN npm install -g @aws-amplify/cli@4.13.1
RUN npm install JSON
RUN npm install moment
RUN npm install faker
RUN npm install js-combinatorics@0.5.5
RUN npm install cross-fetch
RUN npm install amazon-cognito-identity-js

RUN yum -y install yum-utils
RUN yum -y install gcc
RUN pip3 --no-cache-dir install aws-sam-cli awscli
RUN pip3 install awslogs

RUN yum install java-1.8.0-openjdk -y

RUN git clone --single-branch --branch master https://github.com/SimonEismann/cognitocurl.git
RUN (cd cognitocurl && npm install)
RUN ln -s /cognitocurl/bin/run /usr/bin/cognitocurl

RUN git clone --branch develop https://github.com/SimonEismann/aws-serverless-airline-booking.git
RUN (cd aws-serverless-airline-booking && make init)

RUN aws configure set cli_follow_urlparam false
RUN aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
RUN aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
RUN aws configure set region us-west-2
RUN aws configure set output json

RUN mkdir /results
COPY data /aws-serverless-airline-booking/data
COPY measurementplans /measurementplans
COPY load /aws-serverless-airline-booking
COPY files/generateCognito.js /aws-serverless-airline-booking/generateCognito.js
RUN dos2unix /aws-serverless-airline-booking/generateCognito.js
COPY files/genflights.js /aws-serverless-airline-booking/genflights.js
RUN dos2unix /aws-serverless-airline-booking/genflights.js
COPY files/team-provider-info.json /aws-serverless-airline-booking/amplify/team-provider-info.json
RUN dos2unix /aws-serverless-airline-booking/amplify/team-provider-info.json
COPY files/genFlights.sh /aws-serverless-airline-booking/genFlights.sh
RUN dos2unix /aws-serverless-airline-booking/genFlights.sh
COPY files/addhosting.sh /aws-serverless-airline-booking/addhosting.sh
RUN dos2unix /aws-serverless-airline-booking/addhosting.sh
COPY files/build.sh /aws-serverless-airline-booking/build.sh
RUN dos2unix /aws-serverless-airline-booking/build.sh
COPY files/cognitocurl.sh /aws-serverless-airline-booking/cognitocurl.sh
RUN dos2unix /aws-serverless-airline-booking/cognitocurl.sh
#COPY files/Makefile /aws-serverless-airline-booking/Makefile
#RUN dos2unix /aws-serverless-airline-booking/Makefile
COPY meta-run.sh /meta-run.sh
RUN dos2unix /meta-run.sh
COPY run.sh /run.sh
RUN dos2unix /run.sh
WORKDIR /aws-serverless-airline-booking
RUN git add *
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"
RUN git commit -m "added exp files"
CMD [ "sleep", "1000000000000000000000" ]
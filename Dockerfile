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
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
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
RUN npm install -g @aws-amplify/cli@4.24.0 --unsafe-perm=true
RUN npm install JSON
RUN npm install moment
RUN npm install faker
RUN npm install js-combinatorics
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
RUN echo "cognitocurl installed"

RUN git clone --branch main https://github.com/ServerlessLoadTesting/ReplicationPackage.git
RUN (cd ReplicationPackage && make init)

RUN aws configure set cli_follow_urlparam false
RUN aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
RUN aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
RUN aws configure set region us-west-2
RUN aws configure set output json

RUN mkdir /ReplicationPackage/results
RUN dos2unix /ReplicationPackage/files/generateCognito.js /ReplicationPackage/files/genflights.js /ReplicationPackage/amplify/team-provider-info.json /ReplicationPackage/files/genFlights.sh /ReplicationPackage/files/addhosting.sh /ReplicationPackage/files/build.sh /ReplicationPackage/files/cognitocurl.sh /ReplicationPackage/meta-run.sh /ReplicationPackage/run.sh

RUN chmod +x /ReplicationPackage/meta-run.sh /ReplicationPackage/run.sh /ReplicationPackage/files/* /ReplicationPackage/load/generateConstantLoad.sh

RUN sed -i 's|nodejs10.x|nodejs12.x|g' /usr/lib/node_modules/\@aws-amplify/cli/node_modules/amplify-provider-awscloudformation/lib/update-idp-roles-cfn.json

WORKDIR /ReplicationPackage
CMD [ "sleep", "1000000000000000000000" ]

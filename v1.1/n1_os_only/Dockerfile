FROM  ubuntu:latest
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2021-02-03"
USER  root
WORKDIR /home

# Install necessary libraries from offical repo
RUN apt-get update  -y && \
    apt-get upgrade -y && \
    apt-get install -y  \
        apt-utils \
        build-essential  \
        libreadline-dev  \
        nano  \
        screen \
        vim \
        && \
    rm -rf /var/lib/apt/lists/*

# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"

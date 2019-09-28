FROM  ubuntu:latest
LABEL version="1.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2019-09-28"
USER  root
WORKDIR /home

# Install necessary libraries from offical repo
RUN apt-get update  -y && \
    apt-get upgrade -y && \
    apt-get install -y  \
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

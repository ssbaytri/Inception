FROM debian:13

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*


RUN curl -L https://github.com/portainer/portainer/releases/download/2.33.6/portainer-2.33.6-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar -xvzf portainer.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm portainer.tar.gz


EXPOSE 9443

CMD [ "/usr/local/bin/portainer" ]
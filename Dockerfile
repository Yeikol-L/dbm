FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    curl
RUN wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb

RUN dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

RUN apt-get update 
RUN apt-get install -y percona-toolkit 

# Run pt-heartbeat
CMD ["pt-heartbeat"]

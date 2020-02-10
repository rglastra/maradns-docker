FROM ubuntu:latest as builder
LABEL maintainer="Robert Glastra <robert.glastra@gmail.com>" version="1.0"

# Run apt quietly
RUN apt-get update -qq && apt-get install -qq -o Dpkg::Use-Pty=0 > /dev/null \
    build-essential \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    autoconf \
    git \
    wget

WORKDIR /tmp/maradns

# MaraDNS build/install.sh checks for the presence of these.
RUN mkdir -p /usr/local/share/man/man1 && \
    mkdir -p /usr/local/share/man/man5 && \
    mkdir -p /usr/local/share/man/man8

# Install MaraDNS
RUN git clone https://github.com/samboy/MaraDNS.git /tmp/maradns && \
    cd /tmp/maradns && \
    ./configure && \
    make && \
    make install

# Make Deadwood
RUN cd /tmp/maradns/deadwood-github/src/ && mv Makefile.sl6 Makefile && \
    bash make.version.h && \
    make

# Create production image
FROM ubuntu:latest
RUN apt-get update && apt-get install dnsutils nano -y && apt-get clean

# Copy the compiled files from builder
COPY --from=builder /tmp/maradns/deadwood-github/src/Deadwood /usr/local/sbin/Deadwood
COPY --from=builder /usr/local/bin/askmara /usr/local/bin/askmara
COPY --from=builder /usr/local/bin/duende /usr/local/bin/duende
COPY --from=builder /usr/local/bin/fetchzone /usr/local/bin/fetchzone
COPY --from=builder /usr/local/bin/getzone /usr/local/bin/getzone
COPY --from=builder /usr/local/sbin/maradns /usr/local/sbin/maradns
COPY --from=builder /usr/local/sbin/zoneserver /usr/local/sbin/zoneserver
COPY --from=builder /etc/mararc /etc/mararc
COPY --from=builder /etc/maradns/db.example.net /etc/maradns/db.example.net
COPY --from=builder /etc/maradns/logger /etc/maradns/logger

#WORKDIR /
#COPY maradns/ .

EXPOSE 53/udp
EXPOSE 53/tcp
CMD ["/usr/local/sbin/maradns"]

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wireguard iproute2 iptables curl tini && \
    apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/entrypoint.sh"]
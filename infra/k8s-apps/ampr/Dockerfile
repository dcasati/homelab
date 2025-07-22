FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wireguard iproute2 iptables iputils-ping curl && \
    apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
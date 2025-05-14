FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y iptables iproute2 iputils-ping net-tools python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY upf.py .
CMD ["python3", "upf.py"]

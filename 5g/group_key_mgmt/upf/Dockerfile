FROM python:3.10-slim

# Install essential tools
RUN apt-get update && \
    apt-get install -y \
    iproute2 \      
    iptables \      
    kmod \          
    net-tools \     
    iputils-ping && \
    rm -rf /var/lib/apt/lists/*
    
WORKDIR /app
COPY upf.py ./

# Install Flask and requests using pip
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install flask requests

EXPOSE 5006
CMD ["python3", "upf.py"]
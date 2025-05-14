FROM ubuntu:22.04

# Install network utilities
RUN apt-get update && \
    apt-get install -y iproute2 && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y python3-pip && \
    apt-get install -y python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Install Flask and requests using pip
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install flask requests

# Expose port 5000 to the outside world
EXPOSE 5000

# Run the application
CMD ["python3", "ue.py"]
FROM python:3.10-slim
WORKDIR /app
COPY udm.py .
RUN pip3 install flask
EXPOSE 5004
CMD ["python", "udm.py"]
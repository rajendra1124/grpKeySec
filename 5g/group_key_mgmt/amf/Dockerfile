FROM python:3.10-slim
WORKDIR /app
COPY amf.py .
RUN pip3 install flask requests
EXPOSE 5002
CMD ["python", "amf.py"]
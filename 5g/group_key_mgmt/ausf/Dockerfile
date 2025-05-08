FROM python:3.10-slim
WORKDIR /app
COPY ausf.py .
RUN pip3 install flask requests
EXPOSE 5003
CMD ["python", "ausf.py"]
FROM python:3.10-slim
WORKDIR /app
COPY gnb.py .
RUN pip3 install flask requests
EXPOSE 5001
CMD ["python", "gnb.py"]
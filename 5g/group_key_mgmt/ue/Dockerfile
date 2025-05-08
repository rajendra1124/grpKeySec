FROM python:3.10-slim
WORKDIR /app
COPY ue.py .
RUN pip3 install flask requests
EXPOSE 5000
CMD ["python", "ue.py"]  # This will now keep running
FROM python:3.10-slim
WORKDIR /app
COPY smf.py .
RUN pip3 install flask requests
EXPOSE 5005
CMD ["python", "smf.py"]
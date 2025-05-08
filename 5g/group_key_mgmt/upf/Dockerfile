FROM python:3.10-slim
WORKDIR /app
COPY upf.py .
RUN pip3 install flask
EXPOSE 5006
CMD ["python", "upf.py"]
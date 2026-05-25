FROM python:3.9-slim
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple flask mysql-connector-python
COPY app.py /app.py
CMD ["python", "/app.py"]

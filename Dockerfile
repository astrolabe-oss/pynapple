# Use an official Python runtime as a parent image
FROM python:3.8

WORKDIR /app/pynapple
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 80

ENV FLASK_APP=run.py
ENV PYTHONPATH=/app/pynapple

WORKDIR /app
CMD ["gunicorn", "-b", "0.0.0.0:80", "run:app"]

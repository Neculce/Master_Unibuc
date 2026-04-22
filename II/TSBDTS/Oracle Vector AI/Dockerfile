FROM python:3.10-slim
LABEL authors="iamxorum"

RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

RUN echo '#!/bin/bash \n\
export PYTHONUNBUFFERED=1 \n\
python app/setup_database.py \n\
if [ $? -eq 0 ]; then \n\
    python app/generate_embeddings.py \n\
    python app/app.py \n\
else \n\
    sleep 30 \n\
    exit 1 \n\
fi' > /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
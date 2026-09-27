FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar conectores de bases de datos
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar las librerías directamente desde pip de forma nativa
RUN pip install --no-cache-dir fastapi uvicorn sqlalchemy psycopg2-binary pymongo

# Copiar el código de la aplicación
COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

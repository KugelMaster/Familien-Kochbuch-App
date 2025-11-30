FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY /src .

# FastAPI does use the Port defined in the ENV!
ENV PORT=8000
EXPOSE 8000
CMD ["fastapi", "run", "main.py"]

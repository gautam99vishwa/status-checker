#  # Stage 1: Frontend Build

#  FROM node:18 AS frontend-builder

#  WORKDIR /app/frontend
 
#  COPY frontend/package*.json ./
 
#  RUN npm install
 
#  COPY frontend/. ./
 
#  RUN npm run build
 
 
 
 
#  # Stage 2: Backend Build
 
#  FROM python:3.9-slim-buster AS backend-builder
 
#  WORKDIR /app/backend
 
#  COPY backend/server.py ./
 
#  COPY backend/venv ./venv
 
#  RUN pip install --no-cache-dir flask flask_cors requests gunicorn
 
 
 
 
#  # Stage 3: Final Image
 
#  FROM nginx:alpine
 
#  COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
 
#  COPY --from=backend-builder /app/backend/server.py /app/server.py
 
#  COPY --from=backend-builder /app/backend/venv /app/venv
 
#  #copy nginx conf file for proxy pass
 
#  COPY nginx.conf  /etc/nginx/conf.d/default.conf
 
#  # Set environment variables
 
#  ENV FLASK_APP=/app/server.py
 
#  ENV VIRTUAL_ENV=/app/venv
 
#  ENV FLASK_RUN_HOST=0.0.0.0
 
#  ENV FLASK_RUN_PORT=5000
 
#  # Expose port 80 for the nginx
 
#  EXPOSE 80
 
#  # Start the backend server
 
#  CMD ["/bin/sh", "-c", ". /app/venv/bin/activate && gunicorn --bind 0.0.0.0:5000 server:app"]
 
 # Stage 1: Frontend Build

 ################

#  FROM node:18 AS frontend-builder

#  WORKDIR /app/frontend
 
#  COPY frontend/package*.json ./
 
#  RUN npm install
 
#  COPY frontend/. ./
 
#  RUN npm run build
 
#  # Stage 2: Backend Build
 
#  FROM python:3.9-slim-buster AS backend-builder
 
#  WORKDIR /app/backend
 
#  COPY backend/server.py ./
 
#  COPY backend/venv ./venv
 
#  RUN pip install --no-cache-dir flask flask_cors requests gunicorn
 
#  # Stage 3: Final Image
 
#  FROM nginx:alpine
 
#  COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
 
#  COPY --from=backend-builder /app/backend/server.py /app/server.py
 
#  COPY --from=backend-builder /app/backend/venv /app/venv
 
#  #copy nginx conf file for proxy pass
 
#  COPY nginx.conf  /etc/nginx/conf.d/default.conf
 
#  # Set environment variables
 
#  ENV FLASK_APP=/app/server.py
 
#  ENV VIRTUAL_ENV=/app/venv
 
#  ENV FLASK_RUN_HOST=0.0.0.0
 
#  ENV FLASK_RUN_PORT=5000
 
#  # Expose port 80 for the nginx
 
#  EXPOSE 80
 
#  # Start the backend server
 
#  CMD ["sh", "-c", "source /app/venv/bin/activate && echo 'Virtual environment activated' && /app/venv/bin/gunicorn --bind 0.0.0.0:5000 server:app"]
 # Stage 1: Build Frontend

 # Stage 1: Build Frontend
FROM node:18 AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Backend Setup
FROM python:3.9-slim

WORKDIR /app
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./
COPY --from=frontend-builder /app/frontend/dist /app/frontend

# Install Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose ports
EXPOSE 80 5000

# Start Gunicorn and Nginx
CMD ["sh", "-c", "gunicorn -w 4 -b 0.0.0.0:5000 server:app & nginx -g 'daemon off;'"]

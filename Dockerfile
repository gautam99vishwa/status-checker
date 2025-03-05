#  # Stage 1: Frontend Build

#  FROM node:16-alpine AS frontend-builder

#  WORKDIR /app/frontend
 
#  COPY frontend/package*.json ./
 
#  RUN npm install
 
#  COPY frontend/. ./
 
#  RUN npm run dev 
 
 
 
 
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

 FROM node:16 AS frontend-builder

 WORKDIR /app/frontend
 
 COPY frontend/package*.json ./
 
 RUN npm install
 
 # Install any missing dependencies required for building
 
 RUN apt-get update && apt-get install -y --no-install-recommends \
 
     ca-certificates \
 
     && rm -rf /var/lib/apt/lists/*
 
 # Add this line to install a crypto polyfill
 
 RUN npm install crypto-browserify
 
 # Set environment variables to ensure proper build execution
 
 ENV CI=true
 
 ENV WDS_SOCKET_PORT=0
 
 COPY frontend/. ./
 
 RUN npm run build
 
 
 
 
 # Stage 2: Backend Build
 
 FROM python:3.9-slim-buster AS backend-builder
 
 WORKDIR /app/backend
 
 COPY backend/server.py ./
 
 COPY backend/venv ./venv
 
 RUN pip install --no-cache-dir flask flask_cors requests gunicorn
 
 
 
 
 # Stage 3: Final Image
 
 FROM nginx:alpine
 
 COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
 
 COPY --from=backend-builder /app/backend/server.py /app/server.py
 
 COPY --from=backend-builder /app/backend/venv /app/venv
 
 #copy nginx conf file for proxy pass
 
 COPY nginx.conf  /etc/nginx/conf.d/default.conf
 
 # Set environment variables
 
 ENV FLASK_APP=/app/server.py
 
 ENV VIRTUAL_ENV=/app/venv
 
 ENV FLASK_RUN_HOST=0.0.0.0
 
 ENV FLASK_RUN_PORT=5000
 
 # Expose port 80 for the nginx
 
 EXPOSE 80
 
 # Start the backend server
 
 CMD ["/bin/sh", "-c", ". /app/venv/bin/activate && gunicorn --bind 0.0.0.0:5000 server:app"]
 
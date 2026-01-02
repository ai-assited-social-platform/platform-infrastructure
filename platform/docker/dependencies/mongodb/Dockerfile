FROM mongo:latest

COPY ai/init-ai-db.js /docker-entrypoint-initdb.d/01-init-ai-db.js
COPY chat/init-chat-db.js /docker-entrypoint-initdb.d/02-init-chat-db.js

EXPOSE 27017

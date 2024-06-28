# syntax=docker/dockerfile:1

FROM node:lts-alpine AS builder
WORKDIR /src
COPY package*.json ./

# Install dependencies including python3 and make
RUN apk add --no-cache python3 make g++ && \
    npm install && \
    apk del python3 make g++

COPY . .
RUN npm run build

FROM node:lts-alpine
WORKDIR /app
COPY package*.json ./

ARG SUNO_COOKIE
RUN if [ -z "$SUNO_COOKIE" ]; then echo "SUNO_COOKIE is not set" && exit 1; fi
ENV SUNO_COOKIE=${SUNO_COOKIE}

# Install dependencies including python3 and make
RUN apk add --no-cache python3 make g++ && \
    npm install --only=production && \
    apk del python3 make g++

COPY --from=builder /src/.next ./.next
EXPOSE 3000
CMD ["npm", "run", "start"]
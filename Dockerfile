FROM ruby:3.4.2-alpine

# Paquetes básicos para compilar gems
RUN apk update && apk add --no-cache \
    build-base tzdata yaml-dev curl bash \
    # si usas PostgreSQL, descomenta la siguiente línea:
    # postgresql-dev \
    # si usas SQLite, descomenta la siguiente línea:
    # sqlite-dev \
 && rm -rf /var/cache/apk/*

WORKDIR /app

# Dependencias Ruby (capa cacheable)
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_WITHOUT=""
RUN bundle install --no-cache

# Código
COPY . .

# Usuario no-root y permisos
RUN addgroup -S app && adduser -S -D -G app app \
 && mkdir -p tmp/pids log \
 && chown -R app:app /app /usr/local/bundle
USER app

EXPOSE 3001
ENV RAILS_ENV=development

CMD ["bin/rails","server","-b","0.0.0.0","-p","3001"]

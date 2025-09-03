# Usar una imagen base Ruby en Alpine
ARG BUILD_IMAGE=ruby:3.4.2-alpine
FROM $BUILD_IMAGE

# Instalar dependencias del sistema necesarias y bash
RUN apk update && \
    apk add --no-cache \
    bash \
    build-base \
    libpq-dev \
    tzdata \
    yaml-dev && \
    rm -rf /var/cache/apk/*

# Establecer el directorio de trabajo
WORKDIR /rails

# Copiar solo Gemfile y Gemfile.lock primero para aprovechar el caché
COPY Gemfile Gemfile.lock ./

# Establecer variables de entorno para Rails
ARG ENVIRONMENT=development
ARG GROUP_EXCLUDE_BUNDLE="production testing"
ENV RAILS_ENV=$ENVIRONMENT

# Instalar las gemas necesarias excluyendo grupos no deseados
RUN bundle config set without $GROUP_EXCLUDE_BUNDLE && bundle install --no-cache

# Copiar el resto de la aplicación Rails
COPY . .

# Generar y guardar un secreto OTP en un archivo .env
RUN echo "OTP_SECRET=$(rails secret)" > .env

# Copiar el script de arranque y darle permisos de ejecución
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

# Exponer el puerto configurado por la variable de entorno APP_PORT
EXPOSE 3001

# Establecer el punto de entrada usando bash
ENTRYPOINT ["bash", "/usr/bin/run.sh"]

# Comando por defecto si no se pasa ninguno desde Kubernetes
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3001"]
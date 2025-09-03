#!/bin/bash
set -e

echo "===> Entrando al entrypoint: $@"

# Ejecutar tareas solo si el comando es rails server
if [[ "$@" == *"rails server"* ]]; then
    echo "===> Ejecutando setup de base de datos..."
    # 1) Crear la DB (si no existe)
    bundle exec rails db:create
    # 2) Ejecutar migraciones
    bundle exec rails db:migrate
    # 3) Sembrar datos
    bundle exec rails db:seed
fi

# Ejecutar el comando que se pase
exec "$@"
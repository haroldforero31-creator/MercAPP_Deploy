#!/usr/bin/env bash
# ============================================================
# MercAPP — Build Script para Render
# ============================================================
set -o errexit

echo "=== Instalando dependencias ==="
pip install --upgrade pip
pip install -r requirements.txt

echo "=== Creando directorios de uploads ==="
mkdir -p uploads/products uploads/categories uploads/invoices
mkdir -p MercAPP_IS2_Frontend/static/images/products
mkdir -p MercAPP_IS2_Frontend/static/images/categories
mkdir -p MercAPP_IS2_Frontend/static/images/invoices

echo "=== Inicializando base de datos ==="
python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Tablas creadas exitosamente')
"

echo "=== Build completado ==="
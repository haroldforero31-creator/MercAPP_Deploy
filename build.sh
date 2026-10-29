#!/usr/bin/env bash
set -o errexit

pip install --upgrade pip
pip install -r requirements.txt

mkdir -p uploads/products uploads/categories uploads/invoices

python -c "
import pymysql
import os

# Primero crear la base de datos 'test' si no existe
db_url = os.getenv('DATABASE_URL', '')
if 'tidbcloud' in db_url:
    import re
    m = re.match(r'mysql://([^:]+):([^@]+)@([^:]+):(\d+)', db_url)
    if m:
        import ssl as _ssl
        ssl_ctx = _ssl.create_default_context()
        conn = pymysql.connect(
            host=m.group(3), port=int(m.group(4)),
            user=m.group(1), password=m.group(2),
            ssl=ssl_ctx
        )
        conn.cursor().execute('CREATE DATABASE IF NOT EXISTS test')
        conn.close()
        print('Base de datos test creada/verificada.')

from app import app, db
with app.app_context():
    db.create_all()
    print('Tablas creadas correctamente.')
"

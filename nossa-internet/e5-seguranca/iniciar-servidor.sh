#!/bin/sh
ip route del default 2>/dev/null || true
# Rota de VOLTA: sem ela o servidor recebe o pedido e não consegue responder.
ip route add 10.0.10.0/24 via 10.0.20.254
echo "area restrita do sistema" > /srv/index.html

# Versão desprotegida, na porta 8080 (HTTP puro).
httpd -f -p 8080 -h /srv &

# ---------- TAREFA DO GRUPO: versão protegida por TLS, porta 8443 ----------
mkdir -p /lab
openssl req -x509 -newkey rsa:2048 -nodes -days 30 -subj /CN=srv \
        -addext "subjectAltName=DNS:srv" \
        -keyout /lab/key.pem -out /lab/cert.pem 2>/dev/null

# -WWW serve arquivos do diretório atual (o -www só mostra página de status)
cd /srv
openssl s_server -accept 8443 -cert /lab/cert.pem -key /lab/key.pem -WWW -quiet &

wait
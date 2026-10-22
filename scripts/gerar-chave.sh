#!/usr/bin/env bash
# Gera a chave de assinatura do app UMA vez, no seu computador (precisa do Java/keytool).
# Guarde o arquivo .keystore e a senha em lugar seguro: sem eles não dá para
# publicar atualizações que instalam por cima. Não envie o .keystore para o GitHub.
set -euo pipefail

FILE="volta-do-almoco.keystore"
ALIAS="voltadoalmoco"

if [ -e "$FILE" ]; then
  echo "O arquivo $FILE já existe. Apague ou mova antes de gerar outro." >&2
  exit 1
fi

read -r -s -p "Escolha uma senha para a chave (mínimo 6 caracteres): " PASS
echo
read -r -s -p "Repita a senha: " PASS2
echo
[ "$PASS" = "$PASS2" ] || { echo "As senhas não conferem." >&2; exit 1; }

keytool -genkeypair -keystore "$FILE" -storetype PKCS12 -alias "$ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000 -storepass "$PASS" \
  -dname "CN=Volta do Almoco"

B64=$(base64 < "$FILE" | tr -d '\n')
echo
echo "Chave criada: $FILE"
echo
echo "Cadastre estes 2 segredos em GitHub > Settings > Secrets and variables > Actions:"
echo "  KEYSTORE_PASSWORD = a senha que você acabou de digitar"
echo "  KEYSTORE_B64      = o texto abaixo (uma linha só)"
echo
echo "$B64"

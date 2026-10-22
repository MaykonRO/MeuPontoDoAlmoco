#!/usr/bin/env bash
# Roda depois de `npx cap add android` e `npx cap sync android`.
# Copia o plugin nativo de Live Updates e libera as permissões extras.
set -euo pipefail

PKG_DIR="android/app/src/main/java/br/com/maykon/voltadoalmoco"
MANIFEST="android/app/src/main/AndroidManifest.xml"

cp native/LiveUpdatePlugin.java "$PKG_DIR/LiveUpdatePlugin.java"
cp native/MainActivity.java "$PKG_DIR/MainActivity.java"

add_permission() {
  grep -q "$1" "$MANIFEST" || sed -i "s#</manifest>#    <uses-permission android:name=\"$1\" />\n</manifest>#" "$MANIFEST"
}
add_permission android.permission.POST_NOTIFICATIONS
add_permission android.permission.POST_PROMOTED_NOTIFICATIONS
# Alarme com horário exato (Android 12 ou superior).
add_permission android.permission.USE_EXACT_ALARM

# Versão automática: o código de versão sobe a cada build (número da execução no GitHub),
# para o Android aceitar o APK novo como atualização.
VERSION_CODE="${APP_VERSION_CODE:-1}"
GRADLE="android/app/build.gradle"
sed -i -E "s/versionCode [0-9]+/versionCode ${VERSION_CODE}/; s/versionName \"[^\"]*\"/versionName \"1.0.${VERSION_CODE}\"/" "$GRADLE"
echo "Versão do APK: 1.0.${VERSION_CODE} (código ${VERSION_CODE})"

# Assinatura: usa a chave fixa dos segredos (KEYSTORE_B64 e KEYSTORE_PASSWORD).
# Sem os segredos, gera uma chave temporária só para o build funcionar; nesse caso o
# Android NÃO aceita atualizar por cima de uma versão assinada com outra chave.
KEYSTORE="android/app/volta.keystore"
ALIAS="voltadoalmoco"
if [ -n "${KEYSTORE_B64:-}" ] && [ -n "${KEYSTORE_PASSWORD:-}" ]; then
  echo "$KEYSTORE_B64" | base64 -d > "$KEYSTORE"
  STORE_PASS="$KEYSTORE_PASSWORD"
  echo "Assinando com a chave fixa dos segredos."
else
  STORE_PASS="temporaria"
  rm -f "$KEYSTORE"
  keytool -genkeypair -keystore "$KEYSTORE" -storetype PKCS12 -alias "$ALIAS" \
    -keyalg RSA -keysize 2048 -validity 3650 -storepass "$STORE_PASS" \
    -dname "CN=Volta do Almoco temporario" >/dev/null 2>&1
  echo "::warning::Sem chave fixa: o APK foi assinado com uma chave temporária e não atualiza por cima de versões anteriores. Veja o README (Chave de assinatura)."
fi
if [ -n "${GITHUB_ENV:-}" ]; then
  # A senha já é um segredo (mascarado nos logs) ou o valor temporário.
  echo "APK_KEYSTORE_PASSWORD=$STORE_PASS" >> "$GITHUB_ENV"
fi

cat > android/app/signing.gradle <<EOF2
android {
    signingConfigs {
        volta {
            storeFile file("volta.keystore")
            storePassword System.getenv("APK_KEYSTORE_PASSWORD")
            keyAlias "$ALIAS"
            keyPassword System.getenv("APK_KEYSTORE_PASSWORD")
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.volta
        }
    }
}
EOF2
grep -q "signing.gradle" android/app/build.gradle || echo 'apply from: "signing.gradle"' >> android/app/build.gradle

echo "Android preparado."

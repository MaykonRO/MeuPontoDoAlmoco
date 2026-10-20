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

# Versão automática: o código de versão sobe a cada build (número da execução no GitHub),
# para o Android aceitar o APK novo como atualização.
VERSION_CODE="${APP_VERSION_CODE:-1}"
GRADLE="android/app/build.gradle"
sed -i -E "s/versionCode [0-9]+/versionCode ${VERSION_CODE}/; s/versionName \"[^\"]*\"/versionName \"1.0.${VERSION_CODE}\"/" "$GRADLE"
echo "Versão do APK: 1.0.${VERSION_CODE} (código ${VERSION_CODE})"

echo "Android preparado."

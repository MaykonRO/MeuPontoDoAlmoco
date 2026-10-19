# Volta do Almoço

Toque ao sair para o almoço e veja a hora de voltar (1 hora depois). No Android, a hora de volta fica numa notificação fixa na barra.

## Estrutura

- `www/index.html`: o app (HTML, CSS e JS, sem build).
- `capacitor.config.json`: configuração do Capacitor.
- `.github/workflows/build-apk.yml`: compila o APK na nuvem.

## Instalar no celular

1. Abra a aba **Actions** do repositório e entre na última execução de **Build APK**.
2. Baixe o arquivo **volta-do-almoco-apk** em *Artifacts* e descompacte o `.zip`.
3. No Android, permita instalar apps de fontes desconhecidas e toque no `app-debug.apk`.
4. Ao abrir pela primeira vez, aceite a permissão de notificações.

O APK é de teste (debug), serve para uso pessoal.

## Rodar no navegador

Abra `www/index.html`. A notificação fixa só funciona no app Android.

# Volta do Almoço

Toque ao sair para o almoço e veja a hora de voltar (1 hora depois). No Android, a hora de volta fica numa notificação fixa na barra.

## Estrutura

- `www/index.html`: o app (HTML, CSS e JS, sem build).
- `capacitor.config.json`: configuração do Capacitor.
- `.github/workflows/build-apk.yml`: compila o APK na nuvem.

## Instalar no celular

1. **[Baixar o APK mais recente](https://github.com/MaykonRO/MeuPontoDoAlmoco/releases/latest/download/volta-do-almoco.apk)**. O link é atualizado sozinho a cada merge na `main`.
2. No Android, permita instalar apps de fontes desconhecidas e toque no `volta-do-almoco.apk`.
3. Ao abrir pela primeira vez, aceite a permissão de notificações.

O APK é de teste (debug), serve para uso pessoal.

## Chave de assinatura (fazer uma vez)

Para o Android aceitar a atualização **por cima** do app instalado, todos os APKs precisam ser assinados com a mesma chave. Sem isso, o build usa uma chave temporária e o celular recusa a atualização (é preciso desinstalar antes).

1. No seu computador (com Java instalado), rode `bash scripts/gerar-chave.sh` e escolha uma senha. Guarde o arquivo `volta-do-almoco.keystore` e a senha em lugar seguro. Não envie o `.keystore` para o GitHub.
2. Em **Settings → Secrets and variables → Actions**, cadastre os dois segredos que o script mostra no final:
   - `KEYSTORE_PASSWORD`: a senha que você escolheu.
   - `KEYSTORE_B64`: o texto longo (uma linha só) que o script imprime.
3. No próximo build, o resumo da execução mostra o certificado **SHA-256** do APK. Se ele for igual ao do build anterior, a atualização por cima funciona.

Se a chave for perdida, será preciso desinstalar o app e instalar um novo APK assinado com uma chave nova.

## Rodar no navegador

Abra `www/index.html`. A notificação fixa só funciona no app Android.

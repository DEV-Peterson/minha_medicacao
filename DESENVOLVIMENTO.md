# Documentação técnica — Minha Medicação

Este documento é para quem vai mexer no código. Se você só quer usar o
aplicativo, o [README](README.md) tem o que precisa.

Aplicativo Android local para organizar medicamentos, tratamentos, lembretes,
histórico de doses e estoque. Não tem conta, login, servidor, analytics ou
integração clínica. O SQLite local é a fonte de verdade e as notificações são
sempre reconstruíveis a partir dele. O aplicativo é organizacional e não
fornece orientação médica.

O `applicationId` estável é `br.com.minha_medicacao`. Não o altere depois de
instalar o primeiro APK que conterá dados reais.

## Stack

- Flutter 3.44 / Dart 3.12 e Material 3;
- Drift sobre SQLite, com foreign keys, constraints, índices e migrations;
- Riverpod para injeção, streams e estado assíncrono;
- `flutter_local_notifications`, `timezone` e `flutter_timezone`;
- `image_picker` e armazenamento privado para fotos e receitas;
- `archive`, `crypto`, `file_picker` e `share_plus` para backup local.

O `applicationId` estável é `br.com.minha_medicacao`. Não o altere depois de
instalar o primeiro APK que conterá dados reais.

## Preparar o ambiente

1. Instale o Flutter estável seguindo a documentação oficial:
   <https://docs.flutter.dev/get-started/install/windows/mobile>.
2. Instale Android SDK 36, command-line tools e Java 17.
3. Aceite as licenças:

   ```powershell
   flutter doctor --android-licenses
   flutter doctor -v
   ```

4. Na raiz do projeto, baixe as dependências e gere o código Drift:

   ```powershell
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

Os schemas versionados ficam em `drift_schemas/app_database/`. A versão 2
introduz datas civis estáveis para início/fim de tratamentos; a versão 3
acrescenta a recorrência por dias do calendário. Ambas migram sem perda.

Ao mudar o schema, incremente `versaoSchemaBancoAtual`, escreva a migration e
gere os artefatos. Como `schemaVersion` é lido de uma constante, o
`make-migrations` não consegue inferir a versão sozinho; passe o arquivo:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/core/banco/app_database.dart drift_schemas/app_database/drift_schema_vN.json
dart run drift_dev schema generate drift_schemas/app_database/ test/drift/app_database/generated/
```

Migrations que só acrescentam colunas usam `addColumn`. Quando a mudança
inclui constraint de tabela — que o SQLite não aceita via `ALTER TABLE` — a
tabela é reconstruída com `TableMigration`, com as chaves estrangeiras
desligadas durante a operação e um `PRAGMA foreign_key_check` antes de
religá-las. Sem isso, um banco migrado ficaria com schema diferente de um
banco recém-criado, e o teste de migração acusa a divergência.

Nunca resolva uma atualização apagando ou recriando o banco da usuária.

## Executar e testar

Com um aparelho Android conectado e depuração USB habilitada:

```powershell
flutter devices
flutter run
```

Validação local completa:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Os testes cobrem motor de agenda, viradas de data, intervalo ancorado,
idempotência de doses, transações de estoque, backup/restore, identificadores de
notificação e fluxos essenciais de widgets.

## Rotina no aplicativo (resumo funcional)

- **Hoje** concentra o dia: resumo, próxima dose e as ações **Tomei**, **Adiar**
  e **Não tomei**. A confirmação é idempotente e dá baixa no estoque uma única
  vez.
- **Histórico** permite corrigir um registro marcado como tomado por engano; o
  estorno de estoque é criado vinculado à saída original, sem apagar nada.
- **Estoque** repõe, ajusta pela contagem real e também **ativa ou desativa o
  controle** de um medicamento cadastrado sem ele. Ao ativar, a quantidade
  informada entra no ledger (entrada inicial ou ajuste, quando já houve
  movimentações) e o consumo por dose passa a ser exigido enquanto existir
  tratamento ativo.
- **Medicamentos** cadastra, edita, anexa fotos, altera ou encerra tratamentos e
  inativa um medicamento. Um medicamento inativado pode ser **reativado**; os
  tratamentos encerrados continuam encerrados, então inicie um novo tratamento
  para voltar a gerar doses.

## Regras de agenda

Um tratamento tem um tipo de agendamento e, quando ele usa horários definidos,
uma recorrência de dias:

| Tipo | Campos | Uso |
| --- | --- | --- |
| `horariosFixos` | horários em `horarios_tratamento` | 08:00 e 20:00 |
| `intervalo` | âncora + `intervalo_minutos` | a cada 8 horas |

| Recorrência | Colunas | Exemplo |
| --- | --- | --- |
| `diaria` | — | todo dia |
| `cadaNDias` | `recorrencia_intervalo` | dia sim, dia não |
| `diasDaSemana` | `recorrencia_dias_semana`, `recorrencia_intervalo` | seg e qui, a cada 2 semanas |
| `mensal` | `recorrencia_dia_do_mes`, `recorrencia_intervalo` | todo dia 5, a cada 3 meses |

A contagem é sempre por data civil, nunca por duração: somar 48 horas
deslocaria o horário prescrito se o fuso mudasse. No modo mensal, um dia que
não existe no mês cai no último dia — dia 31 vira 28, 29 ou 30.

Recorrência não diária é incompatível com `intervalo`, e o domínio recusa a
combinação: o intervalo em horas já governa a própria sequência a partir da
âncora.

Isso tem uma consequência no agendamento de lembretes. Um tratamento contínuo
com horários fixos e recorrência diária vira uma notificação repetida todo dia,
gastando um alarme por horário. Qualquer outra recorrência usa ocorrências
individuais, porque a repetição diária tocaria em dias sem dose. Para que o
planejador não percorra o calendário dia a dia procurando a próxima dose de um
remédio mensal, ele salta direto para o próximo dia aceito pela recorrência.

## Compatibilidade e layout

O aplicativo declara `minSdk = 24` (Android 7.0) explicitamente em
`android/app/build.gradle.kts`, em vez de herdar o padrão do Flutter, para que
uma atualização da ferramenta não eleve o mínimo sem querer. O `targetSdk`
acompanha o padrão atual do Flutter.

As diferenças entre versões do Android ficam concentradas nos lembretes:

- `POST_NOTIFICATIONS` só existe no Android 13+; abaixo disso o plugin informa
  o estado real das notificações;
- `SCHEDULE_EXACT_ALARM` vale até o Android 12L e `USE_EXACT_ALARM` a partir do
  Android 13; abaixo do Android 12 o alarme exato é concedido pelo sistema e a
  verificação de saúde responde “habilitado”;
- canais de notificação existem a partir do Android 8; em versões anteriores a
  verificação de canal é considerada satisfeita.

O layout se adapta às faixas de largura do Material 3, definidas em
`lib/app/layout.dart`:

| Largura | Uso típico | Navegação | Conteúdo |
| --- | --- | --- | --- |
| < 600dp | celular em retrato | barra inferior | uma coluna |
| 600–839dp | celular em paisagem, tablet pequeno | barra inferior | uma coluna centralizada |
| ≥ 840dp | tablet em paisagem | trilha lateral | até três colunas de cartões |

O conteúdo tem largura máxima para não esticar linhas de texto em telas
grandes, as listas de cartões usam `Wrap` (a altura varia com o texto, então
nada é cortado) e os rótulos da barra de navegação limitam a escala de fonte
para caber em uma linha. O restante da interface acompanha o tamanho de fonte
do sistema.

Os testes em `test/widgets/responsividade_test.dart` montam o aplicativo em
telas de 320×640 até 1280×900, em paisagem e com fonte ampliada em 160%. Um
estouro de layout falha o teste automaticamente.

## Ícone do aplicativo

As artes de origem ficam em `assets/icone/` e não são empacotadas no APK:

- `ic_launcher.png` — ícone quadrado herdado, com o fundo já aplicado;
- `ic_launcher_frente.png` — camada frontal do ícone adaptativo (transparente);
- `ic_launcher_mono.png` — silhueta para o tema monocromático do Android 13+.

O fundo adaptativo é a cor `#16675E`, declarada em `pubspec.yaml`. Depois de
trocar qualquer uma das artes, regere as densidades:

```powershell
dart run flutter_launcher_icons
```

O gerador aplica um recuo de 16% na camada frontal, e o launcher recorta o
círculo visível de 72dp dentro dos 108dp. Na prática, o desenho precisa caber
em um círculo de aproximadamente 62% do lado da imagem, centralizado.

## APK debug

```powershell
flutter build apk --debug
```

Saída esperada:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Assinatura de release

O Android só instala uma atualização sobre a versão existente quando o
`applicationId` e a chave de assinatura são os mesmos. Perder a chave significa
não conseguir atualizar a instalação mantendo os dados.

Gere a chave uma única vez, fora do repositório:

```powershell
keytool -genkeypair -v `
  -keystore C:\CAMINHO-SEGURO\minha-medicacao-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias minha_medicacao
```

Copie `android/key.properties.example` para `android/key.properties` e preencha
o caminho, alias e senhas reais. Estes itens são ignorados pelo Git:

```text
android/key.properties
key.properties
*.jks
*.keystore
```

Guarde cópias externas seguras do `.jks`, do alias e das senhas. Não envie a
chave para o repositório, e-mail ou conversa. Para cada atualização, preserve a
chave e aumente o build após `+` no campo `version` do `pubspec.yaml`.

Se esta cópia já contém localmente `android/minha-medicacao-release.jks` e
`android/key.properties`, eles foram gerados para este aparelho e estão
ignorados pelo Git. Faça agora uma cópia segura dos dois; sem eles não será
possível assinar uma atualização compatível.

## APK release

Com `android/key.properties` configurado:

```powershell
flutter build apk --release
```

Saída esperada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Sem `android/key.properties`, o build release falha com uma mensagem explícita.
O projeto nunca usa silenciosamente a chave de debug para um APK release.

## Instalar no Moto G86

1. Transfira `app-release.apk` para o aparelho.
2. Autorize temporariamente “Instalar apps desconhecidos” para o gerenciador de
   arquivos usado.
3. Abra o APK e conclua a instalação.
4. Nas atualizações, instale o novo APK sobre o existente, sem desinstalar.
5. Confirme antes que `applicationId` e keystore continuam os mesmos.

Desinstalar o aplicativo apaga os dados privados locais. Gere e compartilhe um
backup antes de desinstalar ou trocar de aparelho.

## Permissões e lembretes

O aplicativo declara apenas permissões relacionadas aos lembretes:

- notificações (`POST_NOTIFICATIONS` em Android 13+);
- alarmes exatos para horários prescritos;
- recebimento do boot para restaurar agendamentos.

Câmera e galeria são acessadas somente por seletores do sistema quando a
usuária escolhe adicionar um anexo; não há permissão ampla de armazenamento.

Fotos, banco e backups locais ficam na área privada do aplicativo. O seletor de
arquivos Android (SAF) é usado para restaurar ZIPs, então não há permissão ampla
de armazenamento. O Android Auto Backup fica desabilitado para que dados de
medicação não saiam do aparelho sem uma ação explícita.

### Validar notificações

1. Abra **Configurações → Lembretes** e confirme notificações e alarmes exatos.
2. Cadastre um medicamento para alguns minutos à frente.
3. Bloqueie a tela e aguarde o lembrete.
4. Teste **Tomei**, **Adiar** e **Não tomei**; confira histórico e estoque.
5. Reinicie o aparelho e aguarde a próxima ocorrência.
6. Repita com economia de bateria habilitada.
7. Se houver atraso no Moto G86, remova a restrição de bateria para o aplicativo
   nas configurações do Android e repita o teste.

O sistema Android não garante alarmes depois de um “Forçar parada” manual até o
aplicativo ser aberto novamente. Isso é diferente de apenas fechar a tela.

## Backup

Em **Configurações → Backup → Criar backup**, o aplicativo:

1. cria um snapshot consistente do SQLite;
2. inclui anexos referenciados;
3. gera `manifest.json` com versão, tamanhos e SHA-256;
4. valida o ZIP;
5. abre o compartilhamento Android.

Escolha o Google Drive no painel de compartilhamento se desejar. Não existe API,
login ou credencial Google dentro do aplicativo. “Compartilhamento aberto” não
significa que o upload do aplicativo de destino já terminou; confira o arquivo
no Drive.

## Restaurar backup

1. Abra **Configurações → Backup → Restaurar backup**.
2. Selecione o ZIP pelo seletor Android; o Drive pode aparecer como origem.
3. Leia a confirmação: a restauração substituirá os dados atuais.
4. Aguarde validação de tipo, versão, hashes, SQLite e anexos.
5. Após o sucesso, confira medicamentos, agenda, estoque, histórico e fotos.

Antes de substituir dados, o aplicativo cria um backup de segurança. ZIP
incompatível, corrompido ou inseguro é rejeitado; uma falha restaura o estado
anterior. Após restore, os lembretes são reconstruídos do banco.

## Teste físico de aceite

No Moto G86 real, valide pelo menos:

- instalação e atualização do APK sem perda de dados;
- funcionamento totalmente offline;
- notificação com tela bloqueada, Doze, economia de bateria e reboot;
- confirmação duplicada sem segunda baixa de estoque;
- tratamento temporário após a data final e tratamento contínuo;
- intervalo atravessando meia-noite;
- reposição, ajuste e previsão de estoque;
- foto pela câmera e galeria;
- backup compartilhado para Drive e restauração completa.

## Privacidade e limites

Todos os dados permanecem localmente, salvo quando a usuária compartilha um
backup. Não há telemetria externa. O aplicativo não interpreta receitas, não
diagnostica e não recomenda compensar, dobrar ou alterar doses. Em caso de dúvida
sobre uma dose perdida, siga a orientação prescrita ou procure um profissional
de saúde.

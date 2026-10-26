# Documentação técnica — Minha Medicação

Para quem vai mexer no código. Quem só quer usar o aplicativo encontra tudo no
[README](README.md).

O aplicativo não tem conta, servidor, analytics nem integração clínica. O
SQLite local é a fonte da verdade, e a agenda da tela e os lembretes agendados
são sempre reconstruíveis a partir dele.

O `applicationId` é `br.com.minha_medicacao`. Não o altere: o Android só
atualiza por cima uma instalação com o mesmo identificador e a mesma chave.

## Ambiente

- **Flutter 3.44** / Dart 3.12. Versões mais novas do Flutter exigem `intl`
  acima da versão fixada no `pubspec.yaml` e o `flutter pub get` falha; ao
  atualizar o Flutter, ajuste essa dependência e rode a validação completa.
- Android SDK 36, command-line tools e Java 17.

```powershell
flutter doctor --android-licenses
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Executar e validar

```powershell
flutter run
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Os testes cobrem motor de agenda, recorrências, viradas de data, intervalo
ancorado, idempotência de doses, ledger de estoque, migrations, backup e
restauração, planejamento e ações dos lembretes, fluxos principais da
interface e layouts de 320×640 a 1280×900 com fonte ampliada em 160% — um
estouro de layout falha o teste.

## Banco e migrations

Os schemas versionados ficam em `drift_schemas/app_database/`: a versão 2
introduz datas civis para início e fim de tratamento, e a versão 3 a
recorrência por dias do calendário. Ambas migram sem perda.

Ao mudar o schema, incremente `versaoSchemaBancoAtual`, escreva a migration e
gere os artefatos. Como `schemaVersion` é lido de uma constante, o
`make-migrations` não infere a versão sozinho:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/core/banco/app_database.dart drift_schemas/app_database/drift_schema_vN.json
dart run drift_dev schema generate drift_schemas/app_database/ test/drift/app_database/generated/
```

Migrations que só acrescentam colunas usam `addColumn`. Quando a mudança
inclui constraint de tabela — que o SQLite não aceita via `ALTER TABLE` — a
tabela é reconstruída com `TableMigration`, com as chaves estrangeiras
desligadas e um `PRAGMA foreign_key_check` antes de religá-las. Sem isso, um
banco migrado ficaria diferente de um recém-criado, e o teste de migração
acusa a divergência.

Nunca resolva uma atualização apagando ou recriando o banco de quem usa.

## Regras de domínio

- **Confirmar dose é idempotente.** A mesma ocorrência gera um único registro e
  uma única baixa de estoque, na mesma transação. "Não tomei" não baixa
  estoque.
- **Estoque é um ledger.** Reposição e consumo são lançamentos; corrigir uma
  dose tomada por engano cria um estorno vinculado à saída original.
- **Ativar o controle de estoque depois** lança a quantidade informada como
  entrada inicial (ou ajuste, se já houver movimentações) e passa a exigir o
  consumo por dose enquanto houver tratamento ativo.
- **Excluir só existe sem histórico.** A exclusão apaga em transação,
  respeitando as chaves `RESTRICT`, na ordem adiamentos → movimentações →
  horários → tratamentos → anexos → medicamento; os arquivos das fotos saem
  depois do commit, tolerando falha. Com dose registrada,
  `MedicamentoRepository.excluir` lança `ExclusaoBloqueadaPorHistorico` e a
  tela oferece inativar.
- **Reativar um medicamento não reabre tratamentos encerrados.**

## Regras de agenda

Um tratamento tem um tipo de agendamento e, quando usa horários definidos, uma
recorrência de dias:

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
não existe no mês cai no último dia — dia 31 vira 28, 29 ou 30. Recorrência não
diária é incompatível com `intervalo`, que já governa a própria sequência a
partir da âncora.

Um tratamento contínuo com horários fixos e recorrência diária vira uma
notificação repetida todo dia, gastando um alarme por horário. Qualquer outra
recorrência usa ocorrências individuais, e o planejador salta direto para o
próximo dia aceito em vez de percorrer o calendário.

## Lembretes e permissões

O aplicativo declara apenas permissões ligadas aos lembretes:

- `POST_NOTIFICATIONS`, pedida na primeira abertura no Android 13+;
- alarme exato: `USE_EXACT_ALARM` no Android 13+, concedida na instalação, e
  `SCHEDULE_EXACT_ALARM` no Android 12. Sem alarme exato, os lembretes são
  agendados em modo inexato e o Android pode entregá-los até 1 hora depois;
- `RECEIVE_BOOT_COMPLETED`, para recolocar os lembretes após reiniciar.

A política do Google Play reserva `USE_EXACT_ALARM` a despertadores e agendas.
O aplicativo é distribuído pelo GitHub; para publicá-lo na Play, retire essa
permissão e dependa da concessão de `SCHEDULE_EXACT_ALARM` pela usuária.

Cada lembrete tem um identificador estável derivado da dose. A cada abertura e
retorno ao app, o serviço compara o que deveria estar agendado com o que está e
corrige a diferença, inclusive quando o fuso muda. Um "Forçar parada" manual
suspende os alarmes até o app ser aberto de novo.

Câmera, galeria e restauração de backup usam os seletores do sistema, então não
há permissão de câmera, fotos ou armazenamento. O Android Auto Backup fica
desligado para que dados de saúde não saiam do aparelho sem ação explícita.

## Backup e restauração

**Criar backup** gera um snapshot consistente do SQLite, inclui os anexos
referenciados, escreve um `manifest.json` com versão, tamanhos e SHA-256,
valida o ZIP e abre o compartilhamento do Android. Não há API nem login do
Google no aplicativo.

**Restaurar** valida tipo, versão, hashes, SQLite e anexos, recusa ZIP
corrompido, de versão futura ou com caminho para fora do destino, e cria um
backup de segurança antes de substituir os dados. Uma falha restaura o estado
anterior, e uma troca interrompida é recuperada antes de a interface abrir.
Depois da restauração, os lembretes são reconstruídos a partir do banco.

## Layout

| Largura | Uso típico | Navegação | Conteúdo |
| --- | --- | --- | --- |
| < 600dp | celular em retrato | barra inferior | uma coluna |
| 600–839dp | celular em paisagem, tablet pequeno | barra inferior | uma coluna centralizada |
| ≥ 840dp | tablet em paisagem | trilha lateral | até três colunas de cartões |

As faixas estão em `lib/app/layout.dart`. O conteúdo tem largura máxima, as
listas de cartões usam `Wrap` para nada ser cortado, e só os rótulos da barra
de navegação limitam a escala de fonte.

## Ícone

As artes ficam em `assets/icone/` (não vão no APK): o ícone quadrado, a camada
frontal do ícone adaptativo e a silhueta monocromática do Android 13+. O fundo
adaptativo é `#16675E`, no `pubspec.yaml`. Depois de trocar uma arte:

```powershell
dart run flutter_launcher_icons
```

O desenho precisa caber num círculo de cerca de 62% do lado da imagem,
centralizado.

## Assinatura e publicação

O Android só instala uma atualização com a mesma chave. Perder a chave
significa não conseguir atualizar a instalação de ninguém mantendo os dados.

Gere a chave uma única vez, fora do repositório, e guarde cópias seguras do
`.jks`, do alias e das senhas:

```powershell
keytool -genkeypair -v `
  -keystore C:\CAMINHO-SEGURO\minha-medicacao-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias minha_medicacao
```

Copie `android/key.properties.example` para `android/key.properties` e
preencha caminho, alias e senhas. Esses arquivos são ignorados pelo Git. Sem
eles, o build release falha com mensagem explícita — o projeto nunca assina um
release com a chave de debug.

Para publicar uma versão:

1. Aumente `version` no `pubspec.yaml` (nome e build, por exemplo `1.9.0+11`).
2. Rode a validação completa e gere o APK com `flutter build apk --release`.
3. Copie `build/app/outputs/flutter-apk/app-release.apk` para
   `Minha-Medicacao.apk` — o README aponta para esse nome.
4. Crie a release com as novidades escritas para quem usa:

   ```powershell
   gh release create v1.9.0 Minha-Medicacao.apk `
     --title "Minha Medicação 1.9.0" --notes-file NOVIDADES.md
   ```

## Teste manual em aparelho

Antes de publicar, valide num aparelho real:

- instalação por cima da versão anterior, sem perda de dados;
- lembrete com tela bloqueada, em Doze, com economia de bateria e após
  reiniciar;
- **Tomei**, **Adiar** e **Não tomei** pela notificação, conferindo histórico e
  estoque, e confirmação duplicada sem segunda baixa;
- tratamento temporário após a data final e intervalo atravessando a
  meia-noite;
- foto pela câmera e pela galeria;
- backup compartilhado para o Drive e restauração completa;
- funcionamento em modo avião.

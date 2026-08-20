# Ficha da Play Store — textos prontos

Rascunho para copiar no Play Console. Os limites de caracteres estão indicados;
os textos abaixo respeitam todos.

## Nome do app — 30 caracteres

```
Minha Medicação
```

*(15 caracteres. Se já existir um app com nome idêntico na loja, uma variação
como `Minha Medicação — Lembretes` ainda cabe, com 28.)*

## Descrição curta — 80 caracteres

```
Lembretes de remédio que funcionam offline, sem cadastro e sem anúncios.
```

*(72 caracteres. É o texto que aparece na busca, abaixo do nome — por isso
começa pelo benefício e não pelo nome do app.)*

## Descrição completa — 4000 caracteres

```
Um aplicativo simples para não esquecer os remédios.

Minha Medicação mostra o que você precisa tomar, em que horário e quanto. Avisa
na hora certa, mesmo com o celular bloqueado. E quando você confirma que tomou,
fica registrado — acabou aquela dúvida de "será que eu já tomei hoje?".

O QUE ELE FAZ

• Agenda do dia: o que tomar, a que horas e a quantidade certa
• Lembretes no horário, com as opções Tomei, Adiar e Não tomei no próprio aviso
• Registro do que já foi tomado, para não repetir a dose por esquecimento
• Controle de quantos comprimidos restam, com aviso antes de acabar
• Previsão de quando o estoque termina, com base nas próximas doses
• Histórico completo das doses tomadas e não tomadas
• Foto do medicamento e da receita, para não confundir caixas parecidas
• Cópia de segurança em arquivo, para trocar de celular sem perder nada

PARA QUALQUER ROTINA DE TRATAMENTO

• Uso contínuo, sem data para acabar
• Tratamento com data final, como um antibiótico de sete dias
• Horários fixos, como 08:00 e 20:00
• Intervalos, como a cada 8 horas
• Dias alternados, dias específicos da semana ou uma vez por mês

SEUS DADOS FICAM COM VOCÊ

Não existe conta, login nem servidor. Tudo o que você cadastra fica guardado
apenas no seu celular, e o aplicativo funciona sem internet — inclusive em modo
avião. Nenhuma informação é enviada para lugar nenhum, nem para quem
desenvolveu o aplicativo.

A única vez que algo sai do aparelho é quando você mesmo cria uma cópia de
segurança e escolhe compartilhá-la, por exemplo com o Google Drive.

SEM CUSTO E SEM ANÚNCIOS

O aplicativo é gratuito, não tem anúncios, não tem compras dentro do app e não
pede assinatura.

IMPORTANTE

Este aplicativo organiza, mas não orienta. Ele não indica medicamentos, não
calcula doses, não interpreta receitas e não diz o que fazer quando uma dose é
esquecida. Ele apenas lembra e registra o que você cadastrou, seguindo a
prescrição do seu médico.

Em caso de dúvida sobre um remédio ou sobre uma dose perdida, procure o
profissional de saúde que acompanha o tratamento.

PARA OS LEMBRETES FUNCIONAREM

Ao abrir pela primeira vez, permita o envio de notificações e o uso de alarmes
e lembretes. Se o seu celular tiver economia de bateria agressiva, vale liberar
o aplicativo nas configurações de bateria — é a causa mais comum de aviso
atrasado em qualquer app de lembrete.

O código do aplicativo é aberto e pode ser conferido por qualquer pessoa em
github.com/DEV-Peterson/minha_medicacao
```

*(Aproximadamente 2.100 caracteres, dentro do limite de 4.000.)*

## Categoria e classificação

| Campo | Valor sugerido |
| --- | --- |
| Categoria | Medicina |
| Tags | lembrete, saúde, medicamentos |
| Classificação de conteúdo | Livre — sem violência, sem conteúdo sexual, sem apostas |
| Público-alvo | 18 anos ou mais |
| Anúncios | Não contém anúncios |
| Compras no app | Não |
| Contas de usuário | O app não possui contas |
| Acesso para revisão | Todas as funções ficam disponíveis sem login |

## Segurança de dados — respostas do formulário

| Pergunta | Resposta |
| --- | --- |
| Coleta dados do usuário? | **Não** |
| Compartilha dados com terceiros? | **Não** |
| Os dados são criptografados em trânsito? | Não se aplica: não há transmissão |
| O usuário pode pedir exclusão dos dados? | Sim, desinstalando o app ou apagando dentro dele |
| Coleta dados de saúde? | **Não** — as informações ficam apenas no dispositivo e não são transmitidas |

> O formulário de Segurança de Dados trata de **coleta e transmissão**, não de
> armazenamento local. Como nada sai do aparelho, a resposta correta é que não
> há coleta. A explicação sobre o armazenamento local vai na política de
> privacidade.

## Declaração de app de saúde

O app se enquadra em **gerenciamento de medicamentos**. Pontos a declarar:

- não é dispositivo médico e não faz afirmações clínicas;
- não fornece diagnóstico, prescrição ou orientação de dose;
- destina-se a organização pessoal de tratamento já prescrito;
- não é destinado a profissionais de saúde nem a uso institucional.

## Justificativa da permissão de alarme exato

Texto para o formulário de permissões restritas, ao declarar
`USE_EXACT_ALARM`:

```
A função central do aplicativo é lembrar o usuário de tomar medicamentos em
horários prescritos. Um lembrete de medicação entregue fora do horário perde a
utilidade e pode induzir o usuário a tomar a dose no momento errado, por isso o
aplicativo agenda notificações no horário exato definido pelo próprio usuário
ao cadastrar o tratamento.

Os alarmes são todos criados a partir de horários que o usuário cadastra
explicitamente e correspondem a eventos visíveis para ele: cada alarme gera uma
notificação com o nome do medicamento e a quantidade a ser tomada. O aplicativo
não usa alarmes exatos para nenhuma finalidade em segundo plano, não realiza
sincronização, não coleta dados e não possui servidor.
```

## Links obrigatórios

| Campo | Endereço |
| --- | --- |
| Política de privacidade | `https://dev-peterson.github.io/minha_medicacao/politica-de-privacidade` |
| E-mail de suporte | `petersonmarinho07@hotmail.com` |
| Site (opcional) | `https://github.com/DEV-Peterson/minha_medicacao` |

## Capturas de tela — roteiro sugerido

Mínimo de 2, ideal 5 a 8. Tire no aparelho com dados realistas já cadastrados,
**depois** dos ajustes de tema escuro (senão você refaz).

1. **Hoje** com a próxima dose destacada e duas ou três doses no dia
2. **Hoje** com uma dose já confirmada, mostrando "Tomada às 08:07"
3. **Estoque** com um item em "Precisa repor em breve"
4. **Medicamentos** com dois ou três remédios cadastrados
5. **Histórico** com dias agrupados
6. **Cadastro** no passo de horários, mostrando a repetição semanal
7. Uma captura no **tema escuro**, para quem usa o celular à noite

Para distribuição em tablets, repetir as principais em 7" e 10".

# Atlas AI — Fundação do Produto

> Documento vivo para registrar o papel da inteligência artificial no Atlas. A arquitetura técnica e o modelo de execução serão detalhados em uma etapa posterior.

## Missão

A IA do Atlas não será um chatbot colocado ao lado de um aplicativo financeiro. Ela será uma **camada de inteligência do produto**, capaz de transformar dados financeiros e de compras em contexto, explicações e ações úteis.

O princípio central é:

> O Atlas não deve apenas mostrar números. Deve ajudar o usuário a entender o que esses números significam.

## O que a IA deve entender

Conforme o usuário autorizar e os módulos forem implementados, a IA poderá trabalhar sobre:

- receitas e despesas;
- categorias;
- contas e cartões;
- recorrências;
- histórico mensal;
- notas fiscais e recibos processados;
- produtos comprados;
- preços históricos;
- estabelecimentos;
- metas financeiras;
- dados sincronizados por Open Finance.

## Capacidades planejadas

### 1. Conversa financeira

Permitir perguntas em linguagem natural, por exemplo:

- Quanto eu gastei este mês?
- Onde eu mais gastei?
- Quanto gastei com alimentação nos últimos três meses?
- Minhas despesas aumentaram?
- Quanto tenho comprometido até o próximo pagamento?

### 2. Explicação

A IA deve explicar alterações relevantes, como:

- aumento de gastos em uma categoria;
- despesa incomum;
- mudança no padrão mensal;
- aumento recorrente de determinado produto;
- concentração de gastos em determinado estabelecimento.

### 3. Insights proativos

O Atlas poderá gerar cards e alertas quando encontrar algo realmente útil.

Exemplos:

- "Seus gastos com delivery estão maiores que sua média recente."
- "Este produto ficou mais caro nas últimas compras."
- "Você tem pagamentos relevantes previstos para os próximos dias."

A IA não deve inundar a Home com observações irrelevantes.

### 4. Compras inteligentes

Quando o histórico de produtos estiver disponível, a IA poderá:

- identificar evolução de preços;
- comparar locais onde o usuário já comprou;
- destacar produtos com aumento relevante;
- ajudar a planejar compras com base no histórico disponível.

### 5. Organização assistida

A IA poderá sugerir:

- categoria provável de uma transação;
- associação entre uma movimentação bancária e uma compra/nota;
- correções em dados extraídos por OCR;
- identificação de recorrências.

Sugestão automática não significa alteração automática. Ações que modificam dados devem seguir regras explícitas de confirmação e confiança.

## Atlas AI na interface

A IA poderá aparecer em diferentes superfícies:

- área dedicada de conversa;
- cards de insight na Home;
- explicações dentro de relatórios;
- sugestões contextuais em transações;
- análise de compras e preços;
- alertas relevantes.

Isso evita concentrar toda a inteligência em uma única tela de chat.

## Personalidade

A IA deve ser:

- clara;
- objetiva;
- útil;
- respeitosa;
- sem julgamento moral sobre gastos;
- transparente quando não possuir dados suficientes.

Evitar frases alarmistas e culpabilizantes. O Atlas informa e ajuda a decidir; não repreende o usuário.

## Confiança e explicabilidade

Quando fizer uma afirmação sobre as finanças do usuário, o Atlas deve preferir conclusões verificáveis pelos próprios dados.

Exemplo:

> "Você gastou mais com restaurantes este mês porque foram registradas 8 compras, contra 4 no mês anterior."

Sempre que útil, a interface deve permitir chegar aos dados/transações que sustentam um insight.

## Limites

A IA não deve:

- inventar transações ou valores ausentes;
- afirmar certeza quando os dados forem incompletos;
- executar movimentações bancárias silenciosamente;
- alterar registros importantes sem consentimento adequado;
- tratar previsões como fatos;
- apresentar aconselhamento financeiro de alto risco como garantia de resultado.

## Privacidade

O princípio será **mínimo dado necessário**.

A arquitetura deverá separar:

1. dados financeiros armazenados;
2. camada de regras/cálculos determinísticos;
3. contexto estritamente necessário enviado ao modelo de IA;
4. resposta apresentada ao usuário.

Informações sensíveis não devem ser enviadas indiscriminadamente ao modelo.

## IA + cálculos determinísticos

O modelo de linguagem não deve ser a fonte de verdade para saldos, somatórios e cálculos financeiros.

Fluxo ideal:

1. backend consulta os dados autorizados;
2. serviços determinísticos calculam valores e métricas;
3. IA recebe resultados estruturados e contexto relevante;
4. IA interpreta/explica;
5. interface apresenta a resposta e, quando aplicável, suas evidências.

Assim, a IA funciona como cérebro interpretativo sem substituir o motor financeiro.

## Arquitetura futura

Será especificada separadamente, incluindo:

- provedor/modelos;
- function/tool calling;
- permissões;
- memória e contexto;
- classificação de intenções;
- geração de insights;
- custo e limites;
- proteção contra prompt injection;
- auditoria;
- política de retenção;
- fallback quando IA estiver indisponível.

## Princípio de produto

**IA é uma capacidade transversal do Atlas, não um enfeite.**

Cada recurso de IA deverá responder a pelo menos uma destas perguntas:

- Isso ajuda o usuário a entender melhor suas finanças?
- Isso reduz trabalho manual?
- Isso revela informação que seria difícil perceber sozinho?
- Isso ajuda o usuário a tomar uma decisão melhor usando seus próprios dados?

Se não responder a nenhuma delas, provavelmente não precisa de IA.

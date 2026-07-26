# Atlas Finance — Fluxos de UX e Telas

Este documento detalha como as partes principais do aplicativo devem funcionar. Ele complementa `APP_STRUCTURE.md`.

## 1. Home / Dashboard

A Home é o centro de comando financeiro do Atlas.

### Conteúdo principal

- saldo atual;
- receitas do período;
- despesas do período;
- próximos vencimentos;
- objetivos/metas;
- resumo/gráfico mensal;
- atalhos para ações frequentes;
- acesso rápido para adicionar transação.

### Comportamento

A tela deve responder rapidamente às perguntas:

- Quanto eu tenho?
- Quanto entrou?
- Quanto saiu?
- Com o que estou gastando?
- O que está para vencer?
- Como este mês está comparado ao meu histórico?

O dashboard deve evoluir progressivamente conforme novos módulos forem implementados, sem exigir que todos estejam prontos no MVP.

---

## 2. Nova transação

Esta é uma das telas prioritárias da primeira experiência funcional do Atlas.

### Tipos

- despesa;
- receita;
- transferência.

### Informações

O fluxo deve permitir informar, conforme o tipo:

- valor;
- descrição;
- categoria;
- conta ou cartão;
- data;
- observações;
- recorrência, quando suportada.

### UX

- valor deve receber destaque visual;
- tipo da transação deve ser fácil de alternar;
- categorias devem ser rápidas de selecionar;
- campos secundários não devem competir com o valor e a categoria;
- salvar deve ser uma ação inequívoca;
- após salvar, o dashboard e o histórico devem refletir a alteração.

---

## 3. Histórico de transações

### Objetivo

Permitir entender e localizar movimentações passadas sem transformar a tela em uma planilha pesada.

### Recursos planejados

- lista cronológica;
- busca;
- filtros por período;
- filtros por categoria;
- filtros por tipo;
- filtros por conta/cartão;
- agrupamento por data quando fizer sentido;
- acesso aos detalhes da transação.

---

## 4. Detalhes da transação

Ao tocar em uma movimentação, o usuário deve conseguir visualizar os dados completos e, quando permitido:

- editar;
- excluir;
- consultar categoria;
- consultar origem/conta/cartão;
- visualizar observações;
- identificar se foi manual, sincronizada ou originada de outro módulo futuramente.

---

## 5. Contas e cartões

O Atlas deve concentrar diferentes fontes financeiras sem confundi-las.

### Contas

- conta bancária;
- dinheiro/carteira;
- outras carteiras suportadas futuramente.

### Cartões

Devem possuir contexto próprio para permitir evolução posterior para:

- limite;
- fatura;
- vencimento;
- fechamento;
- transações vinculadas.

A integração via Open Finance será adicionada progressivamente. Cadastro manual continua importante para o MVP.

---

## 6. Categorias

Categorias organizam despesas e receitas e alimentam relatórios futuros.

Devem ser:

- reconhecíveis visualmente;
- fáceis de selecionar;
- reutilizáveis em filtros;
- preparadas para categorias padrão e personalizadas.

---

## 7. Compras e scanner

O módulo de compras diferencia o Atlas de um controle financeiro comum.

Fluxo futuro:

1. usuário escaneia nota fiscal ou recibo;
2. OCR/extrator identifica itens, preços, estabelecimento e data;
3. usuário confirma/corrige informações quando necessário;
4. itens entram no histórico de compras;
5. Atlas relaciona compra e movimentação financeira quando possível;
6. preços passam a alimentar histórico e comparação.

O sistema não deve assumir silenciosamente que uma leitura automática está correta quando houver baixa confiança.

---

## 8. Histórico e comparação de preços

Para um produto reconhecido, o Atlas deverá permitir visualizar:

- compras anteriores;
- preço pago em cada compra;
- estabelecimento;
- data;
- evolução do preço;
- comparação entre estabelecimentos quando houver dados suficientes.

O objetivo é responder não apenas **quanto o usuário gastou**, mas também **quanto as coisas que ele compra estão custando ao longo do tempo**.

---

## 9. Open Finance

Área destinada a:

- bancos conectados;
- estado da sincronização;
- consentimentos;
- origem das movimentações.

O usuário nunca deve fornecer senha bancária diretamente ao Atlas. Credenciais e consentimentos devem seguir o fluxo seguro dos provedores autorizados e as regras descritas em `SECURITY.md`.

---

## 10. Inteligência Artificial

A IA será uma camada de interpretação sobre dados financeiros e de compras.

Exemplos de perguntas futuras:

- Onde meu dinheiro foi gasto este mês?
- Em quais categorias meus gastos aumentaram?
- Quais produtos ficaram mais caros?
- Onde eu poderia economizar?

Respostas devem indicar os dados que fundamentaram a conclusão sempre que isso ajudar o usuário a entender a recomendação.

---

## 11. Ordem de construção visual

Backlog inicial de telas:

1. Home evoluída;
2. Nova transação;
3. Histórico de transações;
4. Detalhes da transação;
5. Contas e cartões;
6. Categorias.

A tela **Nova transação** é uma boa próxima peça para fechar o primeiro fluxo real: `Home → Nova transação → Salvar → Home/Histórico`.

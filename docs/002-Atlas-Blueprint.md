# Atlas Finance

# Documento 002

# Atlas Blueprint

**Versão:** 1.0.0 (Draft)

**Status:** Oficial

---

# Visão Geral

O Atlas Finance é uma plataforma de inteligência financeira pessoal.

Seu objetivo não é apenas registrar receitas e despesas, mas transformar dados financeiros em contexto, compreensão e decisão melhor.

O Atlas deve funcionar como um copiloto financeiro, com base em dados verificáveis, regras determinísticas e inteligência interpretativa.

---

# Missão do Produto

Dar ao usuário controle real sobre sua vida financeira por meio de organização, automação, análise e inteligência.

---

# Objetivos do Produto

O Atlas deverá permitir:

- controlar contas;
- acompanhar saldo e patrimônio;
- registrar receitas e despesas;
- organizar cartões e parcelas;
- classificar transações;
- acompanhar metas e orçamentos;
- analisar hábitos de consumo;
- acompanhar compras e preços históricos;
- integrar Open Finance no futuro;
- utilizar IA para interpretação financeira.

---

# Princípios do Produto

- O usuário é dono dos dados.
- A IA interpreta, nunca inventa.
- Cálculos financeiros são determinísticos.
- Privacidade é requisito, não diferencial.
- Transparência é obrigatória.
- Performance é parte da experiência.
- Offline First sempre que possível.

---

# Estrutura de Alto Nível

O Atlas será composto por camadas e features independentes.

```text
Presentation
↓
Application
↓
Domain
↓
Infrastructure
↓
Data Sources
```

---

# Organização por Features

Cada feature será isolada e responsável por seu próprio contexto funcional.

Exemplos de features:

- dashboard
- accounts
- cards
- transactions
- categories
- budgets
- goals
- shopping
- receipts
- reports
- subscriptions
- notifications
- atlas_ai
- settings

Cada feature poderá conter:

- presentation/
- domain/
- data/

---

# Núcleo Financeiro

O Atlas possuirá um núcleo matemático central chamado **Financial Engine**.

Esse núcleo será a única fonte da verdade para cálculos financeiros.

Responsabilidades:

- saldo;
- patrimônio;
- juros;
- parcelas;
- recorrências;
- projeções;
- indicadores;
- estatísticas;
- validações financeiras.

Nenhuma feature poderá recalcular essas informações por conta própria.

---

# Atlas AI

A Atlas AI será uma camada interpretativa.

Ela não calcula saldo.
Ela não altera registros.
Ela não cria transações.
Ela não substitui regras financeiras.

Seu papel é:

- explicar;
- contextualizar;
- encontrar padrões;
- gerar insights verificáveis;
- responder perguntas em linguagem natural.

---

# Context Builder

Antes de qualquer prompt chegar ao modelo, o Atlas deverá preparar um contexto seguro e controlado.

Responsabilidades:

- anonimizar dados sensíveis quando necessário;
- agregar informação;
- filtrar ruído;
- reduzir exposição de dados;
- fornecer contexto estruturado.

A IA nunca terá acesso direto ao banco de dados.

---

# Modelo de Dados de Alto Nível

Entidades principais esperadas:

- User
- Account
- Card
- Transaction
- Category
- Budget
- Goal
- Merchant
- ShoppingItem
- Receipt
- PriceHistory
- Subscription
- Insight
- Notification

---

# Fluxos Principais

## 1. Dashboard

O Dashboard será a tela inicial do Atlas.

Deverá exibir rapidamente:

- saldo consolidado;
- resumo do mês;
- transações recentes;
- próximos pagamentos;
- insights úteis;
- atalhos para ações frequentes.

## 2. Contas

Permite criar, editar e acompanhar contas financeiras.

## 3. Transações

Permite registrar entradas, saídas, transferências e recorrências.

## 4. Compras

Permite registrar itens comprados, associar notas fiscais e acompanhar preços.

## 5. Relatórios

Permite visualizar tendências, categorias, comparativos e evolução financeira.

## 6. Atlas AI

Permite conversar sobre dados financeiros e receber interpretações e insights.

---

# Offline First

O Atlas deverá continuar útil mesmo sem conexão.

Operações locais deverão funcionar normalmente quando possível.

Sincronizações com serviços externos ocorrerão posteriormente.

---

# Open Finance

A integração com Open Finance será tratada como fonte adicional de dados, nunca como substituição automática das informações do usuário.

O usuário sempre deverá manter controle sobre o que entra no sistema.

---

# OCR

O OCR será usado para capturar informações de documentos, recibos e notas fiscais.

Toda informação extraída precisará de validação antes de se tornar dado confiável do sistema.

---

# Design System

Identidade visual do Atlas:

- tema escuro predominante;
- verde Atlas como cor principal;
- Poppins como tipografia;
- cards arredondados;
- interface limpa;
- hierarquia visual clara.

---

# Roadmap

## v1

- Dashboard
- Contas
- Transações
- Categorias
- Relatórios

## v2

- Cartões
- Open Finance
- OCR
- Compras

## v3

- Atlas AI
- Insights avançados
- Histórico de preços

## v4

- Planejamento financeiro
- Projeções
- Recomendações inteligentes

---

# Restrições de Produto

- Não misturar regras de negócio com UI.
- Não duplicar cálculos financeiros em features.
- Não permitir IA como fonte da verdade.
- Não usar `double` para valores monetários.
- Não quebrar a independência entre features.

---

# Encerramento

O Atlas Blueprint descreve o que o Atlas é, o que ele deve oferecer e como suas grandes áreas se conectam.

Ele serve como ponte entre a linguagem oficial do projeto e sua implementação técnica.

Fim do Documento.

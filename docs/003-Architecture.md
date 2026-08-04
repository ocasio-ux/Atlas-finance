# Atlas Finance

# Documento 003

# Architecture Specification

**Versão:** 1.0.0 (Draft)

**Status:** Oficial

---

# 1. Objetivo

Este documento define a arquitetura técnica do Atlas Finance.

Ele descreve como o sistema é organizado, como as camadas se relacionam e quais regras estruturais devem ser seguidas por todo o código-fonte.

Caso exista conflito entre implementação e este documento, a arquitetura documentada prevalece.

---

# 2. Arquitetura Base

O Atlas adota uma combinação de:

- Feature-First
- Clean Architecture
- Offline First
- Domain-Driven Design em nível conceitual

A estrutura do projeto será organizada por funcionalidades independentes, com separação clara entre apresentação, domínio e dados.

---

# 3. Princípios Arquiteturais

## 3.1 Separação de responsabilidades

Cada camada deve possuir uma responsabilidade principal.

- Presentation: exibir e coletar interação.
- Domain: conter regras de negócio.
- Data: acessar e persistir dados.
- Infrastructure: integrar serviços externos e tecnologias concretas.

## 3.2 Fonte única da verdade

Regras financeiras pertencem ao Financial Engine.

A interface nunca calcula valores finais.

## 3.3 Independência de features

Features devem ser isoladas entre si.

A comunicação entre módulos deve ocorrer por contratos, serviços centrais ou eventos de domínio, nunca por dependências diretas entre camadas de dados.

## 3.4 Determinismo financeiro

Valores financeiros devem ser calculados de forma determinística.

Nenhum cálculo monetário deve depender de ponto flutuante.

## 3.5 Privacidade por padrão

Dados sensíveis devem ser tratados localmente sempre que possível.

A IA deve receber apenas o contexto mínimo necessário.

---

# 4. Estrutura de Pastas

A estrutura base do projeto deverá seguir este padrão:

```text
lib/
├── app/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── finance/
│   ├── navigation/
│   ├── services/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── accounts/
│   ├── atlas_ai/
│   ├── cards/
│   ├── categories/
│   ├── dashboard/
│   ├── goals/
│   ├── reports/
│   ├── shopping/
│   ├── subscriptions/
│   ├── transactions/
│   └── settings/
└── shared/
```

Cada feature poderá conter, quando necessário:

```text
feature_name/
├── data/
├── domain/
└── presentation/
```

---

# 5. Camadas

## 5.1 Presentation

Responsável por UI, interação, estado visual e navegação de tela.

Regras:

- não acessar banco diretamente;
- não conter regras financeiras;
- não calcular totais finais;
- não conversar com APIs sem mediação de serviços ou use cases.

## 5.2 Domain

Responsável por regras de negócio, entidades, value objects e casos de uso.

Regras:

- não depender de Flutter;
- não depender de banco de dados;
- não depender de SDKs de UI;
- conter a verdade do domínio financeiro.

## 5.3 Data

Responsável por repositórios concretos, fontes locais, mapeamentos e persistência.

Regras:

- converter dados externos para o modelo interno;
- não conter lógica financeira de negócio;
- não decidir o significado dos dados;
- apenas transportar, transformar e persistir.

## 5.4 Infrastructure

Responsável por integrações técnicas como:

- banco local;
- Open Finance;
- OCR;
- armazenamento seguro;
- serviços de rede;
- IA;
- logging técnico.

---

# 6. Núcleo Financeiro

O Atlas deve possuir um núcleo financeiro centralizado dentro de `core/finance`.

Este núcleo será responsável por cálculos e regras compartilhadas entre features.

Funções esperadas:

- cálculo de saldo;
- patrimônio;
- projeções;
- juros;
- parcelas;
- recorrências;
- validações monetárias;
- conversões de valores;
- agregações financeiras globais.

Nenhuma feature poderá duplicar essas regras.

---

# 7. Comunicação Entre Features

A comunicação entre features deverá seguir estas regras:

1. Preferir dependência de abstrações do domínio.
2. Quando necessário, usar eventos de domínio ou serviços centrais.
3. Evitar importações diretas entre camadas de data de features diferentes.
4. Evitar circularidade entre módulos.

Exemplo:

- Transactions pode publicar um evento de criação.
- Accounts pode reagir a esse evento para atualizar estado derivado.
- Dashboard pode consumir o resultado consolidado.

---

# 8. Gerenciamento de Estado

O padrão de estado será definido em detalhe posterior, mas a regra arquitetural é clara:

- estado visual pertence à Presentation;
- estado de domínio pertence aos use cases e entidades;
- estado persistido pertence ao banco local;
- estado remoto pertence às fontes externas autorizadas.

A UI nunca deve ser a fonte da verdade.

---

# 9. Navegação

A navegação deverá ser centralizada e previsível.

Requisitos:

- rotas nomeadas ou estrutura equivalente;
- separação entre navegação global e navegação de feature;
- suporte a fluxo simples e fluxo profundo;
- integração futura com autenticação e sincronização.

---

# 10. Injeção de Dependências

O Atlas deverá usar um mecanismo de injeção de dependências adequado ao ecossistema Flutter.

Regras:

- dependências devem ser declaradas de forma explícita;
- implementações concretas devem ser substituíveis por mocks em testes;
- o domínio não deve conhecer o contêiner de DI;
- a configuração deve acontecer na borda da aplicação.

---

# 11. Offline First

A arquitetura deve assumir funcionamento offline como comportamento padrão.

Consequências:

- dados locais são prioritários;
- sincronização acontece em segundo plano;
- falhas de rede não podem impedir operações básicas;
- conflitos devem ser tratados por estratégia documentada.

---

# 12. Banco de Dados

O banco local será especificado em documento próprio.

A arquitetura, porém, já estabelece:

- persistência relacional;
- suporte a transações ACID;
- capacidade de consultas agregadas;
- migrações versionadas;
- criptografia quando aplicável.

---

# 13. Dados Monetários

Valores financeiros devem ser tratados com precisão fixa.

Regras:

- nunca usar double para dinheiro;
- representar valores de forma determinística;
- encapsular operações monetárias em value objects;
- centralizar conversões e arredondamentos.

---

# 14. IA e Contexto

A Atlas AI nunca acessará o banco diretamente.

O fluxo correto é:

1. dados são lidos das fontes autorizadas;
2. o domínio consolida e valida;
3. o Context Builder sanitiza e agrega;
4. a IA interpreta o contexto;
5. a interface apresenta a resposta.

A IA não pode violar privacidade nem substituir regras de negócio.

---

# 15. Testabilidade

Toda regra crítica deve ser testável sem UI.

Requisitos:

- use cases isolados;
- value objects testáveis;
- repositórios mockáveis;
- cálculos financeiros cobertos por testes unitários;
- integrações cobertas por testes de contrato ou integração quando necessário.

---

# 16. Evolução Arquitetural

Mudanças permanentes na arquitetura devem ser registradas em ADRs.

A arquitetura não deve mudar por conveniência momentânea.

Qualquer mudança que afete persistência, cálculo financeiro, segurança ou comunicação entre módulos deve ser documentada antes de ser codificada.

---

# 17. Resumo das Regras Inflexíveis

- Features são independentes.
- A UI não contém regras financeiras.
- O Financial Engine é a fonte da verdade para cálculos.
- A IA interpreta, não calcula.
- O banco local serve ao domínio, nunca o contrário.
- Valores monetários exigem precisão fixa.
- Offline First é obrigatório.
- Decisões importantes exigem ADR.

---

# Encerramento

A arquitetura do Atlas foi desenhada para suportar evolução de longo prazo, consistência financeira, privacidade, rastreabilidade e colaboração entre múltiplas IAs e desenvolvedores.

Este documento deve ser lido como a fundação técnica do projeto.

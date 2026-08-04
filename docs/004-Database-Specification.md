# Atlas Finance

# Documento 004

# Database Specification

**Versão:** 1.0.0 (Draft)

**Status:** Oficial

---

# 1. Objetivo

Este documento define os princípios, a estrutura conceitual e as diretrizes de persistência do Atlas Finance.

O banco de dados existe para armazenar, consultar e preservar com integridade os dados financeiros do usuário.

Ele não define regras de negócio. Regras pertencem ao Financial Engine.

---

# 2. Princípios

A persistência do Atlas deverá seguir os seguintes princípios:

- integridade dos dados;
- consistência;
- determinismo;
- consultas eficientes;
- suporte a relatórios;
- offline first;
- segurança;
- evolutividade.

---

# 3. Diretrizes Arquiteturais

A camada de dados deverá ser separada da camada de domínio.

O banco de dados não deverá ser acessado diretamente pela interface.

Toda leitura e escrita deverá passar por repositórios e serviços definidos pela arquitetura.

---

# 4. Estratégia de Persistência

A persistência local do Atlas deverá ser relacional.

A estratégia deverá privilegiar:

- consultas analíticas;
- relacionamentos explícitos;
- transações atômicas;
- migrações versionadas;
- integridade referencial.

---

# 5. Entidades Principais

As entidades mínimas previstas para o Atlas são:

- User
- Account
- Card
- Transaction
- Category
- Merchant
- Product
- Purchase
- Receipt
- Budget
- Goal
- Recurrence
- Installment
- Insight
- Notification
- SyncEvent
- AuditLog

---

# 6. Requisitos de Modelo

Cada entidade deverá possuir, quando aplicável:

- id;
- createdAt;
- updatedAt.

Entidades financeiras relevantes também deverão manter:

- status;
- source;
- sync metadata;
- audit metadata.

---

# 7. Regras de Dinheiro

Valores monetários não deverão ser armazenados em tipos de ponto flutuante.

Representações monetárias deverão ser precisas e auditáveis.

Toda modelagem de dinheiro deverá respeitar os ADRs oficiais do projeto.

---

# 8. Relacionamentos

O banco deverá representar explicitamente os relacionamentos entre:

- contas e transações;
- cartões e transações;
- categorias e transações;
- compras e produtos;
- recibos e compras;
- recorrências e transações futuras;
- metas e eventos financeiros.

---

# 9. Índices

O banco deverá possuir índices para consultas frequentes, incluindo:

- transações por data;
- transações por conta;
- transações por categoria;
- transações por cartão;
- compras por estabelecimento;
- produtos por histórico de preço;
- eventos de sincronização.

---

# 10. Migrações

Toda mudança estrutural no banco deverá ser versionada.

Migrações deverão ser seguras, reversíveis quando possível e documentadas.

---

# 11. Segurança

A persistência deverá considerar:

- criptografia em repouso quando adotada pelo projeto;
- proteção de credenciais e tokens;
- isolamento de dados sensíveis;
- trilha de auditoria.

---

# 12. Offline First

O banco local é a base da experiência offline.

Toda funcionalidade essencial deverá continuar operando sem conexão.

---

# 13. Sincronização

A sincronização com fontes externas deverá ser tratada como camada complementar.

Conflitos deverão ser resolvidos por regras explícitas definidas em documentação própria.

---

# 14. Auditoria

Eventos relevantes deverão ser registráveis para fins de rastreabilidade.

A auditoria deverá permitir reconstruir decisões importantes do sistema sempre que necessário.

---

# 15. Observações

Este documento é intencionalmente conceitual.

A implementação concreta do banco, das tabelas e dos DAOs será detalhada em documentos técnicos e ADRs específicos.

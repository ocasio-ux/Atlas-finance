# Atlas Finance

# Documento 000

# Atlas Lexicon

Versão: 1.0.0

Status: Draft

Última atualização: Agosto de 2026

---

# 1. Introdução

O Atlas Lexicon é o documento responsável por definir a linguagem oficial do Atlas Finance.

Seu objetivo é eliminar ambiguidades entre documentação, código, banco de dados, interface, inteligência artificial e regras de negócio.

Todo conceito utilizado no projeto deverá seguir rigorosamente este documento.

Caso exista conflito entre implementação e Lexicon, o Lexicon prevalece.

---

# 2. Objetivos

O Atlas Lexicon existe para:

- padronizar conceitos;
- reduzir ambiguidades;
- facilitar comunicação entre desenvolvedores;
- facilitar comunicação entre IAs;
- garantir consistência arquitetural;
- servir como base para toda documentação futura.

---

# 3. Hierarquia da Documentação

A documentação do Atlas possui a seguinte ordem de prioridade.

1. Atlas Lexicon
2. Atlas Constitution
3. Architecture Decision Records (ADR)
4. Atlas Blueprint
5. Architecture Specification
6. Database Specification
7. Design System
8. Atlas AI Specification
9. API Specification
10. Código Fonte

---

# 4. Regras do Lexicon

Toda definição presente neste documento é considerada oficial.

Nenhum documento poderá redefinir conceitos já existentes.

Novos conceitos somente poderão ser adicionados mediante atualização deste documento.

---

# 5. Domínio Principal

## Usuário (User)

Pessoa proprietária dos dados financeiros.

Todos os dados pertencem ao usuário.

O Atlas apenas organiza essas informações.

---

## Conta (Account)

Representa um local onde recursos financeiros podem existir.

Exemplos:

- Conta Corrente
- Conta Poupança
- Carteira Digital
- Dinheiro em Espécie
- Conta Investimento

Uma conta representa patrimônio.

Uma conta nunca representa um cartão.

---

## Banco

Instituição financeira.

Um banco pode possuir diversas contas.

Uma conta pode existir sem banco.

---

## Cartão (Card)

Instrumento utilizado para realizar pagamentos.

Um cartão não representa patrimônio.

Um cartão pode possuir:

- limite
- fechamento
- vencimento
- parcelas
- bandeira

---

## Transação (Transaction)

Registro permanente de uma movimentação financeira.

Uma transação altera o estado financeiro.

Uma transação nunca representa saldo.

Tipos:

- Receita
- Despesa
- Transferência
- Ajuste
- Estorno

---

## Receita

Movimentação financeira que aumenta patrimônio.

---

## Despesa

Movimentação financeira que reduz patrimônio ou disponibilidade.

---

## Transferência

Movimentação entre contas pertencentes ao mesmo usuário.

Transferências nunca alteram patrimônio.

---

## Categoria

Forma de classificação das transações.

Categorias não armazenam dinheiro.

Categorias não alteram cálculos.

---

## Estabelecimento (Merchant)

Empresa ou local onde ocorreu uma compra.

Exemplos:

- Supermercado
- Farmácia
- Restaurante
- Marketplace

---

## Produto

Item adquirido em uma compra.

Um produto pode aparecer diversas vezes no histórico do usuário.

---

## Compra

Conjunto de produtos adquiridos em uma mesma operação comercial.

Uma compra pode gerar:

- uma transação
- diversas parcelas
- uma nota fiscal

---

## Nota Fiscal

Documento oficial de uma compra.

Nunca altera automaticamente os dados do usuário.

---

## OCR

Processo responsável por transformar documentos em informações estruturadas.

Toda informação extraída deverá passar por validação.

---

# 6. Conceitos Financeiros

## Saldo

Valor disponível em uma conta.

O saldo nunca é informado manualmente.

O saldo é calculado pelo Financial Engine.

---

## Patrimônio

Diferença entre ativos e passivos.

Patrimônio não representa dinheiro disponível.

---

## Disponibilidade

Valor imediatamente utilizável.

Pode ser diferente do saldo.

Pode ser diferente do patrimônio.

---

## Limite

Valor máximo disponível em um cartão.

Nunca representa patrimônio.

---

## Parcela

Divisão temporal de uma obrigação financeira.

Cada parcela possui:

- valor
- vencimento
- status

---

## Recorrência

Regra responsável por gerar transações futuras.

Recorrência não é transação.

Recorrência produz transações.

---

## Meta

Objetivo financeiro definido pelo usuário.

Metas nunca movimentam dinheiro automaticamente.

---

## Orçamento

Planejamento financeiro.

Serve como referência.

Nunca impede movimentações.

---

# 7. Núcleo do Atlas

## Financial Engine

O Financial Engine é o núcleo matemático do Atlas.

Toda regra financeira pertence exclusivamente a ele.

Responsabilidades:

- cálculo de saldo;
- patrimônio;
- juros;
- parcelas;
- recorrências;
- projeções;
- estatísticas;
- indicadores;
- validações financeiras.

Nenhum outro módulo poderá recalcular essas informações.

O Financial Engine é a única fonte da verdade para cálculos.

---

# 8. Inteligência Artificial

## Atlas AI

Camada responsável por interpretar informações produzidas pelo sistema.

Nunca deverá:

- calcular saldo;
- calcular patrimônio;
- alterar registros;
- criar transações;
- modificar valores financeiros.

Seu papel é exclusivamente interpretar, explicar e orientar.

---

## Context Builder

Componente responsável por preparar informações para a IA.

Responsabilidades:

- anonimização;
- agregação;
- filtragem;
- contextualização.

A IA nunca acessará diretamente o banco de dados.

---

# 9. Fontes de Dados

## Banco Local

Fonte principal de persistência.

Armazena todo o histórico financeiro.

---

## Open Finance

Fonte externa autorizada pelo usuário.

Complementa informações.

Nunca substitui registros locais automaticamente.

---

# 10. Interface

## Dashboard

Tela responsável por apresentar informações produzidas pelo sistema.

Nunca conterá regras financeiras.

---

# 11. Princípios

## Fonte Única da Verdade

Cada informação possui exatamente uma fonte oficial.

---

## Determinismo

Os mesmos dados sempre deverão produzir exatamente o mesmo resultado.

---

## Explicabilidade

Toda conclusão produzida pela IA deverá ser rastreável.

---

## Offline First

O Atlas deverá continuar funcionando sem internet sempre que possível.

---

## Privacidade

Todos os dados pertencem exclusivamente ao usuário.

---

## Transparência

O Atlas sempre deverá explicar como chegou às suas conclusões.

---

# 12. Controle de Alterações

Toda alteração neste documento deverá:

- atualizar a versão;
- registrar data;
- informar responsável;
- quando necessário, criar uma ADR correspondente.

---

# 13. Encerramento

O Atlas Lexicon é a fundação conceitual do Atlas Finance.

Ele não descreve telas.

Ele não descreve banco de dados.

Ele não descreve implementação.

Ele define a linguagem oficial do produto.

Todos os documentos futuros deverão respeitar rigorosamente este Lexicon.

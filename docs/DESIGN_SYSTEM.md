# Atlas Finance — Identidade Visual e Design System

> Documento vivo. Consolida as decisões de identidade e interface do Atlas e serve como referência para design e implementação.

## 1. Direção visual

O Atlas deve transmitir **clareza, inteligência, controle e confiança**, sem parecer um aplicativo bancário tradicional ou excessivamente corporativo.

A interface deve ser moderna, limpa e orientada a dados, com **dark mode como experiência visual principal**.

Princípios:

- informação financeira legível antes de decoração;
- hierarquia visual forte;
- poucos elementos competindo pela atenção;
- números e ações importantes em destaque;
- cards para agrupar contexto sem fragmentar demais a tela;
- consistência entre Home, transações, contas, cartões e módulos futuros;
- linguagem simples e humana.

## 2. Personalidade da marca

O Atlas é:

- inteligente;
- confiável;
- organizado;
- tecnológico;
- acessível;
- proativo.

O produto não deve tratar o usuário como alguém que precisa apenas de uma planilha digital. O objetivo é transformar movimentações, compras e preços em informação útil para decisões.

## 3. Tema escuro

A interface principal será construída em dark mode.

Estrutura visual recomendada:

- fundo geral muito escuro;
- superfícies/cards ligeiramente mais claros que o fundo;
- texto principal de alto contraste;
- texto secundário com contraste reduzido;
- cor de destaque reservada para ações, estados selecionados e dados relevantes;
- receitas e despesas devem ser distinguíveis também por ícones/texto, não somente por cor.

Os valores exatos das cores devem ser centralizados em tokens antes da implementação final para evitar cores soltas pelo código.

## 4. Tipografia e números

A tipografia deve priorizar leitura em telas pequenas.

Hierarquia:

1. saldo e valores financeiros principais;
2. títulos de seção;
3. nomes de transações/contas;
4. informações auxiliares, datas e categorias.

Valores monetários devem usar formatação brasileira quando o usuário estiver em pt-BR, por exemplo `R$ 1.250,00`.

## 5. Componentes fundamentais

O design system deve prever componentes reutilizáveis para:

- App Bar;
- Bottom Navigation;
- cards financeiros;
- saldo principal;
- chips/filtros;
- botões primário, secundário e de ação rápida;
- campos de formulário;
- seletor de categoria;
- seletor de conta/cartão;
- item de transação;
- indicador de receita/despesa;
- gráficos;
- estados vazios;
- loading/skeleton;
- mensagens de erro e confirmação;
- modais/bottom sheets.

## 6. Navegação

A navegação deve manter as tarefas mais frequentes a poucos toques de distância.

A Home funciona como centro de comando. A partir dela, o usuário deve conseguir rapidamente:

- consultar a situação financeira;
- registrar uma transação;
- abrir o histórico;
- acessar contas e cartões;
- chegar aos demais módulos do Atlas.

A ação de adicionar uma transação deve ter alta visibilidade.

## 7. Acessibilidade

- manter contraste adequado;
- não depender exclusivamente de verde/vermelho para comunicar estado;
- oferecer áreas de toque confortáveis;
- evitar textos excessivamente pequenos;
- suportar aumento de fonte sem quebrar informações essenciais;
- usar rótulos claros para ícones importantes.

## 8. Regra de evolução

Novas telas devem reutilizar tokens e componentes existentes sempre que possível. Qualquer novo padrão visual recorrente deve primeiro ser incorporado ao design system.

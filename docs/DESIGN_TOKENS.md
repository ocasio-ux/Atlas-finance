# Atlas Finance — Design Tokens v0.2

> Fonte de verdade da identidade visual aprovada do Atlas. As telas novas devem preservar esta linguagem.

## Conceito

O Atlas usa uma estética escura, tecnológica e financeira, com **verde esmeralda como assinatura da marca**. A identidade nasce do personagem Atlas carregando o dinheiro: força, responsabilidade, equilíbrio, proteção, controle e foco.

Tagline de marca: **Seu dinheiro. Sob controle.**

Na experiência do app também pode aparecer a mensagem contextual **Seu dinheiro, mais claro.**

## Paleta oficial

| Token | Valor | Uso |
|---|---:|---|
| `atlasGreen` | `#10B981` | cor principal da marca, CTAs e destaques |
| `atlasGreenDark` | `#059669` | estados fortes/pressionados e gradientes |
| `atlasGreenDeep` | `#064E3B` | superfícies verdes profundas |
| `atlasSlate` | `#1F2937` | superfícies, cards e apoio |
| `atlasWhite` | `#F3F4F6` | texto principal e versão clara da marca |
| `atlasBackground` | `#111512` | fundo escuro do aplicativo |
| `atlasSurface` | `#252B27` | cards principais |
| `atlasSurfaceSoft` | `#303832` | cards elevados/campos |
| `atlasTextMuted` | `#AEB7B0` | texto secundário |
| `atlasExpense` | `#F08A78` | despesas/saídas |

O verde é parte da identidade e não deve ser substituído por azul/roxo em componentes principais.

## Gradientes

Cards de grande destaque, como saldo e Atlas AI, podem usar gradiente entre `atlasGreen` e variações mais claras/escuras do verde. Cards utilitários permanecem em superfícies grafite para preservar hierarquia.

## Tipografia

Família oficial: **Poppins**.

- marca ATLAS: Poppins Semibold, caixa alta e tracking amplo;
- FINANCE: Poppins Medium, caixa alta e tracking amplo;
- títulos: Poppins Semibold/Bold;
- corpo: Poppins Regular/Medium;
- números financeiros: Poppins Semibold/Bold.

## Formas

A interface usa cantos arredondados generosos:

- controles pequenos: 12 px;
- campos e botões: 16 px;
- cards: 20–24 px;
- cards hero: 28–32 px;
- chips: formato pill.

## Espaçamento

Escala base de 4 px: 4, 8, 12, 16, 20, 24, 32 e 40.

Margem horizontal preferencial: 20–24 px, adaptável ao tamanho da tela.

## Iconografia

- ícones simples e reconhecíveis;
- containers verdes arredondados para ações/categorias;
- ícones claros sobre verde;
- despesas podem usar a cor semântica de saída;
- significado nunca depende apenas da cor.

## Componentes de assinatura

### Saldo total
Card hero verde, grande, com valor financeiro como ponto focal.

### Seu Atlas
Área que apresenta a inteligência do produto como **Sua gerente**, usando card verde de alto destaque e acesso à conversa financeira.

### Cards financeiros
Receitas e despesas aparecem lado a lado em superfícies grafite, com iconografia e valores semanticamente diferenciados.

### Ações
Botões primários usam verde Atlas. A ação flutuante `Adicionar` preserva a mesma assinatura.

## Tecnologia visual

O aplicativo atual é construído em **Flutter**. O tema e componentes devem ser centralizados para impedir cores, tipografia e raios inconsistentes espalhados pelo código.

Material pode servir como fundação técnica, mas componentes devem seguir a identidade Atlas, não a aparência padrão do framework.

## Regra de consistência

A identidade mostrada no dashboard e no brand board aprovado é a referência. Novos módulos, incluindo transações, contas, cartões, scanner e Atlas AI, devem parecer partes do mesmo produto desde o primeiro frame.
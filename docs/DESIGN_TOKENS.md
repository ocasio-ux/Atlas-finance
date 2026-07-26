# Atlas Finance — Design Tokens v0.1

> Primeira especificação técnica da identidade visual. Valores poderão ser refinados após validação das telas reais.

## Conceito

O Atlas usa uma estética escura, precisa e tecnológica. O azul é a assinatura de interação e inteligência do produto. Verde e vermelho são cores semânticas, não cores decorativas.

## Cores

### Base

| Token | Valor | Uso |
|---|---:|---|
| `background` | `#080B10` | fundo principal |
| `surface` | `#10151D` | cards e superfícies |
| `surfaceElevated` | `#171D27` | elementos elevados |
| `border` | `#252D3A` | divisores e contornos |
| `textPrimary` | `#F5F7FA` | conteúdo principal |
| `textSecondary` | `#9DA8B8` | conteúdo auxiliar |
| `textMuted` | `#697586` | conteúdo de baixa ênfase |

### Marca e interação

| Token | Valor | Uso |
|---|---:|---|
| `atlasPrimary` | `#5B8CFF` | ação principal, seleção e foco |
| `atlasPrimaryStrong` | `#3F73F2` | estados pressionados/destaque |
| `atlasPrimarySoft` | `#17264A` | fundos sutis ligados à marca |

### Semânticas

| Token | Valor | Uso |
|---|---:|---|
| `positive` | `#43C98B` | receita, sucesso |
| `negative` | `#FF6678` | despesa, erro |
| `warning` | `#F4B860` | atenção |
| `info` | `#66B5FF` | informação |

As cores semânticas nunca devem ser o único indicador de significado.

## Espaçamento

Escala base de 4 dp:

- `space1`: 4 dp
- `space2`: 8 dp
- `space3`: 12 dp
- `space4`: 16 dp
- `space5`: 20 dp
- `space6`: 24 dp
- `space8`: 32 dp
- `space10`: 40 dp

Margem horizontal padrão de tela: **20 dp**.

## Bordas

- `radiusSmall`: 8 dp
- `radiusMedium`: 12 dp
- `radiusLarge`: 18 dp
- `radiusCard`: 20 dp
- `radiusPill`: 999 dp

## Tipografia

A implementação Android deve começar com uma família sans-serif moderna e altamente legível, utilizando os pesos disponíveis pelo sistema/Compose até a família definitiva ser validada.

Escala inicial:

- Display financeiro: 36 sp / semibold
- Headline: 28 sp / semibold
- Title Large: 22 sp / semibold
- Title Medium: 18 sp / medium
- Body Large: 16 sp / regular
- Body Medium: 14 sp / regular
- Label: 12 sp / medium

Valores monetários devem preferir números tabulares quando a fonte escolhida oferecer suporte.

## Elevação

O Atlas deve evitar sombras dramáticas. Profundidade será comunicada principalmente pela diferença entre fundo, superfície e borda.

## Ícones

- traço simples;
- aparência consistente;
- evitar mistura de famílias visuais;
- ícones importantes acompanhados de rótulo quando houver risco de ambiguidade.

## Movimento

Animações devem explicar mudança de estado, não decorar a interface.

- feedback rápido: 100–150 ms;
- transições comuns: 200–300 ms;
- evitar animações longas em tarefas financeiras frequentes.

## Material 3

A implementação Android poderá usar Material 3 como fundação técnica, mas o Atlas não deve parecer um app Material genérico. Cores, formas, tipografia, componentes e comportamento devem ser encapsulados pelo tema e componentes próprios do Atlas.

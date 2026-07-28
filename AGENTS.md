# Guia de autonomia — Atlas Finance

Este arquivo orienta agentes e colaboradores que atuam neste repositório. Ele
complementa os documentos de produto; instruções mais específicas em arquivos
`AGENTS.md` dentro de subdiretórios têm precedência sobre este guia.

## Objetivo e limites

Atlas é um aplicativo Flutter de finanças pessoais. Preserve a confiança do
usuário como requisito de produto: valores, datas, transações, credenciais e
dados bancários nunca podem ser inventados, expostos ou modificados de modo
silencioso.

Dentro do escopo autorizado, prefira tomar por conta própria decisões técnicas
reversíveis a pedir confirmação para cada detalhe de implementação. É seguro
agir de forma autônoma em mudanças locais e reversíveis: ler código e
documentação, criar ou ajustar testes, documentar decisões, formatar arquivos
alterados, corrigir problemas pequenos diretamente relacionados e executar as
verificações listadas abaixo. Pare e peça orientação antes de ações que:

- criem, enviem ou excluam dados financeiros reais;
- conectem bancos, Open Finance, serviços de IA ou qualquer serviço externo;
- adicionem serviços externos, SDKs que coletem ou transmitam dados,
  permissões de plataforma ou telemetria;
- adicionem dependências pagas, experimentais, abandonadas ou com impacto
  relevante em segurança, privacidade ou arquitetura;
- alterem autenticação, criptografia, retenção, backups ou regras de privacidade;
- façam `commit`, `push`, `merge`, release ou modifiquem configurações remotas,
  salvo solicitação explícita.

Nunca registre segredos, tokens, dados pessoais, extratos, números de cartão ou
contas. Use dados sintéticos em testes e exemplos. Os arquivos locais de
ambiente e material de assinatura são ignorados por `.gitignore` e não devem
ser incluídos em mudanças.

É permitido adicionar uma dependência Dart/Flutter gratuita, madura e
diretamente necessária à tarefa. Escolha a alternativa de menor escopo,
verifique manutenção e compatibilidade com o SDK do projeto, e justifique a
decisão no relatório final. Essa permissão não substitui a autorização exigida
para os casos de maior risco listados acima.

## Mapa do projeto

- `lib/main.dart`: ponto de entrada do aplicativo.
- `lib/app/`: composição do app e tema global.
- `lib/features/<feature>/`: funcionalidades por domínio; mantenha telas,
  estado e lógica de cada domínio juntos.
- `test/`: testes de widget e de unidade que espelham a estrutura de `lib/`.
- `docs/`: decisões e documentação de produto, segurança e design.
- `.github/workflows/flutter-ci.yml`: contrato mínimo de qualidade no CI.

Antes de criar uma nova abstração ou dependência, procure um padrão existente
no domínio correspondente. Prefira a menor mudança que resolva a necessidade e
evite refatorações não relacionadas.

## Ciclo de trabalho

1. Leia os arquivos relacionados e confirme o estado do Git antes de editar.
2. Delimite a mudança e preserve edições não relacionadas já presentes no
   diretório de trabalho.
3. Implemente com nomes explícitos e comportamento determinístico. Valores
   monetários devem usar representação decimal/inteira apropriada ao domínio;
   não use `double` para persistência ou cálculo financeiro.
4. Atualize ou crie testes que cubram o comportamento alterado, incluindo
   estados vazios, erro e arredondamento quando aplicável.
   Corrija também falhas pequenas e diretamente relacionadas que sejam
   necessárias para manter análise, testes ou build funcionando. Apenas
   reporte problemas não relacionados, refatorações amplas e mudanças
   arquiteturais relevantes.
5. Execute, nesta ordem, as verificações disponíveis:

   ```sh
   dart format --set-exit-if-changed lib test
   flutter analyze
   flutter test
   flutter build apk --debug
   ```

   Se uma ferramenta não estiver instalada, não tente contornar a ausência com
   artefatos manuais: informe qual etapa não pôde ser executada. O CI executa
   análise, testes e build Android de depuração.
6. Revise o diff e informe arquivos alterados, verificações executadas e
   limitações restantes. Não faça operações Git de publicação sem autorização.

## Convenções de implementação

- Mantenha o código com nulidade segura e compatível com o SDK definido em
  `pubspec.yaml`.
- Use widgets `const` sempre que possível e extraia widgets privados para
  tornar telas longas legíveis.
- O idioma padrão atual da interface é português do Brasil. Estruture textos e
  componentes de modo que uma internacionalização futura permaneça possível,
  sem introduzir agora uma camada de localização fora do escopo da tarefa.
  Siga também a identidade documentada em `docs/`.
- Trate entrada, carregamento, sucesso e falha de forma explícita. Uma ação
  financeira deve ser idempotente ou proteger contra submissão duplicada.
- Não misture acesso a serviços, regras de negócio e apresentação na mesma
  tela. Quando surgir uma fonte de dados, defina uma interface no domínio e
  mantenha a implementação externa isolada.
- Não introduza analytics, logs remotos ou chamadas de IA sem consentimento,
  minimização de dados e uma decisão documentada de privacidade.

## Critério de conclusão

Uma mudança está pronta quando atende ao pedido, não quebra as verificações
disponíveis, não expõe dados sensíveis, tem testes proporcionais ao risco e
mantém documentação atualizada quando altera comportamento, arquitetura ou
decisões de produto.

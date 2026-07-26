# Atlas Finance — Arquitetura de Segurança

## Princípio

Dados financeiros são privados por padrão. O Atlas usa defesa em camadas e não depende de uma única barreira.

## Camada 1 — Identidade e recuperação

Firebase Authentication identifica a conta. O primeiro provedor planejado é Google Sign-In.

- Atlas não recebe nem armazena a senha Google;
- cada conta recebe um Firebase `uid`;
- o `uid` é a raiz dos dados privados no Firestore;
- trocar de aparelho não deve significar perder o histórico.

## Camada 2 — Isolamento dos dados na nuvem

Estrutura:

`/users/{uid}/transactions/...`

`/users/{uid}/accounts/...`

`/users/{uid}/cards/...`

`/users/{uid}/categories/...`

`/users/{uid}/purchases/...`

As regras do Firestore exigem `request.auth.uid == uid`. Tudo que não estiver explicitamente permitido é negado.

## Camada 3 — Bloqueio do aplicativo

O Atlas usa a autenticação segura do sistema operacional através de `local_auth`.

Pode aceitar, conforme suporte/configuração do aparelho:

- impressão digital;
- reconhecimento facial;
- PIN/padrão/senha do dispositivo como fallback.

O Atlas nunca armazena template biométrico, PIN, padrão ou senha do aparelho.

Configuração planejada:

- Proteção do Atlas: ligada/desligada;
- bloquear imediatamente;
- posteriormente: tolerância configurável de 1 ou 5 minutos.

## Camada 4 — Segredos locais

Preferências de segurança e futuros tokens/segredos locais usam armazenamento seguro do sistema através de `flutter_secure_storage`, e não SharedPreferences em texto simples.

Dados financeiros offline exigirão uma decisão específica de banco local + criptografia antes da persistência definitiva.

## Camada 5 — Operações sensíveis

Operações de maior risco poderão exigir reautenticação mesmo durante uma sessão aberta, por exemplo:

- exportar todos os dados;
- alterar configurações críticas de segurança;
- excluir a conta;
- futuramente autorizar operações financeiras, se o Atlas algum dia oferecer essa capacidade.

## Camada 6 — IA

A Atlas AI recebe somente o contexto necessário para executar uma tarefa. O LLM não é a fonte de verdade para saldo ou cálculos financeiros.

A camada de IA não deve receber senhas, credenciais bancárias, tokens de autenticação ou dados que não sejam necessários para a solicitação.

## Próximos hardenings

Antes de produção:

- Firebase App Check;
- regras Firestore testadas no Emulator Suite;
- criptografia do banco offline;
- proteção de logs contra PII/dados financeiros;
- política de retenção e exclusão;
- revogação de sessão/dispositivos;
- threat modeling de Open Finance e Atlas AI;
- testes de segurança automatizados;
- revisão das configurações Android/iOS do `local_auth`;
- configuração correta de SHA-1/SHA-256 e Firebase por ambiente.

## Estado atual

Os arquivos desta etapa criam a fundação de código e regras. Firebase ainda precisa ser associado a um projeto real e receber os arquivos/configurações gerados pelo FlutterFire antes de o login Google funcionar no aparelho.

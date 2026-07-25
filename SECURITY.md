# Segurança — Atlas Finance

A segurança do Atlas Finance deve ser tratada como parte da arquitetura do produto, não como uma funcionalidade adicionada no final. Como o aplicativo poderá lidar com informações financeiras, dados pessoais, comprovantes e integrações via Open Finance, o princípio central é minimizar a coleta, o armazenamento e a exposição de dados sensíveis.

> Este documento define diretrizes de segurança para o desenvolvimento e deverá evoluir junto com a arquitetura antes de qualquer lançamento em produção.

## 1. Princípios fundamentais

- Privacy by design.
- Princípio do menor privilégio.
- Minimização de dados.
- Defesa em profundidade.
- Configurações seguras por padrão.
- Validação de toda entrada externa.

## 2. Dados financeiros e Open Finance

O Atlas Finance não deve solicitar nem armazenar senhas bancárias do usuário. Integrações com instituições financeiras deverão utilizar provedores e fluxos autorizados de Open Finance, com mecanismos oficiais de consentimento e autenticação.

- Nunca armazenar credenciais bancárias.
- Nunca registrar tokens, credenciais ou dados financeiros sensíveis em logs.
- Proteger tokens de integração e mantê-los somente pelo período necessário.
- Utilizar tokens de curta duração e renovação segura quando disponível.
- Permitir revogação de consentimento e desconexão de contas.
- Solicitar somente os escopos necessários.

## 3. Autenticação e sessão

A autenticação deverá utilizar soluções consolidadas e protocolos modernos.

- Senhas nunca devem ser armazenadas em texto puro.
- Hash de senha deve ocorrer no backend com algoritmo apropriado e configuração atualizada.
- Sessões e tokens devem expirar e poder ser revogados.
- Endpoints de autenticação devem possuir proteção contra força bruta e abuso.
- Biometria no Android deverá usar APIs seguras do sistema operacional e funcionar como camada local de acesso.

## 4. Comunicação e APIs

Toda comunicação com serviços do Atlas deverá utilizar HTTPS/TLS. Decisões críticas de autorização devem ocorrer no backend, nunca exclusivamente no aplicativo.

As APIs deverão implementar autenticação, autorização por recurso, validação de entrada, rate limiting, tratamento seguro de erros e proteção contra abuso.

Mensagens de erro não devem revelar stack traces, chaves, consultas, caminhos internos ou detalhes desnecessários da infraestrutura.

## 5. Armazenamento

Dados sensíveis devem ser criptografados em trânsito e, quando aplicável, em repouso.

No Android:

- não armazenar segredos diretamente no código-fonte;
- utilizar Android Keystore para material criptográfico quando necessário;
- evitar dados financeiros sensíveis em armazenamento compartilhado;
- invalidar dados locais após logout quando apropriado;
- evitar backups inseguros de informações sensíveis.

No backend, bancos de dados não devem ficar diretamente expostos à internet. Acesso, backups, retenção e exclusão devem seguir políticas de segurança e menor privilégio.

## 6. Recibos, notas e OCR

Arquivos enviados pelo usuário devem ser considerados conteúdo não confiável.

- Validar formato e tamanho.
- Limitar tipos aceitos.
- Nunca executar conteúdo proveniente de uploads.
- Remover metadados desnecessários quando aplicável.
- Armazenar imagens somente quando necessárias.
- Permitir exclusão pelo usuário quando aplicável.
- Resultados de OCR devem ser tratados como dados potencialmente incorretos, nunca como código ou comandos executáveis.

## 7. Segredos

É proibido colocar no repositório chaves privadas, API keys reais, senhas, tokens, credenciais de banco de dados, certificados privados ou arquivos `.env` contendo segredos.

Segredos deverão ser fornecidos por mecanismos próprios de gerenciamento de secrets nos ambientes de desenvolvimento, CI/CD e produção. O `.gitignore` deverá impedir commits acidentais de arquivos locais sensíveis.

Se um segredo for publicado acidentalmente, removê-lo do Git não é suficiente: ele deverá ser imediatamente revogado e substituído.

## 8. Logs e monitoramento

Logs não devem conter senhas, tokens completos, credenciais bancárias, números completos de cartões, documentos completos ou informações pessoais desnecessárias.

Eventos relevantes de segurança deverão ser auditáveis no backend respeitando privacidade e retenção adequada.

## 9. Dependências

- Utilizar dependências mantidas e provenientes de fontes confiáveis.
- Manter bibliotecas atualizadas.
- Revisar vulnerabilidades conhecidas antes de releases.
- Remover dependências sem uso.
- Utilizar análise automatizada de dependências e código no pipeline de desenvolvimento.

## 10. LGPD e privacidade

O desenvolvimento deverá considerar a Lei Geral de Proteção de Dados (LGPD) e demais obrigações aplicáveis antes da operação real.

O Atlas deverá oferecer mecanismos compatíveis com os direitos do usuário, incluindo, quando aplicável, transparência sobre tratamento de dados, acesso, correção, exclusão, revogação de consentimentos e exportação ou portabilidade.

## 11. Segurança no desenvolvimento

Mudanças relacionadas a autenticação, autorização, Open Finance, criptografia ou dados sensíveis devem receber revisão adicional antes de produção.

Antes de releases importantes, executar pelo menos:

1. análise de dependências vulneráveis;
2. análise estática de código;
3. testes de autenticação e autorização;
4. verificação de exposição de secrets;
5. revisão das permissões solicitadas pelo aplicativo;
6. testes dos principais cenários de abuso.

O projeto deverá acompanhar referências reconhecidas como OWASP MASVS/MASWE para segurança mobile e OWASP ASVS para componentes web/backend.

## 12. Modelo inicial de ameaças

O Atlas deve considerar desde o início riscos como roubo de sessão, acesso indevido a contas, vazamento de dados financeiros, exposição de tokens e API keys, manipulação de requisições, uploads maliciosos, abuso de APIs, dispositivos comprometidos, dependências vulneráveis, engenharia reversa e comprometimento de integrações externas.

Controles no aplicativo não substituem controles equivalentes no servidor.

## 13. Relato de vulnerabilidades

Enquanto o Atlas estiver em desenvolvimento inicial e não possuir canal dedicado de segurança, vulnerabilidades não devem ser publicadas em Issues públicas contendo detalhes exploráveis ou dados sensíveis.

Antes do lançamento público deverá existir um processo formal de divulgação responsável e um canal privado de contato.

---

**Regra de ouro do Atlas:** nenhum recurso novo justifica enfraquecer a proteção dos dados financeiros ou pessoais do usuário. Segurança faz parte do produto.
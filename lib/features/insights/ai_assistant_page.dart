import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../transactions/transaction_store.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final input = TextEditingController();
  final messages = <_Message>[];
  final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.8-flash');
  bool sending = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = input.text.trim();
    if (question.isEmpty || sending) return;
    input.clear();
    setState(() {
      messages.add(_Message(question, true));
      sending = true;
    });
    final store = TransactionStore.instance;
    final context = store.transactions
        .take(80)
        .map((item) => '${item.createdAt.toIso8601String()} | ${item.type.name} | ${item.amount} | ${item.category.name} | ${item.description}')
        .join('\n');
    try {
      final response = await model.generateContent([
        Content.text('''Você é a gerente financeira do Atlas. Responda em português do Brasil, de forma clara e curta. Use somente os dados fornecidos; se não houver informação suficiente, diga isso. Não invente valores e não ofereça aconselhamento financeiro de alto risco.

Dados do usuário:
Saldo: ${store.balance}
Receitas: ${store.income}
Despesas: ${store.expenses}
Movimentações:
$context

Pergunta: $question'''),
      ]);
      setState(() => messages.add(_Message(response.text ?? 'Não consegui gerar uma resposta.', false)));
    } catch (_) {
      setState(() => messages.add(const _Message('A IA está temporariamente indisponível. Verifique o App Check e tente novamente.', false)));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AtlasColors.background,
    appBar: AppBar(title: const Text('Sua gerente')),
    body: Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Pergunte sobre seus gastos, saldo ou metas.', style: TextStyle(color: AtlasColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => Align(
                    alignment: messages[index].fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: messages[index].fromUser ? AtlasColors.green : AtlasColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(messages[index].text, style: const TextStyle(color: AtlasColors.white)),
                    ),
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(child: TextField(controller: input, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Pergunte ao Atlas'))),
                const SizedBox(width: 8),
                IconButton(onPressed: sending ? null : _send, icon: const Icon(Icons.send_rounded, color: AtlasColors.green)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Message {
  const _Message(this.text, this.fromUser);
  final String text;
  final bool fromUser;
}

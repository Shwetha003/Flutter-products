// lib/screens/support_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/message.dart';
import '../services/support_storage.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loaded = await SupportStorage.loadSupportHistory();
    setState(() {
      _messages.addAll(loaded);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = Message(text: text, sender: Sender.user);
    final echoMsg = Message(text: text, sender: Sender.echo);

    setState(() {
      _messages.addAll([userMsg, echoMsg]);
    });
    _controller.clear();
    _scrollToBottom();

    await SupportStorage.saveSupportHistory(_messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        //appBar:AppBar(
        leading: IconButton(
          onPressed: () {
            context.goNamed('products');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Products',
        ),
      ),
      //)
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Type below to start chat'))
                : ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      final isUser = msg.sender == Sender.user;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(msg.text),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

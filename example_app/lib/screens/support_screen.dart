// lib/screens/support_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/message.dart';
import '../services/support_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
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

  /*Future<void> _handleSend() async {
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
  }*/

  // User taps the photo icon:
  Future<void> _handlePickImage() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    final XFile? file = await _picker.pickImage(source: choice);
    if (file == null) return;

    //  Build two messages (user + echo) carrying the path:
    final userMsg = Message(imagePath: file.path, sender: Sender.user);
    final echoMsg = Message(imagePath: file.path, sender: Sender.echo);

    setState(() {
      _messages.addAll([userMsg, echoMsg]);
    });
    await SupportStorage.saveSupportHistory(_messages);
    _scrollToBottom();
  }

  // text send
  Future<void> _handleSendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = Message(text: text, sender: Sender.user);
    final echoMsg = Message(text: text, sender: Sender.echo);

    setState(() {
      _messages.addAll([userMsg, echoMsg]);
    });
    _controller.clear();
    await SupportStorage.saveSupportHistory(_messages);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        leading: IconButton(
          onPressed: () {
            context.goNamed('products');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Products',
        ),
      ),
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

                      Widget bubbleContent;
                      if (msg.imagePath != null) {
                        bubbleContent = ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: Image.file(
                            File(msg.imagePath!),
                            width: 500.w,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        bubbleContent = Text(
                          msg.text!,
                          style: TextStyle(fontSize: 50.sp),
                        );
                      }

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4.h,
                            horizontal: 8.w,
                          ),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: bubbleContent,
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handlePickImage,
                  icon: const Icon(Icons.photo),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                    onSubmitted: (_) => _handleSendText(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSendText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:poc/src/nearby/presentation/nearby_sendable_list.dart';

class NearbySendSection extends StatefulWidget {
  const NearbySendSection({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  State<NearbySendSection> createState() => _NearbySendSectionState();
}

class _NearbySendSectionState extends State<NearbySendSection> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  bool canSend = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()
      ..addListener(() {
        if (_textController.text.isEmpty) {
          setState(() {
            canSend = false;
          });
        } else {
          if (!canSend) {
            setState(() {
              canSend = true;
            });
          }
        }
      });

    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            canRequestFocus: true,
            decoration: InputDecoration(
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: canSend ? widget.onSubmit : null,
            child: const Text('Find recipient'),
          ),
          const SizedBox(height: 8),
          const NearbySendableList(),
        ],
      ),
    );
  }
}

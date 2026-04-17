import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';

class SignaturePadScreen extends StatefulWidget {
  const SignaturePadScreen({super.key});

  @override
  State<SignaturePadScreen> createState() => _SignaturePadScreenState();
}

class _SignaturePadScreenState extends State<SignaturePadScreen> {
  late final SignatureController _controller;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _controller.addListener(() {
      final empty = _controller.isEmpty;
      if (empty != _isEmpty) {
        setState(() => _isEmpty = empty);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearCanvas() {
    _controller.clear();
  }

  Future<void> _confirmSignature() async {
    final Uint8List? bytes = await _controller.toPngBytes();
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to capture signature. Please try again.')),
        );
      }
      return;
    }
    if (mounted) {
      context.pop(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Sign PO'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear',
              onPressed: _clearCanvas,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                  width: double.infinity,
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                minimum:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop<Uint8List?>(null),
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isEmpty ? null : _confirmSignature,
                        child: const Text('Confirm Signature'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

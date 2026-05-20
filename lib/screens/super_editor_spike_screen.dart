import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// Throwaway screen for evaluating super_editor as a TextField replacement.
/// Tests selection painting (per-line tightness), IME-on-resume keyboard
/// behavior, multi-line drag-select, soft-keyboard interactions.
///
/// Delete this file (and the settings entry in `settings_screen.dart`) if
/// the spike is rejected.
class SuperEditorSpikeScreen extends StatefulWidget {
  const SuperEditorSpikeScreen({super.key});

  @override
  State<SuperEditorSpikeScreen> createState() => _SuperEditorSpikeScreenState();
}

class _SuperEditorSpikeScreenState extends State<SuperEditorSpikeScreen> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _document = MutableDocument(nodes: [
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('# worthy'),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(
          'Jesus is worthy of all of our praise and stuff',
        ),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('# exalt'),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('Short'),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(
          'Now here is a really really really really really long line that '
          'should wrap onto the next visual line within a normal screen width '
          'on a phone in portrait mode, giving us a multi-line wrap inside '
          'one paragraph node so we can test selection on a wrapped line.',
        ),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('Another short line'),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(
          'Type here to test the soft keyboard. Background the app, return, '
          'and tap to confirm the keyboard reattaches.',
        ),
      ),
    ]);
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _editor.dispose();
    _composer.dispose();
    _document.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('super_editor spike')),
      body: SafeArea(
        child: SuperEditor(
          editor: _editor,
          focusNode: _focusNode,
        ),
      ),
    );
  }
}

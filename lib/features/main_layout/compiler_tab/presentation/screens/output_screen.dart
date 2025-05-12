import 'package:flutter/material.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../manager/compile_view_model.dart';

class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String removeNonUTF8(String input) {
    return input.replaceAll(RegExp(r'[^\x0A\x0D\x20-\x7E]'), '');
  }

  String _formatOutput(String output) {
    String trimmed = output.trim().replaceAll('\r\n', '\n');
    return removeNonUTF8(trimmed.replaceAll(RegExp(r'\n{3,}'), '\n\n'));
  }

  void _sendInput(BuildContext context, void Function() callBack) {
    final compiler = Provider.of<CompileViewModel>(context, listen: false);
    final inputText = _inputController.text.trim();

    if (inputText.isNotEmpty) {
      compiler.sendCommandToCompiler(inputText);
      _inputController.clear();
    }
    callBack();
    compiler.clearOutput();

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black,
          iconTheme: const IconThemeData(color: AppColors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: () {
                Provider.of<CompileViewModel>(
                  context,
                  listen: false,
                ).closeConnection();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        backgroundColor: AppColors.black,
        body: Consumer<CompileViewModel>(
          builder: (context, compiler, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent,
                );
              }
            });

            String formattedOutput = _formatOutput(compiler.output);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Output:',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: SelectableText(
                        formattedOutput,
                        style: TextStyle(
                          color:
                              formattedOutput.toLowerCase().contains('error')
                                  ? Colors.red
                                  : Colors.green[200],
                          fontSize: 16,
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ),
                  ),
                ),
                if (compiler.isRunning)
                  Container(
                    color: AppColors.lightGray,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter input...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                              ),
                            ),
                            onSubmitted: (_) => _sendInput(context,() {
                              formattedOutput = '';
                            },),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),

                          onPressed: () => _sendInput(context,() {
                            formattedOutput = '';
                          },),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

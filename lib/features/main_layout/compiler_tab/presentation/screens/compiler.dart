import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/cs.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/features/file_managment/presentation/manager/file_view_model.dart';
import 'package:graduation_project/features/main_layout/compiler_tab/presentation/manager/compile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/routes/app_routes_name.dart';
import '../../../../file_managment/data/models/file_detail_model.dart';
import '../../../home/manager/home_tab_controller.dart';

class CompilerScreen extends StatefulWidget {
  const CompilerScreen({super.key});

  @override
  State<CompilerScreen> createState() => _CompilerScreenState();
}

class _CompilerScreenState extends State<CompilerScreen> {
  late CodeController _codeController;
  String? selectedLanguage = "python";
  final Map<String, dynamic> languageMap = {
    "python": python,
    "javascript": javascript,
    "csharp": cs,
    "java": java,
    "cpp": cpp,

  };

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(text: '', language: python);

    Future.microtask(() {
      Provider.of<CompileViewModel>(
        context,
        listen: false,
      ).fetchSupportedLanguages();
      _loadFileContent();
    });
  }

  void _loadFileContent() {
    final fileViewModel = Provider.of<FileViewModel>(context, listen: false);
    final selectedFile = fileViewModel.selectedFile;

    if (selectedFile != null) {
      _updateCodeController(selectedFile);
    } else {}
  }

  void _updateCodeController(FileDetailModel file) {
    setState(() {
      _codeController = CodeController(
        text: file.fileContent ?? '',
        language: languageMap[selectedLanguage] ?? python,
      );
    });
  }

  // Future<void> _executeCode(BuildContext context) async {
  //   final navigatorKey = Navigator.of(context);
  //   FocusManager.instance.primaryFocus?.unfocus();
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(child: CircularProgressIndicator()),
  //   );
  //
  //   try {
  //     final compiler = Provider.of<CompileViewModel>(context, listen: false);
  //     await compiler.compileCode(selectedLanguage!, _codeController.text);
  //
  //     navigatorKey.pop();
  //
  //     if (compiler.compileResult != null) {
  //       await navigatorKey.pushNamed(
  //         AppRoutesName.output,
  //         arguments: compiler.compileResult,
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Compilation returned no output')),
  //       );
  //     }
  //   } catch (e) {
  //     navigatorKey.pop();
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //   }
  // }

  Future<void> _executeCode(BuildContext context) async {
    print("Selected Language: $selectedLanguage");
    print("Code to run: ${_codeController.text}");
    if (selectedLanguage == null || _codeController.text.trim().isEmpty) {
      print("❌ Either language or code is missing");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final compiler = Provider.of<CompileViewModel>(context, listen: false);
    compiler.connectToCompiler(selectedLanguage!, _codeController.text);


    Navigator.of(context).pushNamed(AppRoutesName.output);
  }
  String shortenString(String input) {
    return input.length > 6 ? input.substring(0, 6) + '...' : input;
  }


  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Consumer2<CompileViewModel, FileViewModel>(
        builder: (context, compiler, fileViewModel, child) {
          final languages = compiler.rootModel?.supportedLanguages ?? [];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.gray,

              title: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final homeTabController = Provider.of<HomeTabController>(
                        context,
                        listen: false,
                      );
                      if (fileViewModel.fileCreated) {
                        homeTabController.changeTab(0);
                      }
                      if (fileViewModel.readFile) {
                        homeTabController.changeTab(1);
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Spacer(),
                  Text(
                    shortenString(fileViewModel.selectedFile!.fileName )??
                        'No file selected',
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,

                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    hint: const Text(
                      '+ Select Language',
                      style: TextStyle(color: AppColors.white),
                    ),
                    value: selectedLanguage,
                    dropdownColor: AppColors.gray,
                    style: const TextStyle(color: AppColors.white),
                    items:
                        languages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang),
                          );
                        }).toList(),
                    onChanged: (newLang) {
                      setState(() {
                        selectedLanguage = newLang;
                        _codeController.language = languageMap[newLang] ?? python;
                      });
                    },
                  ),
                  const Spacer(),
                  InkWell(
                    onTap:
                        compiler.isLoading ? null : () => _executeCode(context),
                    child: const Icon(
                      Icons.play_arrow_outlined,
                      color: AppColors.white,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: AppColors.gray,
            body: Column(
              children: [
                Expanded(
                  child: CodeTheme(
                    data: CodeThemeData(styles: monokaiSublimeTheme),
                    child: CodeField(
                      controller: _codeController,
                      expands: true,
                      wrap: true,
                      background: AppColors.gray,
                      textStyle: const TextStyle(fontSize: 14),
                      gutterStyle: const GutterStyle(
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ),

                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: AppColors.lightGray,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.save, color: AppColors.white),
                        onPressed: () async {
                          if (fileViewModel.selectedFile == null) return;

                          String newContent = _codeController.text;

                          if (fileViewModel.isSharedFile) {
                            // ✅ تحديث ملف متشين
                            await fileViewModel.updateSharedFile(
                              fileShareCode:
                                  fileViewModel.sharedCodeController.text,
                              newFileContent: newContent,
                            );
                          } else {
                            int? fileId = fileViewModel.selectedFile?.fileId;
                            if (fileId == null) return;

                            // ✅ تحديث ملف عادي
                            await fileViewModel.updateFile(
                              fileId,
                              newFileContent: newContent,
                            );
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Save Changes")));
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.share, color: AppColors.white),
                        onPressed: () async {
                          final file = fileViewModel.selectedFile;
                          if (file == null) return;

                          final shareData = await fileViewModel.shareFile(
                            file.fileId,
                          );
                          final shareUrl = shareData?.fileShareCode;
                          final code = _codeController.text;

                          if (shareUrl != null) {
                            showShareOptionsBottomSheet(context, shareUrl, code);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to generate share link"),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showShareOptionsBottomSheet(
    BuildContext context,
    String shareUrl,
    String codeText,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              runSpacing: 15,
              children: [
                ListTile(
                  leading: Icon(Icons.link, color: Colors.white),
                  title: Text(
                    "Copy Link",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Link copied to clipboard")),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy, color: Colors.white),
                  title: Text(
                    "Copy Code",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: codeText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Code copied to clipboard")),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share, color: Colors.white),
                  title: Text(
                    "Share via WhatsApp",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      'Check this code: $shareUrl',
                      subject: 'Shared Code',
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.send, color: Colors.white),
                  title: Text(
                    "Share via Messenger",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share('Check this code: $shareUrl');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.white),
                  title: Text(
                    "Share via Instagram",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share('Check this code: $shareUrl');
                  },
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graduation_project/core/app_assets/app_assets.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../file_managment/presentation/manager/file_view_model.dart';
import '../../../home/manager/home_tab_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CodeEditorScreen extends StatefulWidget {

  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  bool fetchFiles = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final fileViewModel = Provider.of<FileViewModel>(context, listen: false);
      await fileViewModel.fetchAllFiles(); // ✅ تحميل الملفات
      if (mounted) {
        setState(() {
          fetchFiles = fileViewModel.files.isEmpty; // ✅ مفيش فايلات؟ اعرض الكونتينر
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var local =AppLocalizations.of(context);
    var size = MediaQuery.of(context).size;
    return Consumer<FileViewModel>(
      builder: (context, fileVM, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.gray,
            body: Padding(
              padding: const EdgeInsets.all(11),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.07),
                    Text(
                      local!.welcome,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      local.ready,
                      style: TextStyle(color: AppColors.white, fontSize: 15),
                    ),
                    SizedBox(height: size.height * 0.05),
                    Row(
                      children: [

                        Container(
                          height: size.height * 0.06,
                          width: size.width * 0.48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final homeTabController = Provider.of<HomeTabController>(context, listen: false);
                              bool fileCreated = await createFile(context);
                              if (fileCreated && context.mounted) {
                                homeTabController.changeTab(2);

                              }
                            },

                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.gray,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.add, color: AppColors.white),
                                Text(
                                  local.createNewFile,

                                  style: TextStyle(color: AppColors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: size.height * 0.05),

                    SizedBox(height: 10),
                    if (fileVM.files.isEmpty)
                      Container(
                      height: size.height * 0.23,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Image.asset(
                              AppAssets.starLeft,
                              width: size.width * 0.3,
                              height: size.height * 0.1,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Image.asset(
                              AppAssets.starRight,
                              width: size.width * 0.3,
                              height: size.height * 0.1,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  local.noRecent,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  local.startYourFirst,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),

                    Row(
                      children: [
                        Spacer(),

                        Text(
                          local.exploreOptions,
                          style: TextStyle(color: AppColors.white, fontSize: 16),
                        ),
                        Spacer(),

                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Row(
                      children: [
                        Spacer(),

                        InkWell(
                          onTap: () {
                            Provider.of<HomeTabController>(context, listen: false)
                                .changeTab(1);
                          },
                          child: Container(
                            height: size.height * 0.041,
                            width: size.width * 0.35,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                local.openFolder,
                                style: TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),

                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Spacer(),

                        InkWell(
                          onTap: () {
                            Provider.of<HomeTabController>(context, listen: false)
                                .changeTab(3);
                          },
                          child: Container(
                            height: size.height * 0.041,
                            width: size.width * 0.35,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.white, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                local.importCode,
                                style: TextStyle(color: AppColors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),

                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> createFile(BuildContext context) async {
    TextEditingController fileNameController = TextEditingController();
    var local =AppLocalizations.of(context);

    final fileViewModel = Provider.of<FileViewModel>(context, listen: false);
    String fileName = '';
    bool fileCreated = false;

    await showDialog(

      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightGray,
        title: Text( local!.createNewFile,style: TextStyle(color:AppColors.white )),
        content: TextField(
          onChanged: (value) {
            fileName = value;
          },
          controller: fileNameController,
          decoration: InputDecoration(hintText: local.fileName,hintStyle:TextStyle(color:AppColors.white ) ),
          style:TextStyle(color: AppColors.white) ,

        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(local.cancel,style: TextStyle(color:AppColors.white )),
          ),
          TextButton(
            onPressed: () async {
              String fileName = fileNameController.text.trim();
              if (fileName.isNotEmpty) {
                // ✅ عرض اللودر
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('assets/animation/Animation - 1745441062182.json'),
                    ),
                  ),
                );

                await fileViewModel.createFile(
                  fileName,
                  "// Start coding here",
                );

                await fileViewModel.fetchAllFiles();


                fileViewModel.setSelectedFile(fileViewModel.files.last);


                await fileViewModel.readSingleFile(fileViewModel.selectedFile!.fileId);


                fileCreated = true;

                if (context.mounted) Navigator.pop(context);
                if (context.mounted) Navigator.pop(context);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.createNewFile)),
                  );
                }
              }
            },
            child: Text(local.create,style: TextStyle(color:AppColors.white )),
          ),
        ],
      ),
    );

    return fileCreated;
  }
}

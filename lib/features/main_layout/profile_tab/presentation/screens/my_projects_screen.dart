import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/features/file_managment/presentation/manager/file_view_model.dart';
import 'package:provider/provider.dart';

import '../../../home/manager/home_tab_controller.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<FileViewModel>(context, listen: false).fetchAllFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer<FileViewModel>(
      builder: (context, fileViewModel, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.gray,
          title: IconButton(onPressed: () {
            final homeTabController = Provider.of<HomeTabController>(context, listen: false);
            homeTabController.changeTab(0);

          }, icon: Icon(Icons.arrow_back,color: AppColors.white,)),
        ),
        backgroundColor: AppColors.gray,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: fileViewModel.isLoading
                    ? Center(child: CircularProgressIndicator(color:Colors.white,))
                    : fileViewModel.files.isEmpty
                    ? Center(
                  child: Text(
                    "no projects created",
                    style: TextStyle(color: AppColors.white),
                  ),
                )
                    : ListView.builder(
                  itemCount: fileViewModel.files.length,
                  itemBuilder: (context, index) {
                    final file = fileViewModel.files[index];
                    return InkWell(
                      onTap: () {
                        final navigatorKey = Navigator.of(context);
                        final homeTabController = Provider.of<HomeTabController>(context, listen: false);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator(color:Colors.white,)),
                        );

                        Future(() async {
                          try {
                            await Provider.of<FileViewModel>(context, listen: false)
                                .readSingleFile(file.fileId);
                            print(e.toString());
                            navigatorKey.pop();
                            homeTabController.changeTab(2);
                          } catch (e) {
                            navigatorKey.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(6),
                        height: size.height * 0.1,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.file_copy,
                              color: AppColors.white,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              file.fileName,
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () =>_confirmDelete(context, fileViewModel,file) ,
                              icon: Icon(Icons.delete),
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _confirmDelete(BuildContext context, FileViewModel fileViewModel, file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightGray,
        title: Text("Delete file",style: TextStyle(color:AppColors.white )),
        content: Text("Are you sure you want to delete this file? This action cannot be undone.",style: TextStyle(color:AppColors.white ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel",style: TextStyle(color:AppColors.white,fontWeight: FontWeight.bold ),),
          ),
          TextButton(
            onPressed: () async {
              await fileViewModel.deleteFile(file.fileId);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("File Deleted")),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}

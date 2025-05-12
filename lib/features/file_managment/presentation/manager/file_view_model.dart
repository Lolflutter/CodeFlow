import 'package:flutter/material.dart';
import '../../../../core/services/network_services.dart';
import '../../data/models/file_model.dart';
import '../../data/models/file_shared_model.dart';
import '../../data/models/file_detail_model.dart';
import '../../data/models/update_shared_file_model.dart';
import '../../domain/use_cases/file_use_case.dart';

class FileViewModel extends ChangeNotifier {
  final FileUseCase fileUseCase;
  final token = NetworkServices().token;

  bool isLoading = false;
  String? errorMessage;
  List<FileModel> files = [];
  FileDetailModel? selectedFile;
  FileModel? selectedNewFile;
  bool isDeleted = false;
  String? shareUrl;
  bool fileCreated = false;
  bool readFile = false;
  bool isSharedFile = false;


  final TextEditingController sharedCodeController = TextEditingController();






  FileViewModel({required this.fileUseCase});

  Future<T?> _execute<T>(Future<T> Function() operation) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      return await operation();
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllFiles() async {
    files = await _execute(() => fileUseCase.readAllFiles(token!)) ?? [];
  }

  Future<void> readSingleFile(int fileId) async {
    final file = await _execute(() => fileUseCase.readSingleFile(token!, fileId));

    if (file != null) {
      selectedFile = file;
      readFile =true;
      notifyListeners();
    } else {
      readFile =false;

      throw Exception(errorMessage ?? "Failed to load file");
    }
    notifyListeners();
  }


  Future<void> createFile(String fileName, String fileContent) async {
    final newFile = await _execute(() =>
        fileUseCase.createFile(token!, fileName, fileContent));

    if (newFile != null) {
      await readSingleFile(newFile.fileId);
      files.add(newFile);
      fileCreated = true;
    } else {
      fileCreated = false;
    }
    notifyListeners();
  }



    Future<void> updateFile(int fileId, {String? newFileName, String? newFileContent}) async {
    final updatedFile = await _execute(() => fileUseCase.updateFile(
        token!, fileId, newFileName: newFileName, newFileContent: newFileContent));

    if (updatedFile != null) {
      int index = files.indexWhere((file) => file.fileId == fileId);
      if (index != -1) {
        files[index] = updatedFile;
      }

      if (selectedFile?.fileId == fileId) {
        selectedFile = selectedFile!.copyWith(
          fileName: newFileName ?? selectedFile!.fileName,
          fileContent: newFileContent ?? selectedFile!.fileContent,
        );
      }
    }
  }

  Future<void> deleteFile(int fileId) async {
    isDeleted = await _execute(() => fileUseCase.deleteFile(token!, fileId)) ?? false;

    if (isDeleted) {
      files.removeWhere((file) => file.fileId == fileId);
      if (selectedFile?.fileId == fileId) {
        selectedFile = null;
      }
      notifyListeners();
    }
  }

  Future<FileShareModel?> shareFile(int fileId) async {
    final shareData = await _execute(() => fileUseCase.sharedFile(token!, fileId));
    if (shareData != null) {
      shareUrl = shareData.fileShareCode;
      notifyListeners();
    }
    return shareData;
  }

  Future<void> readSharedFile(String fileShareCode) async {
    final sharedFile = await _execute(() => fileUseCase.readSharedFile(fileShareCode));

    if (sharedFile != null) {
      isSharedFile = true;
      selectedFile = FileDetailModel(
        fileId: 0, // ممكن تحط ID وهمي أو تسيبه زي ما هو لو مش مهم
        fileName: sharedFile.fileName,
        fileContent: sharedFile.fileContent,
        fileCreationDate: sharedFile.dateTime,
        lastModifiedDate: sharedFile.dateTime,
        fileSizeInBytes: sharedFile.fileSizeInBytes,
      );

      shareUrl = fileShareCode;
      notifyListeners();
    }
  }
  UpdateSharedFileModel? updatedSharedFile;

  Future<void> updateSharedFile({
    required String fileShareCode,
    String? newFileName,
    String? newFileContent,
  }) async {
    final result = await _execute(() => fileUseCase.updateSharedFile(
      fileShareCode: fileShareCode,
      newFileName: newFileName,
      newFileContent: newFileContent,
    ));

    if (result != null) {
      updatedSharedFile = result;
      notifyListeners();
    }
  }



  void clearShareUrl() {
    shareUrl = null;
    notifyListeners();
  }
  void setSelectedFile(FileModel file) {
    selectedNewFile = file;
    notifyListeners();
  }

}

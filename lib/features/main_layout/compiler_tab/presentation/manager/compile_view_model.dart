import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../../core/services/network_services.dart';
import '../../data/models/compile_model.dart';
import '../../data/models/root_model.dart';
import '../../domain/use_cases/compile_use_case.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class CompileViewModel extends ChangeNotifier {
  final CompileFeatureUseCase compileFeatureUseCase;
  final token = NetworkServices().token;

  bool isLoading = false;
  bool isSuccess =false;
  String? errorMessage;
  RootModel? rootModel;
  CompileModel? compileResult;

  String? selectedLanguage;
  String? codeContent;
  void clearOutput(){
    _output.clear();
  }


  WebSocketChannel? _channel;
  final StringBuffer _output = StringBuffer();
  bool _isRunning = false;

  String get output => _output.toString();
  bool get isRunning => _isRunning;

  CompileViewModel({required this.compileFeatureUseCase});

  Future<void> fetchSupportedLanguages() async {
    try {
      isLoading = true;
      notifyListeners();

      rootModel = await compileFeatureUseCase.getSupportedLanguages();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /// ✅ NEW WebSocket method
  void connectToCompiler(String language, String code) {
    _output.clear();
    _isRunning = true;
    notifyListeners();

    _channel = WebSocketChannel.connect(Uri.parse('wss://gradapi.duckdns.org/compile-ws'));

    final request = jsonEncode({
      "type": "code",
      "language": language,
      "codeToRun": code,
    });
    print("🚀 Sending this to WebSocket:\n$request");
    _channel!.sink.add(request);

    print('Connected to WebSocket');


    _channel!.stream.listen(
          (message) {
            print('Received: $message');
            _output.write(message + '\n');
        notifyListeners();
      },
      onDone: () {
        _isRunning = false;
        notifyListeners();
      },
      onError: (error) {
        _output.write("Error: $error\n");
        _isRunning = false;
        notifyListeners();
      },
    );
  }
  void sendCommandToCompiler(String input) {
    if (_channel == null || input.trim().isEmpty) return;

    final commandRequest = jsonEncode({
      "type": "command",
      "language": selectedLanguage ?? "",
      "codeToRun": input,
    });

    print("⌨️ Sending command: $commandRequest");
    _channel!.sink.add(commandRequest);
  }
  void sendUserInput(String input) {
    if (_channel != null) {
      _channel!.sink.add(input);
      _output.write('[You] $input\n');
      notifyListeners();
    }
  }

  void closeConnection() {
    _isRunning = false;
    _channel?.sink.close();
    notifyListeners();
  }


  // Future<void> compileCode(String language, String code) async {
  //   try {
  //     isLoading = true;
  //     compileResult = null;
  //     notifyListeners();
  //
  //     compileResult = await compileFeatureUseCase.compileCode(token!, language, code);
  //
  //     if (compileResult == null) {
  //       throw Exception('Compilation failed - no result');
  //     }
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     rethrow;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void updateLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void updateCode(String code) {
    codeContent = code;
    notifyListeners();
  }
}

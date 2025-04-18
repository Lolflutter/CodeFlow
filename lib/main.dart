import 'package:flutter/material.dart';
import 'package:graduation_project/core/routes/app_routes.dart';
import 'package:graduation_project/core/routes/app_routes_name.dart';
import 'package:graduation_project/core/services/network_services.dart';
import 'package:graduation_project/features/auth/data/data_source/data_source_imp.dart';
import 'package:graduation_project/features/auth/data/repo/repo_imp.dart';
import 'package:graduation_project/features/auth/domain/use_cases/auth_use_case.dart';
import 'package:graduation_project/features/auth/presentation/manager/auth_view_model.dart';
import 'package:graduation_project/features/file_managment/data/data_source/file_remote_data_source_imp.dart';
import 'package:graduation_project/features/file_managment/data/repo/file_repository_imp.dart';
import 'package:graduation_project/features/file_managment/domain/use_cases/file_use_case.dart';
import 'package:graduation_project/features/file_managment/presentation/manager/file_view_model.dart';
import 'package:graduation_project/features/main_layout/chat_bot_tab/data/data_source/chatBot_data_imp.dart';
import 'package:graduation_project/features/main_layout/chat_bot_tab/data/repo/chat_bot_repo_imp.dart';
import 'package:graduation_project/features/main_layout/chat_bot_tab/domain/use_cases/chat_bot_use_case.dart';
import 'package:graduation_project/features/main_layout/chat_bot_tab/presentation/manager/chat_bot_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/main_layout/compiler_tab/data/data_source/compile_data_source_imp.dart';
import 'features/main_layout/compiler_tab/data/repo/compile_repository_impl.dart';
import 'features/main_layout/compiler_tab/domain/use_cases/compile_use_case.dart';
import 'features/main_layout/compiler_tab/presentation/manager/compile_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ استرجاع التوكن
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // ✅ تجهيز NetworkServices وتحديث التوكن لو موجود
  final networkServices = NetworkServices();
  if (token != null) {
    networkServices.updateToken(token);
  }

  runApp(MyApp(token: token, networkServices: networkServices));
}

class MyApp extends StatelessWidget {
  final String? token;
  final NetworkServices networkServices;

  const MyApp({super.key, this.token, required this.networkServices});

  @override
  Widget build(BuildContext context) {
    //  Auth Layer
    final authRemoteDataSource = AuthRemoteDataSourceImp();
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    final authUseCase = AuthUseCase(authRepository);

    //  File Management Layer
    final fileRemoteDataSource = FileRemoteDataSourceImpl(
      networkServices: networkServices,
    );
    final fileRepository = FileRepositoryImpl(
      remoteDataSource: fileRemoteDataSource,
    );
    final fileUseCase = FileUseCase(repository: fileRepository);

    //compilation layer
    final compileRemoteDataSource = CompileRemoteDataSourceImpl(
      networkServices: networkServices,
    );
    final compileRepository = CompileRepositoryImpl(
      remoteDataSource: compileRemoteDataSource,
    );
    final compileFeatureUseCase = CompileFeatureUseCase(
      repository: compileRepository,
    );

    //chat bot layer
    final chatBotDataSource = ChatBotDataSourceImpl(
      networkServices: networkServices,
    );
    final chatBotRepo = ChatBotRepositoryImpl(
      chatBotDataSource: chatBotDataSource,
    );
    final chatBotUseCase = ChatBotUseCase(chatBotRepo);

    return MultiProvider(
      providers: [
        //  Auth ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authUseCase: authUseCase),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  FileViewModel(fileUseCase: fileUseCase, token: token ?? ""),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CompileViewModel(
                compileFeatureUseCase: compileFeatureUseCase,
                token: token ?? "",
              ),
        ),
        ChangeNotifierProvider(
            create:
                (_) => ChatBotViewModel(chatBotUseCase: chatBotUseCase )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute:
            token != null
                ? AppRoutesName.mainLayout
                : AppRoutesName.loginScreen,
        routes: AppRoutes.routes,
      ),
    );
  }
}

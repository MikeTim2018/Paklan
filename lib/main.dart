import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/helper/messaging_api/api.dart';
import 'package:paklan/core/configs/theme/app_theme.dart';
import 'package:paklan/firebase_options.dart';
import 'package:paklan/presentation/splash/bloc/splash_cubit.dart';
import 'package:paklan/presentation/splash/pages/splash.dart';
import 'package:paklan/service_locator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebaseMsgApi.instance.initialize();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..appStarted(),
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashPage()
      ),
    );
  }
}

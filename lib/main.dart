import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packlan_alpha/core/configs/theme/app_theme.dart';
import 'package:packlan_alpha/firebase_options.dart';
import 'package:packlan_alpha/presentation/splash/bloc/splash_cubit.dart';
import 'package:packlan_alpha/presentation/splash/pages/splash.dart';
import 'package:packlan_alpha/service_locator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packlan_alpha/common/helper/navigator/app_navigator.dart';
import 'package:packlan_alpha/core/configs/assets/app_images.dart';
import 'package:packlan_alpha/core/configs/theme/app_colors.dart';
import 'package:packlan_alpha/presentation/auth/pages/signin.dart';
import 'package:packlan_alpha/presentation/home/pages/home.dart';
import 'package:packlan_alpha/presentation/splash/bloc/splash_cubit.dart';
import 'package:packlan_alpha/presentation/splash/bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state){
        if (state is UnAuthenticated){
          AppNavigator.pushAndRemove(context, SigninPage());
        }
        if (state is Authenticated){
          AppNavigator.pushAndRemove(context, HomePage());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 190,),
              Text("Paklan",style: TextStyle(
                fontSize: 35
              ),),
              Padding(
                padding: const EdgeInsets.all(65.0),
                child: Image.asset(
                  AppImages.appLogo
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
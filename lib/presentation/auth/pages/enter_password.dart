import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packlan_alpha/common/bloc/button/button_state.dart';
import 'package:packlan_alpha/common/bloc/button/button_state_cubit.dart';
import 'package:packlan_alpha/common/helper/navigator/app_navigator.dart';
import 'package:packlan_alpha/common/widgets/appbar/app_bar.dart';
import 'package:packlan_alpha/common/widgets/button/basic_reactive_button.dart';
import 'package:packlan_alpha/data/auth/models/user_signin.dart';
import 'package:packlan_alpha/domain/auth/usecases/signin.dart';
import 'package:packlan_alpha/presentation/auth/pages/forgot_password.dart';
import 'package:packlan_alpha/presentation/home/pages/home.dart';


class EnterPasswordPage extends StatelessWidget {
  final UserSigninReq signinReq;
  EnterPasswordPage({super.key, required this.signinReq});
  final TextEditingController _passwordCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 40
        ),
        child: BlocProvider(
          create: (context) => ButtonStateCubit(),
          child: BlocListener<ButtonStateCubit,ButtonState>(
            listener: (context, state) {
              if (state is ButtonFailureState){
                var snackbar = SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: TextStyle(
                      color: Colors.white70
                    ),),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  showCloseIcon: true,
                  closeIconColor: Colors.white70,
                  );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              }else if (state is ButtonSuccessState){
                AppNavigator.pushAndRemove(context, HomePage());
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
                _signinText(context),
                const SizedBox(height: 15,),
                _passwordField(context),
                const SizedBox(height: 15,),
                _continueButton(context),
                const SizedBox(height: 10,),
                _forgotPassword(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _signinText(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Inicia Sesión',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _passwordField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        controller: _passwordCon,
        decoration: InputDecoration(
          hintText: "Ingresa tu Contraseña"
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (context) {
          return BasicReactiveButton(onPressed: (){
            signinReq.password = _passwordCon.text;
            context.read<ButtonStateCubit>().execute(
            usecase: SigninUseCase(),
            params: signinReq
          );
          },
          title: 'Ingresar',);
        }
      ),
    );
  }

  Widget _forgotPassword(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "¿Olvidaste tu contraseña? "
            ),
            TextSpan(
              text: '¡Recupérala!',
              recognizer: TapGestureRecognizer()..onTap = (){
                AppNavigator.push(context, ForgotPasswordPage());
              },
              style: TextStyle(
                fontWeight: FontWeight.bold
              )
            )
          ]
        )
        ),
    );
  }
}
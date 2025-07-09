import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/data/auth/models/user_signin.dart';
import 'package:paklan/domain/auth/usecases/signin.dart';
import 'package:paklan/presentation/auth/pages/forgot_password.dart';
import 'package:paklan/presentation/home/pages/home.dart';
import 'package:show_hide_password/show_hide_password.dart';


class EnterPasswordPage extends StatelessWidget {
  final UserSigninReq signinReq;
  EnterPasswordPage({super.key, required this.signinReq});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
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
      child: ShowHidePassword(
        iconSize: 30,
        visibleOffIcon: Iconsax.eye_slash_copy,
        visibleOnIcon: Iconsax.eye_copy,
        passwordField: (bool hidePassword){
        return TextFormField(
          validator: (value){
            if (value!.isEmpty){
              return '¡No puede estar vacío este campo!';
            }
            else{
              return null;
            }
          },
          obscureText: hidePassword,
          enableSuggestions: false,
          autocorrect: false,
          controller: _passwordCon,
          cursorErrorColor: Colors.red,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Ingresa tu Contraseña"
          ),
        );
        }
      ),
    );
  }

  Widget _continueButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (context) {
          return BasicReactiveButton(onPressed: (){
            if (_formKey.currentState!.validate()){
            signinReq.password = _passwordCon.text;
            context.read<ButtonStateCubit>().execute(
            usecase: SigninUseCase(),
            params: signinReq
          );
            }
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
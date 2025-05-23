import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/data/auth/models/user_signin.dart';
import 'package:paklan/presentation/auth/pages/enter_password.dart';
import 'package:paklan/presentation/auth/pages/signup.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(hideBack: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 40
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50,),
              _signinText(context),
              const SizedBox(height: 15,),
              _emailField(context),
              const SizedBox(height: 15,),
              _continueButton(context),
              const SizedBox(height: 10,),
              _createAccount(context),
            ],
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

  Widget _emailField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: (value){
          if (value!.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)){
            return 'Ingresa un Email válido';
          }
          else{
            return null;
          }
        },
        controller: _emailCon,
        decoration: InputDecoration(
          hintText: "Ingresa tu Email"
        ),
      ),
    );
  }

  Widget _continueButton(context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BasicAppButton(onPressed: (){
        if (_formKey.currentState!.validate()){
        AppNavigator.push(context, EnterPasswordPage(
          signinReq: UserSigninReq(
            email: _emailCon.text,
            ),
        ));
        }
      },
      title: 'Continuar',),
    );
  }

  Widget _createAccount(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "¿No tienes una cuenta? "
            ),
            TextSpan(
              text: 'Crea una',
              recognizer: TapGestureRecognizer()..onTap = (){
                AppNavigator.push(context, SignupPage());
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
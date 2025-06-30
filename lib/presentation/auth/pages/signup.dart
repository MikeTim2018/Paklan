import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/presentation/auth/pages/gender_and_age_selection.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';
import 'package:show_hide_password/show_hide_password.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameCon = TextEditingController();
  final TextEditingController _lastNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 40,
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
                _firstName(context),
                const SizedBox(height: 15,),
                _lastName(context),
                const SizedBox(height: 15,),
                _password(context),
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
        'Crear Cuenta',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _firstName(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: (value){
          if (value!.isEmpty || !RegExp(r'[a-z A-Z]+').hasMatch(value)){
            return 'Intenta de nuevo con un nombre válido';
          }
          else{
            return null;
          }
        },
        controller: _firstNameCon,
        decoration: InputDecoration(
          hintText: "Nombre(s)",
        ),
      ),
    );
  }

  Widget _lastName(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: (value){
          if (value!.isEmpty || !RegExp(r'[a-z A-Z]+').hasMatch(value)){
            return 'Intenta de nuevo con apellidos válidos';
          }
          else{
            return null;
          }
        },
        controller: _lastNameCon,
        decoration: InputDecoration(
          hintText: "Apellidos"
        ),
      ),
    );
  }
  
  Widget _password(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ShowHidePassword(
        passwordField: (bool hidePassword){
          return TextFormField(
          validator: (value){
            if (value!.isEmpty || value.length<7){
              return 'Ingresa una contraseña mayor a 6 caracteres';
            }
            else{
              return null;
            }
          },
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          controller: _passwordCon,
          decoration: InputDecoration(
            hintText: "Contraseña"
          ),
        );
        }
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
          AppNavigator.push(
            context, 
            GenderAndAgeSelectionPage(
              userCreationReq: UserCreationReq(
              firstName: _firstNameCon.text,
              email: _emailCon.text,
              lastName: _lastNameCon.text,
              password: _passwordCon.text,
            )
            )
            );
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
              text: "¿Ya tienes una cuenta? "
            ),
            TextSpan(
              text: 'Ingresa aqui',
              recognizer: TapGestureRecognizer()..onTap = (){
                AppNavigator.push(context, SigninPage());
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
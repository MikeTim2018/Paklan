import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/presentation/auth/pages/gender_and_age_selection.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameCon = TextEditingController();
  final TextEditingController _lastNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final FancyPasswordController _passwordCon = FancyPasswordController();
  final TextEditingController _passwordEditCon = TextEditingController();


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
      child: FancyPasswordField(
          passwordController: _passwordCon,
          enableSuggestions: false,
          autocorrect: false,
          controller: _passwordEditCon,
          validationRules: {
            DigitValidationRule(),
            UppercaseValidationRule(),
            LowercaseValidationRule(),
            SpecialCharacterValidationRule(),
            MinCharactersValidationRule(7),
            MaxCharactersValidationRule(18),
          },
          validationRuleBuilder: (rules, value) {
                  if (value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: rules
                        .map(
                          (rule) => rule.validate(value)
                              ? Row(
                                  children: [
                                    const Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                        rule.name,
                                        style: const TextStyle(
                                            color: Colors.white54,
                                        ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                        rule.name,
                                        style: const TextStyle(
                                            color: Colors.red,
                                        ),
                                    ),
                                  ],
                                ),
                        )
                        .toList(),
                  );
                },
          validator: (value){
            return _passwordCon.areAllRulesValidated ? null : 'Contraseña incompleta';
          },
          decoration: InputDecoration(
            hintText: "Contraseña"
          ),
        )
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
        if (_formKey.currentState!.validate() && _passwordCon.areAllRulesValidated){
          AppNavigator.push(
            context, 
            GenderAndAgeSelectionPage(
              userCreationReq: UserCreationReq(
              firstName: _firstNameCon.text,
              email: _emailCon.text,
              lastName: _lastNameCon.text,
              password: _passwordEditCon.text,
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
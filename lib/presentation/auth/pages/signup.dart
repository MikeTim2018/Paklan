import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/domain/auth/usecases/signup.dart';
import 'package:paklan/presentation/home/pages/home.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final FancyPasswordController _passwordCon = FancyPasswordController();
  final TextEditingController _passwordEditCon = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(),
      body: BlocProvider(
        create: (context) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
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
          child: SingleChildScrollView(
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
                    _displayName(context),
                    const SizedBox(height: 15,),
                    _password(context),
                    const SizedBox(height: 15,),
                    _continueButton(context),
                  ],
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
        'Crear Cuenta',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _displayName(BuildContext context){
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
        controller: _displayNameCon,
        decoration: InputDecoration(
          hintText: "Nombre de usuario",
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
            return value!.isEmpty ? '¡No puede estar vacío este campo!' : null;
            //return _passwordCon.areAllRulesValidated ? null : 'Contraseña incompleta';
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
      child: Builder(
        builder: (context) {
          return BasicReactiveButton(onPressed: (){
            if (_formKey.currentState!.validate() && _passwordCon.areAllRulesValidated){
              context.read<ButtonStateCubit>().execute(
                usecase: SignupUseCase(),
                params: UserCreationReq(
                  displayName: _displayNameCon.text,
                  email: _emailCon.text,
                  password: _passwordEditCon.text,
                )
              );
          }
          },
          title: 'Crear',);
        }
      ),
    );
  }
}
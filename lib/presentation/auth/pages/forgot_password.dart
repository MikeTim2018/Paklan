import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packlan_alpha/common/bloc/button/button_state.dart';
import 'package:packlan_alpha/common/bloc/button/button_state_cubit.dart';
import 'package:packlan_alpha/common/helper/navigator/app_navigator.dart';
import 'package:packlan_alpha/common/widgets/appbar/app_bar.dart';
import 'package:packlan_alpha/common/widgets/button/basic_reactive_button.dart';
import 'package:packlan_alpha/domain/auth/usecases/send_password_reset_email.dart';
import 'package:packlan_alpha/presentation/auth/pages/password_reset_email.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});
  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(),
      body: BlocProvider(
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
                AppNavigator.push(context, const PasswordResetEmailPage());
              }
            },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 40
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
                _signinText(context),
                const SizedBox(height: 15,),
                _emailField(context),
                const SizedBox(height: 15,),
                _continueButton(),
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
        'Recuperar Contraseña',
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
      child: TextField(
        controller: _emailCon,
        decoration: InputDecoration(
          hintText: "Ingresa tu Email"
        ),
      ),
    );
  }

  Widget _continueButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (context) {
          return BasicReactiveButton(onPressed: (){
            context.read<ButtonStateCubit>().execute(
              usecase: SendPasswordResetEmailUseCase(),
              params: _emailCon.text);
          },
          title: 'Enviar',);
        }
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';

class PasswordResetEmailPage extends StatelessWidget {
  const PasswordResetEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _emailSending(),
            const SizedBox(height: 30,),
            _sentEmail(),
            const SizedBox(height: 30,),
            _returnToLoginButton(context)
          ],
        ),
      ),
    );
  }
  Widget _emailSending() {
    return Center(
      child: SvgPicture.asset(
        AppVectors.emailSending
      ),
    );
  }

  Widget _sentEmail() {
    return const Center(
      child: Text(
        '¡Te hemos enviado un email para recuperar tu contraseña!'
      ),
    );
  }

  Widget _returnToLoginButton(BuildContext context) {
    return BasicAppButton(
      onPressed: (){
        AppNavigator.pushReplacement(context, SigninPage());
      },
      width: 200,
      title: '¡Regresar a Login!'
    );
  }
}

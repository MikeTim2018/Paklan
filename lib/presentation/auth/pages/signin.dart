import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/facebook_button_state.dart';
import 'package:paklan/common/bloc/button/facebook_button_state_cubit.dart';
import 'package:paklan/common/bloc/button/google_button_state.dart';
import 'package:paklan/common/bloc/button/google_button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/facebook_reactive_button.dart';
import 'package:paklan/common/widgets/button/google_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/data/auth/models/user_signin.dart';
import 'package:paklan/domain/auth/usecases/signin_with_facebook.dart';
import 'package:paklan/domain/auth/usecases/signin_with_google.dart';
import 'package:paklan/presentation/auth/pages/enter_password.dart';
import 'package:paklan/presentation/auth/pages/signup.dart';
import 'package:paklan/presentation/home/pages/home.dart';

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
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FacebookButtonStateCubit()),
            BlocProvider(create: (context) => GoogleButtonStateCubit())
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<GoogleButtonStateCubit, GoogleButtonState>
              (
               listener: (context, state) {
              if (state is GoogleButtonFailureState){
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
              }else if (state is GoogleButtonSuccessState){
                AppNavigator.pushAndRemove(context, HomePage());
              }
            },
            ),
            BlocListener<FacebookButtonStateCubit, FacebookButtonState>
              (
               listener: (context, state) {
              if (state is FacebookButtonFailureState){
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
              }else if (state is FacebookButtonSuccessState){
                AppNavigator.pushAndRemove(context, HomePage());
              }
            },
            ),
            ],
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50,),
                    _signinText(context),
                    const SizedBox(height: 10,),
                    _emailField(context),
                    _createAccount(context),
                    const SizedBox(height: 10,),
                    _continueButton(context),
                    const SizedBox(height: 15,),
                    dividerAltAuth(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        logInWithFacebook(context),
                        const SizedBox(width: 10,),
                        logInWithGoogle(context),
                      ]
                    ),
                    
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
  
  Widget dividerAltAuth(BuildContext context){
    return Row(
  children: const [
    Expanded(
      child: Divider(
        thickness: 1, // Adjust line thickness
        color: Colors.grey, // Adjust line color
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // Spaces line away from text
      child: Text(
        "Inicia también con",
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    Expanded(
      child: Divider(
        thickness: 1,
        color: Colors.grey,
      ),
    ),
  ], 
  );
  }

  Widget logInWithGoogle(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (context) {
          return Center(
            child: GoogleReactiveButton(onPressed: (){
              context.read<GoogleButtonStateCubit>().execute(
              usecase: SigninWithGoogleUseCase()
              );
            },
            ),
          );
        }
      ),
    );
  }

  Widget logInWithFacebook(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder: (context) {
          return Center(
            child: FacebookReactiveButton(onPressed: (){
              context.read<FacebookButtonStateCubit>().execute(
              usecase: SigninWithFacebookUseCase()
              );
            },
            content: AppVectors.facebookIcon,
            ),
          );
        }
      ),
    );
  }

  Widget _createAccount(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "¿No tienes una cuenta? ",
              style: TextStyle(
                color: Colors.black54
              )
            ),
            TextSpan(
              text: 'Crea una',
              recognizer: TapGestureRecognizer()..onTap = (){
                AppNavigator.push(context, SignupPage());
              },
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87
              )
            )
          ]
        )
        ),
    );
  }
}
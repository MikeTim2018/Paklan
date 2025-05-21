import 'package:flutter/material.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/presentation/home/pages/home.dart';

class TransactionSuccessWoConfirmation extends StatelessWidget {
   const TransactionSuccessWoConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(hideBack: true,),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text(
                  "Se le ha notificado a la persona tu intención de hacer un trato.",
                  style: TextStyle(
                    fontSize: 28
                  ),
                  ),
              ),
              SizedBox(height: 20,),
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      AppImages.dealSuccess
                    ) 
                  ),
                  color: Colors.white,
                  shape: BoxShape.circle
                ),
              ),
              SizedBox(height: 20,),
        
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text(
                  "¡Solo hace falta esperar a que la otra persona acepte el trato propuesto!",
                  style: TextStyle(
                    fontSize: 23
                  ),
                  ),
              ),
              
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: BasicAppButton(
                  title: "Aceptar",
                  onPressed: () => AppNavigator.pushAndRemove(context, HomePage())
                  ),
              )
            ],
          ),
        ),
      ),
    );

  }
}
import 'package:flutter/material.dart';
import 'package:packlan_alpha/common/widgets/appbar/app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: _welcome(context),
        height: 110,
        hideBack: true,
      ),
      body: Column(children: [
        Text("")
      ],)
    );
  }
}

Widget _welcome(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '¡Hola!',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
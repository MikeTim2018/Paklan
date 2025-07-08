import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';


class Payment extends StatelessWidget {
  const Payment({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: Scaffold(
          appBar: BasicAppbar(
              hideBack: true,
              title: 
                  Text("Detalle del monto"),
            ),
          body: SingleChildScrollView(
            child: Column(
            children: [
              ExpansionTile(
                   title: Center(child: const Text(
                     'Total a pagar',
                     style: TextStyle(
                       fontSize: 23
                     ),
                     )
                     ),
                   children: <Widget>[
                     ListTile(title: Text(
                           "Hola",
                           style: TextStyle(
                             fontSize: 17,
                             )
                             ),)
                     ],
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
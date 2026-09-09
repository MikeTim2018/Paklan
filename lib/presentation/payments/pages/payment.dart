import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/domain/payments/usecases/payment_onboarding_usecase.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';


class Payment extends StatelessWidget {
  final TransactionEntity transaction;
  final StatusEntity status;
  const Payment({super.key, required this.transaction, required this.status});

  @override
  Widget build(BuildContext context) {
    UserEntity ? userInfo;
    return BlocProvider(
      create: (context) => ButtonStateCubit(),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Icon(Icons.horizontal_rule, size: 45,),),
        resizeToAvoidBottomInset: true,
        child: BlocListener<UserInfoDisplayCubit, UserInfoDisplayState>(
          listener: (BuildContext context, UserInfoDisplayState state) { 
            if (state is UserInfoLoaded) {
              userInfo = state.user;
            }
          },
          child: Scaffold(
              appBar: BasicAppbar(
                  hideBack: true,
                  title: 
                      Text("Detalle del monto"),
                ),
              body: SingleChildScrollView(
                child: BlocListener<ButtonStateCubit, ButtonState>(listener: (context, state) => state is ButtonSuccessState? Navigator.pop(context) : null,
                  child: Column(
                  children: [
                    ExpansionTile(
                      initiallyExpanded: true,
                         title: Center(child: const Text(
                           'Total a pagar',
                           style: TextStyle(
                             fontSize: 23
                           ),
                           )
                           ),
                         children: <Widget>[
                          Row(
                            children: [
                              Text("Monto Acordado: "),
                              SizedBox(width: 10,),
                              Text("\$${transaction.amount} mnx")
                            ],
                          ),
                          Row(
                            children: [
                              Text("Comisión: "),
                              SizedBox(width: 59,),
                              Text("\$${transaction.fee} mnx")
                            ],
                          ),
                            Divider(color: Colors.white38,),
                          
                          Row(
                            children: [
                              Text("Total: "),
                              SizedBox(width: 89,),
                              Text("\$${(double.parse(transaction.fee!) + double.parse(transaction.amount!)).truncateToDouble().toStringAsFixed(2)} mnx")
                            ],
                          ),
                           ],
                       ),
                       SizedBox(height: 30,),
                       Builder(
                         builder: (context) {
                           return Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: BasicReactiveButton(           
                                                title: "Pagar",
                                                onPressed: (){
                                                  context.read<ButtonStateCubit>().execute(
                                                  usecase: PaymentOnboardingUsecase(),
                                                  params: userInfo!.email
                                                  );
                                                }
                                                ),
                           );
                         }
                       )
                  ],
                              ),
                ),
            ),
          ),
        ),
      ),
    );
  }
}
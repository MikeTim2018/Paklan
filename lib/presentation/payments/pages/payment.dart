import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';


class Payment extends StatelessWidget {
  final TransactionEntity transaction;
  final StatusEntity status;
  const Payment({super.key, required this.transaction, required this.status});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ButtonStateCubit(),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: true,
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
                     SizedBox(height: 40,),
                     Text("Transfiere el monto total a la siguiente cuenta CLABE:"),
                     SizedBox(height: 25,),
                     Text(
                      "123456789123456798",
                      style: TextStyle(
                        fontSize: 23,
                        
                      ),
                      ),
                     SizedBox(height: 25,),
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text("Una vez transferido el monto, se validará y confirmará en un tiempo estimado de 2 hrs para avanzar al siguiente paso del proceso."),
                     ),
                     SizedBox(height: 25,),
                     Builder(
                       builder: (context) {
                         return Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: BasicReactiveButton(           
                                              title: "Aceptar",
                                              onPressed: (){
                                                context.read<ButtonStateCubit>().execute(
                                                usecase: UpdateDealUseCase(),
                                                params: StatusModel(
                                                    status: transaction.status, 
                                                    details: "Trato pagado, pendiente de liberación", 
                                                    buyerConfirmation: status.buyerConfirmation, 
                                                    sellerConfirmation: status.sellerConfirmation, 
                                                    transactionId: transaction.transactionId, 
                                                    buyerId: status.buyerId, 
                                                    sellerId: status.sellerId, 
                                                    paymentDone: status.paymentDone, 
                                                    paymentTransferred: true, 
                                                    reimbursementDone: status.reimbursementDone, 
                                                    cancelled: status.cancelled, 
                                                    statusId: status.statusId,
                                                    cancelledBy: status.cancelledBy,
                                                    cancelMessage: status.cancelMessage
                                                )
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
    );
  }
}
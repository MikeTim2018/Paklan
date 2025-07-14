import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';


class CancelDeal extends StatelessWidget {
  final TransactionEntity transaction;
  final String currentUserId;
  final StatusEntity status;
  final MultiSelectController _multiCon = MultiSelectController();
  CancelDeal({super.key, required this.transaction, required this.status, required this.currentUserId});

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
                    Text("Cancelar el trato"),
              ),
            body: SingleChildScrollView(
              child: BlocListener<ButtonStateCubit, ButtonState>(listener: (context, state) => state is ButtonSuccessState? Navigator.pop(context) : null,
                child: Column(
                children: [
                  
                     SizedBox(height: 40,),
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text(
                        "Cancelar el trato, le notificará inmediatamente al vendedor, y rembolsará cualquier monto transferido a la applicación, descontando la comisión cobrada.",
                        style: TextStyle(fontSize: 18),
                        ),
                     ),
                     SizedBox(height: 25,),
                     Text(
                      "Elige la(s) razones de cancelación:",
                      style: TextStyle(
                        fontSize: 23,
                      ),
                      ),
                     SizedBox(height: 25,),
                     MultiSelectContainer(
                      controller: _multiCon,
                      itemsDecoration: MultiSelectDecorations(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.blue.withValues(alpha: 0.1),
                              Colors.yellow.withValues(alpha: 0.1),
                            ]),
                            border: Border.all(color: Colors.green[200]!),
                            borderRadius: BorderRadius.circular(20)),
                        selectedDecoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Colors.red,
                              AppColors.primary
                            ]),
                            border: Border.all(color: Colors.green[700]!),
                            borderRadius: BorderRadius.circular(13)),
                        disabledDecoration: BoxDecoration(
                            color: Colors.grey,
                            border: Border.all(color: Colors.grey[500]!),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      maxSelectableCount: 3,
                      highlightColor: Colors.white38,
                      splashColor: const Color.fromRGBO(82, 184, 221, 1),
                    prefix: MultiSelectPrefix(
                        selectedPrefix: const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        enabledPrefix: const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.add,
                            size: 14,
                          ),
                        )),
                    items: [
                      MultiSelectCard(value: 'No responde', label: 'No responde'),
                      MultiSelectCard(value: 'Presunta estafa', label: 'Presunta estafa'),
                      MultiSelectCard(
                          value: 'Ya no me interesa', label: 'Ya no me interesa'),
                      MultiSelectCard(
                          value: 'Me equivoqué', label: 'Me equivoqué'),
                      MultiSelectCard(value: 'Vendedor me pidió la cancelación', label: 'Vendedor me pidió que cancelara'),
                      MultiSelectCard(value: 'Vendedor ya no tiene el producto', label: 'Vendedor ya no tiene el producto'),
                      MultiSelectCard(value: 'No puedo pagarlo', label: 'No puedo pagarlo'),
                      MultiSelectCard(value: 'Precio incorrecto', label: 'Precio incorrecto'),
                      MultiSelectCard(value: 'Vendedor cambió los términos', label: 'Vendedor cambió los términos'),
                    ],
                    onMaximumSelected: (allSelectedItems, selectedItem) {
                            var snackbar = SnackBar(
                             content: Text(
                               "¡Solo puedes seleccionar hasta 3 opciones!",
                               style: TextStyle(
                                 color: Colors.white70
                               ),),
                             behavior: SnackBarBehavior.floating,
                             backgroundColor: Colors.black87,
                             showCloseIcon: true,
                             closeIconColor: Colors.white70,
                             );
                             ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          },
                    onChange: (allSelectedItems, selectedItem) {}),
                    SizedBox(height: 25,),
                     Builder(
                       builder: (context) {
                         return Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: CustomReactiveButton(
                                              color: Colors.redAccent,           
                                              title: "Cancelar trato",
                                              onPressed: (){
                                                if (_multiCon.getSelectedItems().isNotEmpty){
                                                  print(_multiCon.getSelectedItems());
                                                context.read<ButtonStateCubit>().execute(
                                                usecase: UpdateDealUseCase(),
                                                params: StatusModel(
                                                    status: 'Cancelado', 
                                                    details: "Trato cancelado por usuario", 
                                                    buyerConfirmation: status.buyerConfirmation, 
                                                    sellerConfirmation: status.sellerConfirmation, 
                                                    transactionId: transaction.transactionId, 
                                                    buyerId: status.buyerId, 
                                                    sellerId: status.sellerId, 
                                                    paymentDone: status.paymentDone, 
                                                    paymentTransferred: status.paymentTransferred, 
                                                    reimbursementDone: status.reimbursementDone, 
                                                    cancelled: true, 
                                                    statusId: status.statusId,
                                                    cancelledBy: currentUserId,
                                                    cancelMessage: _multiCon.getSelectedItems()
                                                )
                                              );
                                              }
                                              else {
                                                var snackbar = SnackBar(
                                                 content: Text(
                                                   "¡Tienes que elegir al menos una razón!",
                                                   style: TextStyle(
                                                     color: Colors.white70
                                                   ),),
                                                 behavior: SnackBarBehavior.floating,
                                                 backgroundColor: Colors.black87,
                                                 showCloseIcon: true,
                                                 closeIconColor: Colors.white70,
                                                 );
                                                 ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                              }
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
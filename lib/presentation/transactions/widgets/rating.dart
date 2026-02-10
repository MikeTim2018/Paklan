import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';
import 'package:paklan/presentation/transactions/bloc/rating_selection_cubit.dart';


class Rating extends StatelessWidget {
  final TransactionEntity transaction;
  final String currentUserId;
  final StatusEntity status;
  final MultiSelectController _multiCon = MultiSelectController();
  Rating({super.key, required this.transaction, required this.status, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
      BlocProvider(create: (context) => ButtonStateCubit()),
      BlocProvider(create: (context) => RatingSelectionCubit(),),
      ],
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Icon(Icons.horizontal_rule, size: 45,),),
        resizeToAvoidBottomInset: true,
        child: Scaffold(
            appBar: BasicAppbar(
                hideBack: true,
                title: 
                    Text("Califica el trato"),
              ),
            body: BlocBuilder<RatingSelectionCubit, double>(
              builder: (context, ratingState) {
                return SingleChildScrollView(
                  child: BlocListener<ButtonStateCubit, ButtonState>(listener: (context, state) => state is ButtonSuccessState? Navigator.pop(context) : null,
                    child: Column(
                    children: [
                         Padding(
                           padding: const EdgeInsets.all(12.0),
                           child: Text(
                            "Antes de liberar los fondos al vendedor y finalizar el trato tómate un tiempo para calificar como estuvo el trato, si hubo comunicación constante, si fué lo que esperabas, etc.",
                            style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                            ),
                         ),
                         SizedBox(height: 25,),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Text(
                            "Elige la puntuación y al menos un comentario:",
                            style: TextStyle(
                              fontSize: 23,
                            ),
                            ),
                         ),
                         SizedBox(height: 25,),
                         StarRating(

                          borderColor: Colors.amberAccent,
                          size: 30,
                          rating: context.read<RatingSelectionCubit>().selectedIndex,
                          allowHalfRating: false,
                          onRatingChanged: (rating) {
                            _multiCon.deselectAll();
                            context.read<RatingSelectionCubit>().selectRating(rating);
                            
                          },
                         ),
                         SizedBox(height: 25,),
                        MultiSelectContainer(
                                   controller: _multiCon,
                                   itemsDecoration: MultiSelectDecorations(
                                   decoration: BoxDecoration(
                                       gradient: LinearGradient(colors: [
                                         Colors.green.withValues(alpha: 0.1),
                                         Colors.yellow.withValues(alpha: 0.1),
                                       ]),
                                       border: Border.all(color: Colors.green[200]!),
                                       borderRadius: BorderRadius.circular(20)),
                                   selectedDecoration: BoxDecoration(
                                       gradient: LinearGradient(colors: [
                                         Colors.blue,
                                         Colors.blue[100]!.withValues(alpha: 0.7)
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
                                 splashColor: Colors.white70,
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
                                      items: buildCard(context.read<RatingSelectionCubit>().selectedIndex),
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
                                      onChange: (allSelectedItems, selectedItem) {}
                                        ),
                          
                        
                        SizedBox(height: 25,),
                         Row(
                           children: [
                            SizedBox(width: 50,),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                     minimumSize: Size(50, 50),
                                     backgroundColor: AppColors.primary,
                                      ),
                              child: Text(
                                "Regresar",
                                style: TextStyle(
                                  color: Colors.white
                                ),
                                ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: 10,),
                             Builder(
                               builder: (context) {
                                 return Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: CustomReactiveButton(
                                                      color: Colors.blue,           
                                                      title: "Completar liberación",
                                                      onPressed: (){
                                                        if (_multiCon.getSelectedItems().isNotEmpty){
                                                        context.read<ButtonStateCubit>().execute(
                                            usecase: UpdateDealUseCase(),
                                            params: StatusModel(
                                                status: "Completado", 
                                                details: "Trato Completado, el monto pagado fué liberado exitosamente al vendedor", 
                                                buyerConfirmation: status.buyerConfirmation, 
                                                sellerConfirmation: status.sellerConfirmation, 
                                                transactionId: status.transactionId, 
                                                buyerId: status.buyerId, 
                                                sellerId: status.sellerId, 
                                                paymentDone: true, 
                                                paymentTransferred: status.paymentTransferred, 
                                                reimbursementDone: status.reimbursementDone, 
                                                cancelled: status.cancelled, 
                                                statusId: status.statusId,
                                                cancelledBy: status.cancelledBy,
                                                cancelMessage: status.cancelMessage,
                                                completedRatingMessageForSeller: _multiCon.getSelectedItems(),
                                                sellerRating: context.read<RatingSelectionCubit>().selectedIndex,
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
                             ),
                           ],
                         )
                    ],
                                ),
                  ),
                          );
              }
            ),
        ),
      ),
    );
  }

  List<MultiSelectCard> buildCard(double rating) {
    if(rating == 1.0){
      return [
            MultiSelectCard(value: "Trato difícil", label: "Trato difícil"),
            MultiSelectCard(value: "Canceló sin aviso", label: "Canceló sin aviso"),
            MultiSelectCard(value: "No recomendable", label: "No recomendable"),
            MultiSelectCard(value: "Trato difícil", label: "Trato difícil"),
            MultiSelectCard(value: "No cumplió", label: "No cumplió"),
            MultiSelectCard(value: "Reportable", label: "Reportable"),
          ];
    }
    if (rating == 2.0){
      return [
            MultiSelectCard(value: "No fue lo esperado", label: "No fue lo esperado"),
            MultiSelectCard(value: "Respuesta lenta", label: "Respuesta lenta"),
            MultiSelectCard(value: "No como se acordó", label: "No como se acordó"),
            MultiSelectCard(value: "Trato difícil", label: "Trato difícil"),
            MultiSelectCard(value: "No cumplió", label: "No cumplió"),
            MultiSelectCard(value: "Canceló sin aviso", label: "Canceló sin aviso"),
          ];
    }
    if (rating == 3.0){
      return [
            MultiSelectCard(value: "Trato sin problema", label: "Trato sin problema"),
            MultiSelectCard(value: "Cumplió lo acordado", label: "Cumplió lo acordado"),
            MultiSelectCard(value: "Trato neutral", label: "Trato neutral"),
            MultiSelectCard(value: "Podría mejorar", label: "Podría mejorar"),
            MultiSelectCard(value: "No fue lo esperado", label: "No fue lo esperado"),
          ];
    }
    if (rating == 4.0){
      return [
                  MultiSelectCard(value: 'Volvería a tratar', label: 'Volvería a tratar'),
                  MultiSelectCard(value: 'Confiable', label: 'Confiable'),
                  MultiSelectCard(value: 'Respuesta rápida', label: 'Respuesta rápida'),
                  MultiSelectCard(value: 'Trato sin problema', label: 'Trato sin problema'),
                  MultiSelectCard(value: 'Cumplió lo acordado', label: 'Cumplió lo acordado'),
                                              ];
    }
      return [
                  MultiSelectCard(value: 'Impecable', label: 'Impecable'),
                  MultiSelectCard(value: 'Excelente trato', label: 'Excelente trato'),
                  MultiSelectCard(value: 'Atención personalizada', label: 'Atención personalizada'),
                  MultiSelectCard(value: 'Volvería a tratar', label: 'Volvería a tratar'),
                  MultiSelectCard(value: 'Confiable', label: 'Confiable'),
                                              ];

  }
}

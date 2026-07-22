import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';
import 'package:paklan/domain/transactions/usecases/get_transaction.dart';
import 'package:paklan/presentation/payments/pages/payment.dart';
import 'package:paklan/presentation/transactions/bloc/stepper_selection_cubit.dart';
import 'package:paklan/presentation/transactions/widgets/cancel_deal.dart';
import 'package:paklan/presentation/transactions/widgets/rating.dart';
import 'package:paklan/presentation/transactions/widgets/rating_buyer.dart';
import 'package:paklan/service_locator.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;
  final TextEditingController _cancelCon1 = TextEditingController();
  TransactionDetail({super.key, required this.transaction});
  final GlobalKey<FormState> _formKeyCancel = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> transactionStream = sl<GetTransactionUseCase>().call(
      params: TransactionModel(
            name: transaction.name,
            amount: transaction.amount, 
            status: transaction.status, 
            sellerDisplayName: transaction.sellerDisplayName, 
            buyerDisplayName: transaction.buyerDisplayName, 
            transactionId: transaction.transactionId,
            statusId: transaction.statusId,
            typeOfProduct: transaction.typeOfProduct,
            dealDetails: transaction.dealDetails,
            ));
    final String currenUserId = transactionStream['currentUserId'];
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Icon(Icons.horizontal_rule, size: 45),),
      resizeToAvoidBottomInset: true,
      child: MultiBlocProvider(
        providers: [
        BlocProvider(create: (context) => StepperSelectionCubit(),),
        BlocProvider(create: (context) => ButtonStateCubit()),
            ],
        child: BlocListener<ButtonStateCubit, ButtonState>(
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
              }
          if (state is ButtonSuccessState){
            var snackbar = SnackBar(
                  content: Text(
                    "¡Trato Actualizado!",
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
        },
          child: Scaffold(
            appBar: BasicAppbar(
              height: 50,
              hideBack: true,
              title: 
                  Text(toBeginningOfSentenceCase(transaction.name!),),
            ),
            body: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionStream['transactionStream'],
                builder: (context, AsyncSnapshot<QuerySnapshot> state){
                  if (state.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if(state.hasError){
                    return Center(
                      child: Text(
                        "Ha ocurrido un Error, porfavor intenta de nuevo."
                      ),
                    );
                  }
                  StatusEntity statusEntity = state.data!.docs.map(
                      (element) => StatusModel.fromMap(element.data() as Map<String, dynamic>).toEntity()
                      ).toList()[0];
                  return BlocBuilder<StepperSelectionCubit, int>(
                      builder: (context, stepperState){
                      if(statusEntity.paymentDone!){
                        context.read<StepperSelectionCubit>().selectStep(4);
                      }
                      else if(statusEntity.paymentTransferred!){
                        context.read<StepperSelectionCubit>().selectStep(3);
                      }
                      else if (statusEntity.buyerConfirmation! && statusEntity.sellerConfirmation!){
                        context.read<StepperSelectionCubit>().selectStep(2);
                      }
                      else{
                        context.read<StepperSelectionCubit>().selectStep(1);
                      }
                      double transactionAmount = double.parse(transaction.amount!);
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 220, // Taller display canvas optimized for detailed product views
                      width: double.infinity,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              // Gallery Viewer Layer
                              GestureDetector(
                                onTap: () {
                   if (transaction.images != null && transaction.images!.isNotEmpty) {
                     showDialog(
        context: context,
        barrierDismissible: true, 
        barrierColor: Colors.black87, 
        builder: (BuildContext context) {
          return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Core Popup Card Container
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.6, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: PageView.builder(
                            itemCount: transaction.images!.length,
                            controller: PageController(viewportFraction: 1.0),
                            itemBuilder: (context, imageIndex) {
                              return InteractiveViewer(
                                clipBehavior: Clip.none,
                                minScale: 1.0,
                                maxScale: 4.0, 
                                child: Image(
                                  image: NetworkImage(transaction.images![imageIndex]),
                                  fit: BoxFit.contain, 
                                ),
                              );
                            },
                          ),
                        ),
                      ),
      
                      // 2. Clear Close Action Trigger (Top Right corner) - inside the Stack
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 22, color: Colors.white),
                          ),
                        ),
                      ),
      
                      // 3. Pinch Hint text overlay (Bottom Center) - inside the Stack
                      const Positioned(
                        bottom: 16,
                        child: IgnorePointer(
                          child: Row(
                            children: [
                              Icon(Icons.zoom_in, size: 16, color: Colors.white60),
                              SizedBox(width: 6),
                              Text(
                                "Pellizca para hacer zoom",
                                style: TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              SizedBox(width: 12,),
                              Icon(Icons.swipe_left, size: 16, color: Colors.white60),
                              Icon(Icons.swipe_right, size: 16, color: Colors.white60)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
    
                        },
                      );
                    }
                  },
                child:SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: (transaction.images == null || transaction.images!.isEmpty)
                    ? const Image(
                        image: AssetImage(AppImages.userLogo),
                        fit: BoxFit.cover,
                      )
                    : PageView.builder(
                        itemCount: transaction.images!.length,
                        controller: PageController(viewportFraction: 1.0),
                        itemBuilder: (context, imageIndex) {
                          return Image(
                            image: NetworkImage(transaction.images![imageIndex]),
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
            ),

                              // Product Condition Corner Band Layer
                              Positioned(
                                top: 6,
                                left: -20,
                                child: Transform.rotate(
                                  angle: -0.785398, // -45 Degrees rotation angle
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (transaction.typeOfProduct == 'Original')
                                          ? Colors.green.withValues(alpha: 0.95)
                                          : Colors.orange.withValues(alpha: 0.95),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                      ],
                                    ),
                                    child: Text(
                                      transaction.typeOfProduct == 'Reproducción' ? 'Repro' : 'Original',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Swipe Navigation Indicator (Only visible if multi-image array populates)
                              if (transaction.images != null && transaction.images!.length > 1)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.swipe_left, size: 16, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Icon(Icons.swipe_right, size: 16, color: Colors.white70),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),
                            StepperDeal(),
                            const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
                            SizedBox(height: 15,),
                            ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Container(
          width: MediaQuery.sizeOf(context).width/1.1,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(23), // Matches ClipRRect bounds perfectly
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      "Detalle del trato",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
    
                 // Interactive Info Icon
                 GestureDetector(
                   onTap: () {
                     showDialog(
                       context: context,
                       builder: (BuildContext context) {
                         return AlertDialog(
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                           title: const Text("Nota de Información"),
                           content: Text(
                                     statusEntity.details!,
                                     textAlign: TextAlign.justify,
                                     style: const TextStyle(fontSize: 15, height: 1.3),
                                   ),
                           actions: [
                             BasicAppButton(
                                       onPressed: () => Navigator.of(context).pop(),
                                       content: const Text("Entendido", 
                                       style: TextStyle(color: AppColors.primary)),
                                         ),
                                       ],
                                         );
                                       },
                                     );
                                   },
                                       child: Container(
                                         padding: const EdgeInsets.all(4), // Increases tap target size slightly
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           color: Colors.grey.withValues(alpha: 0.15), // Subtle background bubble
                                         ),
                                         child: const Icon(
                                           Icons.info_outline,
                                           size: 20,
                                           color: Colors.black54,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
      
              // 2. Structured Information Blocks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deal Counterparty Status Metric
                    Text(
                      'Trato con: ${currenUserId == statusEntity.buyerId ? toBeginningOfSentenceCase(transaction.buyerDisplayName) : toBeginningOfSentenceCase(transaction.sellerDisplayName)}',
                      style: const TextStyle(fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    Text("Descripción del producto\n",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("${transaction.dealDetails}",
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 12),
                    Row(
                     children: [
                       Text(
                         "Total a pagar: \$${(transactionAmount + double.parse(transaction.fee!)).truncateToDouble().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mxn",
                         style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       const SizedBox(width: 8),
                       
                       // Interactive Info Icon
                       GestureDetector(
                         onTap: () {
                           showDialog(
                             context: context,
                             builder: (BuildContext context) {
                               return AlertDialog(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                 title: const Text("Desglose del Precio"),
                                 content: Column(
                                   mainAxisSize: MainAxisSize.min, // Wraps content tightly
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     // Breakdown 1: Agreed Amount
                                     Text(
                                       "• Monto acordado: \$${transaction.amount!.replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mxn",
                                       style: const TextStyle(fontSize: 16, color: Colors.black87),
                                     ),
                                     const SizedBox(height: 12),
                                     
                                     // Breakdown 2: Commission Fee
                                     Text(
                                       "• Comisión Paklan: \$${transaction.fee!.replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mxn\n  (IVA incluido)",
                                       style: const TextStyle(fontSize: 16, color: Colors.black87),
                                     ),
                                   ],
                                 ),
                                 actions: [
                                   BasicAppButton(
                                             onPressed: () => Navigator.of(context).pop(),
                                             content: const Text("Entendido", 
                                             style: TextStyle(color: AppColors.primary)),
                                               ),
                                             ],
                                               );
                                             },
                                           );
                                         },
                                             child: Container(
                                               padding: const EdgeInsets.all(4), // Increases tap target size slightly
                                               decoration: BoxDecoration(
                                                 shape: BoxShape.circle,
                                                 color: Colors.grey.withValues(alpha: 0.15), // Subtle background bubble
                                               ),
                                               child: const Icon(
                                                 Icons.info_outline,
                                                 size: 20,
                                                 color: Colors.black54,
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 16),
                                     ],
                                   ),
                                 ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
        
        // 4. Action Blocks Section Flow
        const SizedBox(height: 10),
        const Center(
          child: Text(
            "Acciones a realizar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
          child: actions(context, statusEntity, currenUserId, transaction),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
                          ],
                        ),
                      );
                  }
                    );
                  },
                  ),
            ),
            ),
        )
          ),
    );
  }


Widget actions(BuildContext context, StatusEntity state, String currentUserId, TransactionEntity transaction){
  final String currentUser = currentUserId == state.buyerId ? 'Comprador' : 'Vendedor';
  if(state.cancelled!){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "No hay acciones disponibles a realizar, el trato ya está cancelado",
        style: TextStyle(fontSize: 16),
        ),
    );
  }
  if (currentUser == 'Vendedor' && state.status == 'Completado' && state.completedRatingMessageForBuyer!.isEmpty){
    return calificarUsuario(context, state);
  }
  if(state.status == 'Completado'){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "No hay acciones a realizar, el trato ya fué completado",
        style: TextStyle(fontSize: 16),
        ),
    );
  }
  if(currentUser == 'Vendedor' && state.paymentTransferred!){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "No hay acciones de tu parte, el comprador ya realizó la transferencia, sigue en espera de que el comprador te libere el pago",
        style: TextStyle(fontSize: 16),
        ),
    );
  
  }
  if(currentUser == 'Comprador' && state.paymentTransferred!){
    return Column(
      children: [
        Text("Liberar el pago al vendedor",
        style: TextStyle(
          fontSize: 16
        ),),
        SizedBox(height: 5,),
        Row(
          children: [
            SizedBox(width: 35,),
            liberarPago(context, state),
            SizedBox(width: 55,),
            ElevatedButton(
            style:  ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
               minimumSize: Size(
                120,
                50
               ),
             ),
              child: Row(
                children: [
                  Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.sms_failed_sharp)
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => CancelDeal(
                                      transaction: transaction,
                                      status: state,
                                      currentUserId: currentUserId,
                                      );
      return widgetBuilder(context);
    },
                                    ),
                                    );
              }
              ),
          ],
        )
      ],
    );
  }
  if(currentUser == 'Comprador' && state.buyerConfirmation! && state.sellerConfirmation!){
    return Column(
      children: [
        Text("Proceder a pagar la cantidad acordada",
        style: TextStyle(
          fontSize: 16
        ),),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
            style:  ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
               minimumSize: Size(
                120,
                50
               ),
             ),
             child: Text(
                    "Pagar",
                    style: TextStyle(color: Colors.white),
                    ),
              onPressed: () {
                Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => Payment(
                                      transaction: transaction,
                                      status: state,
                                      );
      return widgetBuilder(context);
    },
                                    ),
                                    );
              }
              ),
              ElevatedButton(
            style:  ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
               minimumSize: Size(
                120,
                50
               ),
             ),
              child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                    ),
              onPressed: () {
                Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => CancelDeal(
                                      transaction: transaction,
                                      status: state,
                                      currentUserId: currentUserId,
                                      );
      return widgetBuilder(context);
    },
                                    ),
                                    );
              }
              ),
          ],
        )
      ],
    );
  }
  if(currentUser == 'Vendedor' && state.buyerConfirmation! && state.sellerConfirmation!){
    return Column(
      children: [
        Text("El comprador está en proceso de pago...",
        style: TextStyle(
          fontSize: 16
        ),),
        SizedBox(height: 5,),
        
      ],
    );
  }
  if((currentUser == 'Comprador' && state.buyerConfirmation!) || (currentUser == 'Vendedor' && state.sellerConfirmation!)){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "No hay acciones de tu parte, hay que esperar a que la otra parte acepte el trato",
        style: TextStyle(
          fontSize: 16
        ),
        ),
      
      );
  
  }
  if((currentUser == 'Comprador' && !state.buyerConfirmation!) || (currentUser == 'Vendedor' && !state.sellerConfirmation!)){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Builder(
              builder: (context) {
            return CustomReactiveButton(
                                color: AppColors.primaryButton,
                                title: "Aceptar Trato",
                                onPressed: (){
                                    context.read<ButtonStateCubit>().execute(
                                          usecase: UpdateDealUseCase(),
                                          params: StatusModel(
                                              status: "Aceptado", 
                                              details: "Trato aceptado por $currentUser .\nRecuerda que tienes 8 días para concretar el trato, de lo contrario se cancelará por sistema.", 
                                              buyerConfirmation: currentUser == 'Comprador' ? true:state.buyerConfirmation, 
                                              sellerConfirmation: currentUser == 'Vendedor' ? true:state.sellerConfirmation, 
                                              transactionId: state.transactionId, 
                                              buyerId: state.buyerId, 
                                              sellerId: state.sellerId, 
                                              paymentDone: state.paymentDone, 
                                              paymentTransferred: state.paymentTransferred, 
                                              reimbursementDone: state.reimbursementDone, 
                                              cancelled: state.cancelled, 
                                              statusId: state.statusId,
                                          )
                                        );
                                  
                                },
                                );
              }
            ),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(50, 50),
                      backgroundColor: Colors.redAccent,
                       ),
                  child: Text(
                     "Rechazar Trato",
                     style: const TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.w400
                     ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder: (innerContext) => 
                      BlocProvider.value(
                    value: context.read<ButtonStateCubit>(),
                    child: AlertDialog(
        title: const Text('¿Quieres Cancelar el Trato?'),
        content: Text("Cancelar el trato notificará al vendedor/comprador"),
        actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                         minimumSize: Size(50, 50),
                        ),
                  child: Text(
                     "Regresar",
                     style: const TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.w400
                     ),
                  ),
                  onPressed: () => Navigator.pop(innerContext)
                      ),
                      VerticalDivider(width: 10,),
                      CustomReactiveButton(
                                        color: Colors.redAccent,
                                        title: "Rechazar",
                                        onPressed: (){
                                          context.read<ButtonStateCubit>().execute(
                                          usecase: UpdateDealUseCase(),
                                          params: StatusModel(
                                              status: "Cancelado", 
                                              details: "Trato Cancelado por $currentUser", 
                                              buyerConfirmation: state.buyerConfirmation, 
                                              sellerConfirmation: state.sellerConfirmation, 
                                              transactionId: state.transactionId, 
                                              buyerId: state.buyerId, 
                                              sellerId: state.sellerId, 
                                              paymentDone: state.paymentDone, 
                                              paymentTransferred: state.paymentTransferred, 
                                              reimbursementDone: state.reimbursementDone, 
                                              cancelled: true, 
                                              statusId: state.statusId,
                                              cancelledBy: currentUserId,
                                          )
                                        );
                                        Navigator.pop(innerContext);
                                        },
                                        ),
                                        ],
      )
                      
                    ) );
                  },
                );
              
              
              }
            ),
          ],
        ),
        SizedBox(height: 15,),
        
      ],

    );
  }
  return Column();
}


  Form reasonToCancelForm(BuildContext context) {
    return Form(
        key: _formKeyCancel,
        child: TextFormField(
        controller: _cancelCon1,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        validator: (value){
        if (value!.isEmpty){
          return 'El campo no debe estar vacío';
        }
        if (value.length>150){
          return 'El Campo no debe exceder los 150 caracteres';
        }
        if (value.length<5){
          return 'El Campo debe ser mayor a 5 caracteres';
        }
        else{
          return null;
        }
                },
            
          ),
      );
  }

Builder liberarPago(BuildContext mainContext, StatusEntity state) {
  return Builder(
            builder: (mainContext) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 50),
                    backgroundColor: Colors.blue,
                     ),
                child:  Row(
                children: [
                  Text(
                    "Liberar Pago",
                    style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.payments_sharp)
                ],
              ),
                onPressed: () {
                              Navigator.of(mainContext).push(
                              CupertinoSheetRoute<void>(
                              scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => Rating(
                              transaction: transaction,
                              status: state,
                              currentUserId: "Comprador",
                              );
      return widgetBuilder(context);
    },
                            ),
                            );
                              }
                    
                 );
                },
              );
            
            
            }
  
  Builder calificarUsuario(BuildContext mainContext, StatusEntity state) {
  return Builder(
            builder: (mainContext) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 50),
                    backgroundColor: Colors.blue,
                     ),
                child:  Row(
                children: [
                  Text(textAlign: TextAlign.center,
                    "Calificar Usuario",
                    style: TextStyle(color: Colors.white,),
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.rate_review_sharp)
                ],
              ),
                onPressed: () {
                              Navigator.of(mainContext).push(
                              CupertinoSheetRoute<void>(
                              scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => RatingBuyer(
                              transaction: transaction,
                              status: state,
                              currentUserId: "Comprador",
                              );
      return widgetBuilder(context);
    },
                            ),
                            );
                              }
                    
                 );
                },
              );
            
            
            }
}



class StepperDeal extends StatelessWidget {
  const StepperDeal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EasyStepper(
      stepRadius: 20.0,
      borderThickness: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      activeStepBackgroundColor: AppColors.primary,
      unreachedStepBackgroundColor: AppColors.secondBackground,
      finishedStepBackgroundColor: Colors.green[200],
      activeStep: context.read<StepperSelectionCubit>().selectedIndex,
      direction: Axis.horizontal,
       steps: [
        EasyStep(
          enabled: false,
          customStep: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(15),
            child: Opacity(
              opacity: context.read<StepperSelectionCubit>().selectedIndex >= 0 ? 1 : 0.3,
              child: SvgPicture.asset(
                AppVectors.check,
                height: 38,
                width: 38,
              ),
              ),
          ),
          customTitle: const Text(
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              "Trato\n Envíado",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500
              ),
              ),
          ),
                        
          EasyStep(
          enabled: false,
          customStep: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(15),
            child: Opacity(
              opacity: context.read<StepperSelectionCubit>().selectedIndex >= 1 ? 1 : 0.3,
              child: SvgPicture.asset(
                AppVectors.handshake,
                height: 38,
                width: 38,
              ),
              ),
          ),
          customTitle: const Text(
            "Trato\n Confirmado",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500
              )
            )
          ),
    
          EasyStep(
          icon: const Icon(CupertinoIcons.bitcoin_circle_fill),
          enabled: false,
          customStep: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(15),
            child: Opacity(
              opacity: context.read<StepperSelectionCubit>().selectedIndex >= 2 ? 1 : 0.3,
              child: SvgPicture.asset(
                AppVectors.pay,
                height: 38,
                width: 38,
              ),
              ),
          ),
          customTitle: const Text(
            "Trato\n Pagado",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500
              )
            )
          ),
    
          EasyStep(
          enabled: false,
          customStep: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(15),
            child: Opacity(
              opacity: context.read<StepperSelectionCubit>().selectedIndex >= 3 ? 1 : 0.3,
              child: SvgPicture.asset(
                AppVectors.finish,
                height: 38,
                width: 38,
              ),
              ),
          ),
          customTitle: const Text(
            "Trato\n Completado",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500
              )
            )
          ),
       ]
       );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/bottomsheet/app_bottomsheet.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_clabes.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';
import 'package:paklan/domain/transactions/usecases/get_transaction.dart';
import 'package:paklan/presentation/home/widgets/credit_card_ui.dart';
import 'package:paklan/presentation/transactions/bloc/clabe_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/stepper_selection_cubit.dart';
import 'package:paklan/service_locator.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _clabeStream = sl<GetClabesUseCase>().call();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cancelCon = TextEditingController();
  TransactionDetail({super.key, required this.transaction});
  
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> transactionStream = sl<GetTransactionUseCase>().call(
      params: TransactionModel(
            name: transaction.name,
            amount: transaction.amount, 
            status: transaction.status, 
            sellerFirstName: transaction.sellerFirstName, 
            buyerFirstName: transaction.buyerFirstName, 
            transactionId: transaction.transactionId,
            statusId: transaction.statusId
            ));
    final String currenUserId = transactionStream['currentUserId'];
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: MultiBlocProvider(
        providers: [
        BlocProvider(create: (context) => StepperSelectionCubit(),),
        BlocProvider(create: (context) => ButtonStateCubit()),
        BlocProvider(create: (context) => ClabeSelectionCubit()),
        
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
              
              hideBack: true,
              title: 
                  Text("Detalle del Trato"),
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
                      if (statusEntity.buyerConfirmation! && statusEntity.sellerConfirmation!){
                        context.read<StepperSelectionCubit>().selectStep(2);
                      }
                      else if(statusEntity.paymentDone!){
                        context.read<StepperSelectionCubit>().selectStep(3);
                      }
                      else if(statusEntity.paymentTransferred!){
                        context.read<StepperSelectionCubit>().selectStep(4);
                      }
                      else{
                        context.read<StepperSelectionCubit>().selectStep(1);
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            StepperDeal(),
                            SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(23),
                                color: Colors.black26,
                              ),
                              width: MediaQuery.sizeOf(context).width,
                              child: Column(
                                children: [
                                  SizedBox(height: 10,),
                                  const Text(
                                  "Detalle del Estátus:",
                                  style: TextStyle(
                                    fontSize: 23
                                  )
                                  ),
                                  SizedBox(height: 10,),
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: 
                                      Text(
                                            statusEntity.details!,
                                            style: TextStyle(
                                              fontSize: 17,
                                              )
                                              ),
                                    
                                  ),
                              const Divider(),
                              SizedBox(height: 10,),
                              const Text(
                                "Monto del Trato:",
                                style: TextStyle(
                                  fontSize: 23
                                )
                                ),
                              SizedBox(
                                height: 40,
                                child: Text(
                                  '\$${transaction.amount!} mxn',
                                  style: TextStyle(
                                    fontSize: 17
                                  )
                                  ),
                              ),
                                const Divider(),
                                SizedBox(height: 10,),
                                const Text(
                                "Acciones a realizar:",
                                style: TextStyle(
                                  fontSize: 23
                                )
                                ),
                                SizedBox(height: 10,),
                                actions(context, statusEntity, currenUserId),
                                ],
                                  
                              ),
                            ),
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


Widget actions(BuildContext context, StatusEntity state, String currentUserId){
  final String currentUser = currentUserId == state.buyerId ? 'Comprador' : 'Vendedor';
  if(state.cancelled!){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "No hay acciones disponibles a realizar, el trato ya está cancelado",
        style: TextStyle(fontSize: 20),
        ),
    );
  }
  if(currentUser == 'Comprador' && state.buyerConfirmation! && state.sellerConfirmation!){
    return Column(
      children: [
        Text("Proceder a pagar la cantidad acordada",
        style: TextStyle(
          fontSize: 20
        ),),
        SizedBox(height: 5,),
        Row(
          children: [
            SizedBox(width: 35,),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(50, 50),
                      backgroundColor: Colors.redAccent,
                       ),
                  child: Text(
                     "Cancelar Trato",
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
        content: Text("Cancelar el trato notificará al vendedor/comprador.\nPorfavor escribe la razón de la cancelación."),
        actions: [    
          Form(
            key: _formKey,
            child: TextFormField(
            controller: _cancelCon,
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
          ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                             minimumSize: Size(60, 50),
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
                          VerticalDivider(width: 20,),
                      CustomReactiveButton(
                                        color: Colors.redAccent,
                                        title: "Cancelar Trato",
                                        onPressed: (){
                                          if (_formKey.currentState!.validate()){
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
                                              cancelMessage: _cancelCon.text
                                          )
                                        );
                                        Navigator.pop(innerContext);
                                        }
                                        }
                                        ),
                        ],
                      ),
                      
                                        ],
      )
                      
                    ) );
                  },
                );
              
              
              }
            ),
            SizedBox(width: 10,),
            BasicAppButton(
              width: 160,
              title: "Pagar",
              onPressed: () {
                // Navigator.of(context).push(
                //                     CupertinoSheetRoute<void>(
                //                      builder: (BuildContext context) => TransactionDetail(
                //                       transaction: state
                //                       ),
                //                     ),
                //                     );
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
          fontSize: 20
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
          fontSize: 20
        ),
        ),
      
      );
  
  }
  if((currentUser == 'Comprador' && !state.buyerConfirmation!) || (currentUser == 'Vendedor' && !state.sellerConfirmation!)){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            child: const Text(
              "¡Selecciona una cuenta CLABE para que se te pueda transferir o rembolsar tu dinero!",
              style: TextStyle(
                fontSize: 17
              ),
            ),
          ),
        ),
        SizedBox(height: 5,),
        _clabes(),
        SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(width: 35,),
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
            SizedBox(width: 35,),
            Builder(
              builder: (context) {
            return CustomReactiveButton(
                                color: Colors.blueAccent,
                                title: "Aceptar Trato",
                                onPressed: (){
                                  String clabe = context.read<ClabeSelectionCubit>().selectedClabe;
                                   if (clabe.isNotEmpty){
                                    context.read<ButtonStateCubit>().execute(
                                          usecase: UpdateDealUseCase(),
                                          params: StatusModel(
                                              status: "En proceso", 
                                              details: "Trato Aceptado por $currentUser .\nRecuerda que tienes 8 días para concretar el trato, de lo contrario se cancelará por sistema.", 
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
                                              timeLimit: DateTime.now().toUtc().add(Duration(days: 8)),
                                          )
                                        );
                                  }
                                  else if(clabe.isEmpty){
                                     var snackbar = SnackBar(
                                       content: Text(
                                         "No has seleccionado una cuenta CLABE",
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

Widget _clabes() {
    return StreamBuilder(
      stream: _clabeStream, 
      builder: (context, AsyncSnapshot<DocumentSnapshot> state){
              if(state.hasError){
                return SizedBox(
                  height: 100,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Ha ocurrido un error, por favor intenta más tarde",
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                  ),
                );
              }
              if(state.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> userData = state.data!.data() as Map<String, dynamic>;
              if (!userData.keys.contains("CLABEs") || userData['CLABEs'].length == 0){
                return SizedBox(
                  height: 120,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        "No Tienes Cuentas registradas, primero registra una en el apartado de Cuentas en la página principal.",
                        style: TextStyle(
                          fontSize: 17
                        ),
                      ),
                    ),
                  ),
                );
              }
              
        
              return BlocBuilder<ClabeSelectionCubit, String>(
                builder: (context, state) {
                return  GestureDetector(
                        onTap: (){
                          AppBottomsheet.display(
                            context,
                            SizedBox(
                             height: MediaQuery.of(context).size.height / 3.6,
                             child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (innerContext, index){
                          return GestureDetector(
                            onTap: (){
                Navigator.pop(innerContext);
                context.read<ClabeSelectionCubit>().selectClabe(
                  userData['CLABEs'][index],
                );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: CreditCardUiCustom(
                                     userData: userData, 
                                     index: index
                                 ),
                            ),
                          );
                        }, 
                        separatorBuilder: (context, index) => SizedBox(width: 20,), 
                        itemCount: userData['CLABEs'].length
                        )
                            )
                            );
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.secondBackground,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                             Text(
                               state
                             ),
                             const Icon(
                               Icons.keyboard_arrow_down
                             )
                            ],
                          ),
                        ),
                      );
      }
              );
    }
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
      activeStepBackgroundColor: AppColors.primary,
      unreachedStepBackgroundColor: Colors.white70,
      finishedStepBackgroundColor: Colors.lightGreen,
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
            "Trato Confirmado",
            textAlign: TextAlign.center,
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
            "Trato Pagado",
            textAlign: TextAlign.center,
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
            "Trato Completado",
            textAlign: TextAlign.center,
            )
          ),
       ]
       );
  }
}
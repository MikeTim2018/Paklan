import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
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
import 'package:paklan/domain/transactions/usecases/update_deal.dart';
import 'package:paklan/domain/transactions/usecases/get_transaction.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';
import 'package:paklan/presentation/transactions/bloc/stepper_selection_cubit.dart';
import 'package:paklan/service_locator.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _clabe = TextEditingController();
  TransactionDetail({super.key, required this.transaction});
  
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> transactionStream = sl<GetTransactionUseCase>().call(
      params: TransactionModel(
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
                                  SizedBox(
                                    height: 40,
                                    child: Text(
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
        BasicAppButton(
          title: "Pagar",
          onPressed: () => AppNavigator.push(context, SigninPage()),)
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
              "¡Ingresa tu cuenta CLABE para que se te pueda transferir o rembolsar tu dinero!",
              style: TextStyle(
                fontSize: 17
              ),
            ),
          ),
        ),
        SizedBox(height: 5,),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
            
            validator: (value){
              if (value!.isEmpty || value.length!=18 || RegExp(r'\D+').hasMatch(value)){
                return 'Tu cuenta CLABE debe ser igual a 18 dígitos';
              }
              else{
                return null;
              }
            },
            enableSuggestions: false,
            autocorrect: false,
            controller: _clabe,
            decoration: InputDecoration(
              hintText: "Ingresa tu cuenta CLABE"
            ),
                   ),
          ),
        ),
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
        content: Flexible(child: Text("Cancelar el trato notificará al vendedor/comprador")),
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
                                  if (_formKey.currentState!.validate()){
                                    context.read<ButtonStateCubit>().execute(
                                          usecase: UpdateDealUseCase(),
                                          params: StatusModel(
                                              status: "En proceso", 
                                              details: "Trato Aceptado por $currentUser", 
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
                                              cancelledBy: currentUserId,
                                          )
                                        );
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
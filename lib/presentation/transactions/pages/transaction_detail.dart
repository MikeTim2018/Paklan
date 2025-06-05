import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/status.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/presentation/transactions/bloc/stepper_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/transaction_state_display_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/transaction_state_display_state.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;
  const TransactionDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: MultiBlocProvider(
        providers: [
        BlocProvider(
          create: (context) => TransactionStateDisplayCubit()..getTransactionState(
          transaction: TransactionModel(
            amount: transaction.amount, 
            status: transaction.status, 
            sellerFirstName: transaction.sellerFirstName, 
            buyerFirstName: transaction.buyerFirstName, 
            transactionId: transaction.transactionId,
            statusId: transaction.statusId
            )
            ),
            ),
        BlocProvider(
          create: (context) => StepperSelectionCubit()
          ),
            ],
        child: Scaffold(
          appBar: BasicAppbar(
            hideBack: true,
            title: 
                Text("Detalle del Trato"),
          ),
          body: SingleChildScrollView(
            child: BlocBuilder<TransactionStateDisplayCubit, TransactionStateDisplayState>(
              builder: (context, state){
                if (state is TransactionLoading){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (state is TransactionLoaded){
                  return BlocBuilder<StepperSelectionCubit, int>(
                    builder: (context, stepperState){
                    if (state.state.buyerConfirmation! && state.state.sellerConfirmation!){
                      context.read<StepperSelectionCubit>().selectStep(2);
                    }
                    if(state.state.paymentDone!){
                      context.read<StepperSelectionCubit>().selectStep(3);
                    }
                    if(state.state.paymentTransferred!){
                      context.read<StepperSelectionCubit>().selectStep(4);
                    }
                    else{
                      context.read<StepperSelectionCubit>().selectStep(1);
                    }
                    return Column(
                      children: [
                        StepperDeal(),
                        SizedBox(height: 25,),
                        const Text(
                          "Detalle del Estátus:",
                          style: TextStyle(
                            fontSize: 23
                          )
                          ),
                  
                        Text(
                          state.state.details!,
                          style: TextStyle(
                            fontSize: 23
                          )
                          ),
                        SizedBox(height: 25,),
                        const Text(
                          "Monto del Trato:",
                          style: TextStyle(
                            fontSize: 23
                          )
                          ),
                        Text(
                          '\$${transaction.amount!} mxn',
                          style: TextStyle(
                            fontSize: 23
                          )
                          ),
                          SizedBox(height: 25,),
                          const Text(
                          "Acciones a realizar:",
                          style: TextStyle(
                            fontSize: 23
                          )
                          ),
                          SizedBox(height: 10,),
                          actions(context, state.state),
                      ],
                    );
                }
                  );
                }
                if(state is TransactionFailure){
                  return Center(
                    child: Text(
                      "Ha ocurrido un Error, porfavor intenta de nuevo."
                    ),
                  );
                }
                return Container();
              },
                
                ),
          ),
          )
          ),
    );
  }

}

Widget actions(BuildContext context, StatusEntity state){
  if(state.currentUser == 'buyer' && !state.buyerConfirmation!){
    return Column(
      children: [
        Row(
          children: [
            BasicReactiveButton(
                                title: "Aceptar Trato",
                                onPressed: (){},
                                ),
            BasicReactiveButton(
                                title: "Cancelar Trato",
                                onPressed: (){},
                                ),
          ],
        ),
        
      ],

    );
  }
  if(state.currentUser == 'seller' ){
    return Column(
      children: [
        const Text(
          "¡Ingresa tu cuenta CLABE para que el comprador te pueda transferir tu dinero!",
          style: TextStyle(
            fontSize: 23
          ),
        ),

        Row(
          children: [
            BasicAppButton( width: 50,
                                title: "Aceptar Trato",
                                onPressed: (){},
                                ),
            BasicAppButton(width: 50,
                                title: "Cancelar Trato",
                                onPressed: (){},
                                ),
          ],
        ),
        
      ],

    );
  }
  return Column();
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
            "Trato Envíado",
            textAlign: TextAlign.center,
            )
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
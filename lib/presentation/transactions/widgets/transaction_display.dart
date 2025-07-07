import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/bloc/server_time/server_time_state.dart';
import 'package:paklan/common/bloc/server_time/server_time_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_transactions.dart';
import 'package:paklan/presentation/transactions/pages/transaction_detail.dart';
import 'package:paklan/presentation/transactions/pages/transaction_search.dart';
import 'package:paklan/service_locator.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;


class TransactionDisplay extends StatelessWidget{
  TransactionDisplay({super.key});
  final Stream<QuerySnapshot> _transactionsStream =  sl<GetTransactionsUseCase>().call();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServerTimeStateCubit()..getServerTime(),
      child: StreamBuilder<QuerySnapshot>(
            stream: _transactionsStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> state){
            if (state.connectionState == ConnectionState.waiting){
              return SizedBox(
                height: 400,
                child: Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator()
                  ),
              );
            }
            if (state.hasError){
              return SizedBox(
                height: 400,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Ha ocurrido un error, por favor intenta más tarde.",
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                ),
              );
            }
            if (state.data == null || state.data!.docs.isEmpty){
              return listNoTransaction(context);
            }
            return Column(
                  children: [
                    SizedBox(height: 50,),
                    Text(
                      "Tratos en Curso",
                      style: TextStyle(
                        fontSize: 20
                      ),
                      ),
                    SizedBox(height: 20,),
                    listTransactions(context, state.data!.docs.map(
                      (element) => TransactionModel.fromMap(element.data() as Map<String, dynamic>).toEntity()
                      ).toList(),
                      _scrollController
                      ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BasicAppButton(
                        onPressed: (){
                          AppNavigator.push(context, TransactionSearch());
                          },
                          width: 200,
                          title: 'Iniciar Trato'
                      ),
                    ),
                
                  ],
              );
            }
          ),
    );
  }
}

Widget listNoTransaction(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
                  SizedBox(height: 100,),
                  Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: const AssetImage(
                          AppImages.noTrades
                        ),
                        )
                    ),
                  ),
                  SizedBox(height: 50,),
                  Text(
                    "Sin Tratos Activos",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "¡Comienza ahora!",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary
                    ),
                  ),
                  SizedBox(height: 30,),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BasicAppButton(
                      onPressed: (){
                        AppNavigator.push(context, TransactionSearch());
                        },
                        width: 200,
                        title: 'Iniciar Trato'
                    ),
                  ),
                  ]
                  ),
    );
  }


  Widget listTransactions(BuildContext context, List<TransactionEntity> state, ScrollController scrollController) {
    return SizedBox(
        height: 400,
      child: RawScrollbar(
        thumbVisibility: true,
        controller: scrollController,
        thumbColor: Colors.white24,
        shape: const StadiumBorder(),
        timeToFade: Duration(seconds: 1),
        thickness: 8,
        child: ListView.separated(
          controller: scrollController,
          padding: EdgeInsets.all(9),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     builder: (BuildContext context) => TransactionDetail(
                                      transaction: state[index]
                                      ),
                                    ),
                                    );
                                  },
                                  child: transactionTile(state, index),
                                );
                              },
                               separatorBuilder: (context, index) => const SizedBox(height: 10,),
                               itemCount: state.length
                            ),
      ),
    );
  }

  Widget transactionTile(List<TransactionEntity> status, int index) {
    return BlocBuilder<ServerTimeStateCubit, ServerTimeState>(
      builder: (context, state) {
        if(state is ServerTimeLoadingState){
          return const Center(child: CircularProgressIndicator(),);
        }
        if(state is ServerTimeFailureState){
          return Center(
                      child: Text(
                        "Ha ocurrido un Error, porfavor intenta de nuevo."
                      ),
                    );
        }
        if (state is ServerTimeLoadedState){
          return Column(
          children: [
            Align(
             alignment: AlignmentGeometry.directional(0.7, 10),
             child: SlideCountdown(
              showZeroValue: false,
              icon: SizedBox(
                height: 20, 
                width: 20,
                child: SvgPicture.asset(AppVectors.clock, fit: BoxFit.fill,)),
              decoration: BoxDecoration(
                color: switch (status[index].timeLimit!.difference(DateTime.parse(state.serverTime)).inHours) {
                               <= 12 && >= 6 => const Color.fromARGB(255, 225, 179, 14),
                               <= 5 && >= 0 => const Color.fromARGB(255, 225, 70, 14),
                               _ => const Color.fromARGB(216, 71, 145, 50),
                               },
                borderRadius: BorderRadius.circular(15)
                ),
              duration: Duration(seconds: status[index].timeLimit!.difference(DateTime.parse(state.serverTime)).inSeconds),
            )
            ),
          Card(
            child: ListTile(
              shape: StadiumBorder(side: BorderSide(
                width: 2,
                color: switch (status[index].timeLimit!.difference(DateTime.parse(state.serverTime)).inHours) {
                               <= 12 && >= 6 => const Color.fromARGB(255, 225, 179, 14),
                               <= 5 && >= 0 => const Color.fromARGB(255, 225, 70, 14),
                               _ => const Color.fromARGB(216, 71, 145, 50),
                               },
                               )
                               ),
              tileColor: AppColors.secondBackground,
              leading: CircleAvatar(
                backgroundColor: AppColors.secondBackground,
                radius: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: SvgPicture.asset(
                      AppVectors.cash,
                      fit: BoxFit.fill,
                    ),
                ),
              ),
              title: Text(
                '${toBeginningOfSentenceCase(status[index].name)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
                ),
                subtitle: Text(
                  'Monto: \$${status[index].amount}\nVendedor: ${status[index].sellerFirstName}\nComprador: ${status[index].buyerFirstName}',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppVectors.info,
                    fit: BoxFit.none,
                  ),
                ),
            ),
          ),
        ],
      );
      }
      return Container();

      }
      
    );
  }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_completed_transactions.dart';
import 'package:paklan/presentation/transactions/pages/transaction_detail.dart';
import 'package:paklan/service_locator.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;


class TransactionHistory extends StatelessWidget {
  TransactionHistory({super.key});
  final Stream<QuerySnapshot> _transactionsStream =  sl<GetCompletedTransactionsUseCase>().call();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
                  "Ha ocurrido un error, por favor intenta más tarde",
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
          return Scaffold(
            body: Column(
                  children: [
                    SizedBox(height: 100,),
                    Text(
                      "Tratos Completados y Cancelados",
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
                
                  ],
              ),
          );
          }
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
                    "No hay Tratos Completados o Cancelados",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white70
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
        controller: scrollController,
        thumbVisibility: true,
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

  Widget transactionTile(List<TransactionEntity> state, int index) {
    return Card(
      child: ListTile(
        shape: StadiumBorder(
          side: BorderSide(
            width: 2,
            color: state[index].status=='Cancelado' ? Colors.red : Colors.blue
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
              '${toBeginningOfSentenceCase(state[index].name)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              ),
              subtitle: Text(
                'Monto: \$${state[index].amount}\nVendedor: ${state[index].sellerFirstName}\nComprador: ${state[index].buyerFirstName}',
                style: TextStyle(
                  color: Colors.grey
                ),
                overflow: TextOverflow.ellipsis,
              ),
          trailing: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              state[index].status=='Completado'? AppVectors.check : AppVectors.error,
              fit: BoxFit.fill,
            ),
          ),
      ),
    );
  }
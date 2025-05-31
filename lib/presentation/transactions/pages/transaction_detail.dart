

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/presentation/transactions/bloc/transaction_state_display_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/transaction_state_display_state.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;
  const TransactionDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: BlocProvider(
        create: (context) => TransactionStateDisplayCubit()..getTransactionState(
          transaction: TransactionModel(
            amount: transaction.amount, 
            status: transaction.status, 
            sellerFirstName: transaction.sellerFirstName, 
            buyerFirstName: transaction.buyerFirstName, 
            transactionId: transaction.transactionId,
            statusId: transaction.statusId)
            ),
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
                  return Column(
                    children: [
                      Center(
                        child: Container()
                        ),
                    ],
                  );
                }
                if (state is TransactionInitial){
                  return Container();
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
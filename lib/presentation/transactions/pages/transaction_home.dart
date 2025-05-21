import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/transactions/transactions_display_cubit.dart';
import 'package:paklan/presentation/home/widgets/header.dart';
import 'package:paklan/presentation/transactions/widgets/transaction_display.dart';


class TransactionHome extends StatelessWidget {
  const TransactionHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: BlocProvider(
                 create: (context) => TransactionsDisplayCubit()..displayTransactions(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Header(),
                    TransactionDisplay(),
                  ],
                ),
              ),)
              ),
            ]
            ),
      ),
      );
    }
}


import 'package:flutter/material.dart';
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
            Column(
                  children: [
                    Header(),
                    TransactionDisplay(),
                  ],
                ),
            ]
            ),
      ),
      );
    }
}


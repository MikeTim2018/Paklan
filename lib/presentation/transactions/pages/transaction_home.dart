import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/widgets/header.dart';
import 'package:paklan/presentation/transactions/widgets/transaction_display.dart';


class TransactionHome extends StatelessWidget {
  const TransactionHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
      create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
          child: SingleChildScrollView(
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
    )
      );
    }
}


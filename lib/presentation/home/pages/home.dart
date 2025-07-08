import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/bottom_nav_cubit.dart';
import 'package:paklan/common/widgets/bottom_nav_bar/main_wrapper.dart';
import 'package:paklan/presentation/home/pages/settings.dart';
import 'package:paklan/presentation/transactions/pages/transaction_history.dart';
import 'package:paklan/presentation/transactions/pages/transaction_home.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});
  PageController pageController = PageController();

  final List<Widget> pages = [
    TransactionHome(),
    TransactionHistory(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavCubit()),
                ],
        child: MainWrapper(),
    );
    }
}

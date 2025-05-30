import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/navigation_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/navigation_state.dart';
import 'package:paklan/common/widgets/bottom_nav_bar/bottom_navigation.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';
import 'package:paklan/presentation/transactions/pages/transaction_home.dart';
import 'package:paklan/presentation/transactions/pages/transaction_success_wo_confirmation.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> pages = [
    TransactionHome(),
    TransactionSuccessWoConfirmation(),
    SigninPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
                  ],
      child:  Scaffold(
          bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state){
              int currentIndex = 0;
              if (state is NavigationChanged){
                currentIndex = state.index;
              }
              return BottomNavBar( 
              currentIndex: currentIndex);
            },
          ),
          body: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state){
              if(state is NavigationChanged){
                return pages[state.index];
              }
              return pages[0];
            },
            ),
        )
    );
    }
}

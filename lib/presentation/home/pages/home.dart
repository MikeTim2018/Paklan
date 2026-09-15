import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/bottom_nav_cubit.dart';
import 'package:paklan/common/widgets/bottom_nav_bar/main_wrapper.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});
  PageController pageController = PageController();

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

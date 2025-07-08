
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/bottom_nav_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/home/pages/settings.dart';
import 'package:paklan/presentation/transactions/pages/transaction_history.dart';
import 'package:paklan/presentation/transactions/pages/transaction_home.dart';
import 'package:paklan/presentation/transactions/pages/transaction_search.dart';



class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Top Level Pages
  final List<Widget> topLevelPages =  [
    TransactionHome(),
    TransactionHistory(),
    Settings(),
  ];

  /// on Page Changed
  void onPageChanged(int page) {
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _mainWrapperBody(),
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _mainWrapperFab(),
    );
  }

  // Bottom Navigation Bar - MainWrapper Widget
  BottomAppBar _mainWrapperBottomNavBar(BuildContext context) {
    return BottomAppBar(
      height: 82,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.home,
                  page: 0,
                  label: "Inicio",
                  filledIcon: IconlyBold.home,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.time_circle,
                  page: 1,
                  label: "Historial",
                  filledIcon: IconlyBold.time_circle,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.wallet,
                  page: 2,
                  label: "Cuentas",
                  filledIcon: IconlyBold.wallet,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  // Floating Action Button - MainWrapper Widget
  FloatingActionButton _mainWrapperFab() {
    return FloatingActionButton.extended(
      label: Text("Nuevo trato"),
      onPressed: () {
        AppNavigator.push(context, TransactionSearch());
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: const Color.fromARGB(255, 92, 144, 212),
      icon: const Icon(Icons.handshake_outlined),
    );
  }


  // Body - MainWrapper Widget
  PageView _mainWrapperBody() {
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: topLevelPages,
    );
  }

  // Bottom Navigation Bar Single item - MainWrapper Widget
  Widget _bottomAppBarItem(
    BuildContext context, {
    required defaultIcon,
    required page,
    required label,
    required filledIcon,
  }) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);

        pageController.animateToPage(page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Icon(
              context.watch<BottomNavCubit>().state == page
                  ? filledIcon
                  : defaultIcon,
              color: context.watch<BottomNavCubit>().state == page
                  ? AppColors.background
                  : Colors.black38,
              size: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: TextStyle(
                color: context.watch<BottomNavCubit>().state == page
                    ? AppColors.background
                    : Colors.black38,
                fontSize: 13,
                fontWeight: context.watch<BottomNavCubit>().state == page
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
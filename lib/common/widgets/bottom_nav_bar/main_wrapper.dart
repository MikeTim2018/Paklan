
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/bottom_nav_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/home/pages/settings.dart' as home_settings;
import 'package:paklan/presentation/in_search_of/pages/in_search_of_home.dart';
import 'package:paklan/presentation/transactions/pages/transaction_history.dart';
import 'package:paklan/presentation/transactions/pages/transaction_home.dart';
import 'package:paklan/presentation/transactions/pages/transaction_search.dart';



class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  Null get pageController => null;

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
    InSearchOfHome(),
    TransactionHistory(),
    home_settings.Settings(),
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
      height: 85,
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
                  defaultIcon: Icons.home,
                  page: 0,
                  label: "Inicio",
                  filledIcon: Icons.home_filled,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: Icons.price_change_outlined,
                  page: 1,
                  label: "Se busca",
                  filledIcon: Icons.price_change_rounded,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: Icons.sell_outlined,
                  page: 2,
                  label: "Comprar",
                  filledIcon: Icons.sell,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: Icons.compare_arrows,
                  page: 3,
                  label: "Trueque",
                  filledIcon: Icons.compare_arrows_outlined,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: Icons.menu,
                  page: 3,
                  label: "Menu",
                  filledIcon: Icons.menu_outlined,
                ),
              ], 
            ),
            
          ),
        ],
      ),
    );
  }

  // Floating Action Button - MainWrapper Widget
  Widget _mainWrapperFab() {
              return FloatingActionButton.extended(
                heroTag: 'addDeal',
                label: Text("Trato Flash",
                style: TextStyle(
                  color: Colors.white70
                ),),
                onPressed: () {
                  AppNavigator.push(context, TransactionSearch());
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                backgroundColor: AppColors.primaryButton,
                icon: Icon(Icons.flash_on_outlined, color: Colors.yellow[200],),

      );
    }


  // Body - MainWrapper Widget
Widget _mainWrapperBody() {
  return BlocListener<BottomNavCubit, int>(
    listener: (context, state) {
      // Sync the PageController whenever BottomNavCubit changes
      if (pageController.hasClients && pageController.page?.round() != state) {
        pageController.animateToPage(
          state,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    },
    child: PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: topLevelPages,
    ),
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
                  ? Colors.black87
                  : Colors.black26,
              size: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: TextStyle(
                color: context.watch<BottomNavCubit>().state == page
                    ? Colors.black87
                    : Colors.black26,
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
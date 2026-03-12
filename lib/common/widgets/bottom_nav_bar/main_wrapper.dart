
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/bottom_nav_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/transactions/usecases/get_clabes.dart';
import 'package:paklan/presentation/home/pages/settings.dart' as home_settings;
import 'package:paklan/presentation/transactions/pages/transaction_history.dart';
import 'package:paklan/presentation/transactions/pages/transaction_home.dart';
import 'package:paklan/presentation/transactions/pages/transaction_search.dart';
import 'package:paklan/service_locator.dart';



class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  get pageController => null;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late PageController pageController;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _clabeStream = sl<GetClabesUseCase>().call();

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
  Widget _mainWrapperFab() {
    return StreamBuilder<DocumentSnapshot>(
              stream: _clabeStream,
              builder: (context, AsyncSnapshot<DocumentSnapshot> state){
              if(state.hasError){
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
              if(state.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> userData = state.data!.data() as Map<String, dynamic>;
              return FloatingActionButton.extended(
                heroTag: 'addDeal',
                label: Text("Nuevo trato"),
                onPressed: () {
                  if (!userData.keys.contains("CLABEs") || userData['CLABEs'].length == 0){
                  var snackbar = SnackBar(
                  content: Text(
                    "¡Debes primero registrar una cuenta clabe!",
                    style: TextStyle(
                      color: Colors.white70
                    ),),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  showCloseIcon: true,
                  closeIconColor: Colors.white70,
                  );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  
                  }
                  else{
                  AppNavigator.push(context, TransactionSearch());
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                backgroundColor: const Color.fromARGB(255, 92, 144, 212),
                icon: const Icon(Icons.handshake_outlined),

      );
        }
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/navigation_bloc.dart';
import 'package:paklan/common/bloc/bottom_nav_bar/navigation_event.dart';



class BottomNavBar extends StatelessWidget {
  //final List<BottomNavigationBarItem> items;
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});
  
  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> staticItems = [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(currentIndex == 0 ? AppVectors.homeBold : AppVectors.home),
            label: "Inicio",
            
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(currentIndex == 1 ? AppVectors.historyBold :AppVectors.history),
            label: "Historial"),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(currentIndex ==2 ? AppVectors.settingsBold : AppVectors.settings),
            label: "Cuentas")
        ];
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      type: BottomNavigationBarType.fixed,
      items: staticItems,
      currentIndex: currentIndex,
      onTap: (index){
        context.read<NavigationBloc>().add(NavigateTo(index: index));
      },
      );
  }



}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_cubit.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.symmetric(
         horizontal: 16
       ),
      child: TextField(
        onChanged: (value){
          if (value.length > 2){
          context.read<PersonInfoDisplayCubit>().findPerson(searchVal: value);
          } 
        },
        decoration: InputDecoration(
          fillColor: AppColors.secondBackground,
          contentPadding: const EdgeInsets.all(12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50)
          ),
          prefixIcon: SvgPicture.asset(
            AppVectors.search,
            fit: BoxFit.none,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.srcIn),
          ),
          hintText: 'Buscar por nombre o email'
        ),
      ),
    );
  }
}

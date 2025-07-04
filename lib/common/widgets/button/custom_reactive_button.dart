
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';


class CustomReactiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double ? height;
  final Widget ? content;
  final Color ? color;
  const CustomReactiveButton({
    required this.onPressed,
    this.title = '',
    this.height,
    this.content,
    super.key, this.color
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder < ButtonStateCubit, ButtonState > (
      builder: (context, state) {
        if (state is ButtonLoadingState) {
          return _loading();
        }
        return _initial();
      }
    );
  }

  Widget _loading() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(50, height ?? 50),
      ),
      child: Container(
        height: height ?? 50,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          backgroundColor: AppColors.secondBackground)
      )
    );
  }

  Widget _initial() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
      minimumSize: Size(50, height ?? 50),
      backgroundColor: color ?? Colors.redAccent,
       ),
      child: content ?? Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400
        ),
      )
    );
  }
}

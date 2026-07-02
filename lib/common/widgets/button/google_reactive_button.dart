
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/bloc/button/google_button_state.dart';
import 'package:paklan/common/bloc/button/google_button_state_cubit.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';


class GoogleReactiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double ? height;
  final String ? content;
  const GoogleReactiveButton({
    required this.onPressed,
    this.title = '',
    this.height,
    this.content,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder < GoogleButtonStateCubit, GoogleButtonState > (
      builder: (context, state) {
        if (state is GoogleButtonLoadingState) {
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
        shape: CircleBorder(),
        backgroundColor: Colors.white54
      ),
      child: Container(
        height: height ?? 35,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[300])
      )
    );
  }

  Widget _initial() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: Colors.grey[300]
      ),
      child: SvgPicture.asset(
        content ?? AppVectors.googleIcon,
        width: 24,
        height: 24,
      ),
    );
  }
}

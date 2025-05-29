
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 40,
            right: 16,
            left: 16
          ),
          child: BlocBuilder < UserInfoDisplayCubit, UserInfoDisplayState > (
            builder: (context, state) {
              if (state is UserInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserInfoLoaded) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _profileImage(state.user,context),
                    _gender(state.user),
                    _card(context)
                  ],
                );
              }
              return Container();
            },
          ),
      ),
    );
  }

  Widget _profileImage(UserEntity user,BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: user.image.isEmpty ? 
            const AssetImage(
              AppImages.userLogo
            ) : NetworkImage(
              user.image
            )
          ),
          color: Colors.white,
          shape: BoxShape.circle
        ),
      ),
    );
  }

  Widget _gender(UserEntity user) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 16
      ),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(100)
      ),
      child: Center(
        child: Text(
          '¡Bienvienid${user.gender == 1 ? 'o' : 'a'} ${user.firstName}!',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return GestureDetector(
      onTap: (){
        //AppNavigator.push(context, HomePage());
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle
        ),
        child: SvgPicture.asset(
          AppVectors.bell,
          fit: BoxFit.none,
        ),
      ),
    );
  }
}

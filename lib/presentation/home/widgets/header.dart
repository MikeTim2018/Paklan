
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/presentation/profile/pages/profile_home.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder < UserInfoDisplayCubit, UserInfoDisplayState > (
            builder: (context, state) {
              if (state is UserInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserInfoLoaded) {
                return Container(
                  height: 110,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    //image: DecorationImage(image: const AssetImage(
                    //        AppImages.retroHome,
                    //      )
                    //      ,
                    //      fit: BoxFit.fitWidth,
                          
                    //      )
                    ),
                  child: TweenAnimationBuilder(
                      curve: Curves.easeInCirc,
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 1000),
                      builder: (BuildContext context, double value, Widget ? child){
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: EdgeInsets.all(value*17.5),
                            child: child,
                            )
                          );
                      },
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _profileImage(state.user,context),
                        _name(state.user, context),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          );
  }

  Widget _profileImage(UserEntity user,BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, ProfileHome());
      },
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: user.photoLink.isEmpty ? 
            const AssetImage(
              AppImages.userLogo
            ) : NetworkImage(
              user.photoLink
            )
          ),
          color: Colors.white,
          shape: BoxShape.circle,
          border: BoxBorder.all(
            color: user.notificationNumber > 0 ? 
            Colors.red[400]!
            :AppColors.primaryButton,
            width: 1.5
          )
        ),
        child: user.notificationNumber > 0 ?
        Align(
          alignment: Alignment.topRight,
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              color: Colors.greenAccent[400],
              shape: BoxShape.circle
            ),
            child: Text("${user.notificationNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87
              ),
            ),
          ),
        ) : null
      ),
    );
  }

  Widget _name(UserEntity user, BuildContext context) {
    return Flexible(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 13
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100)
        ),
        child: Center(
          child: 
          Text(
              '¡Bienvienid${user.gender == 1 ? 'o' : 'a'} ${user.displayName}!',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black87
              ),
            ),
          ),
      ),
    );
  }
}

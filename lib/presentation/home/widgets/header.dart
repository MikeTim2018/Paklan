
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
          child: BlocBuilder < UserInfoDisplayCubit, UserInfoDisplayState > (
            builder: (context, state) {
              if (state is UserInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserInfoLoaded) {
                return Container(
                  height: 125,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(image: const AssetImage(
                            AppImages.noTrades,
                          )
                          ,
                          fit: BoxFit.fitWidth,
                          
                          )),
                  child: TweenAnimationBuilder(
                      curve: Curves.easeIn,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _profileImage(state.user,context),
                        _name(state.user, context),
                        _card(context)
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
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

  Widget _name(UserEntity user, BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 16
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100)
      ),
      child: Center(
        child: 
        Text(
            '¡Bienvienid${user.gender == 1 ? 'o' : 'a'} ${user.firstName}!',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: Colors.black
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
          color: Colors.white,
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

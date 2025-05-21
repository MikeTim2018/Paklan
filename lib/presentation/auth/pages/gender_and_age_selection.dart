import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/bottomsheet/app_bottomsheet.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/domain/auth/usecases/signup.dart';
import 'package:paklan/presentation/auth/bloc/age_selection_cubit.dart';
import 'package:paklan/presentation/auth/bloc/ages_display_cubit.dart';
import 'package:paklan/presentation/auth/bloc/gender_selection_cubit.dart';
import 'package:paklan/presentation/auth/widgets/ages.dart';
import 'package:paklan/presentation/home/pages/home.dart';
import '../../../common/widgets/appbar/app_bar.dart';
import '../../../common/widgets/button/basic_reactive_button.dart';

class GenderAndAgeSelectionPage extends StatelessWidget {
  final UserCreationReq userCreationReq;
  final String _countryCodeText = '+52';
  GenderAndAgeSelectionPage({
    required this.userCreationReq,
    super.key
  });
  final TextEditingController _phoneCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => GenderSelectionCubit()),
            BlocProvider(create: (context) => AgeSelectionCubit()),
            BlocProvider(create: (context) => AgesDisplayCubit()),
            BlocProvider(create: (context) => ButtonStateCubit())
          ],
          child: BlocListener<ButtonStateCubit,ButtonState>(
            listener: (context, state) {
              if (state is ButtonFailureState){
                var snackbar = SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: TextStyle(
                      color: Colors.white70
                    ),),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  showCloseIcon: true,
                  closeIconColor: Colors.white70,
                  );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              }else if (state is ButtonSuccessState){
                AppNavigator.pushAndRemove(context, HomePage());
              }
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 40
                    ),
              children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tellUs(),
                        const SizedBox(height: 30, ),
                          _genders(context),
                          const SizedBox(height: 30, ),
                            howOld(),
                            const SizedBox(height: 30, ),
                              _age(),
                              const SizedBox(height: 30, ),
                              phoneNum(),
                              const SizedBox(height: 20, ),
                              _phone(context),
                      ],
                    ),
                  _finishButton(context)
              ],
            ),
          ),
        ),
    );
  }

  Widget _tellUs() {
    return const Text(
      'Acerca de Ti',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500
      ),
    );
  }

  Widget _genders(BuildContext context) {
    return BlocBuilder<GenderSelectionCubit,int>(
      builder: (context,state) {
        return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          genderTile(context,1,'Hombre'),
          const SizedBox(width: 20,),
          genderTile(context,2,'Mujer'),
        ],
      );
      }

    );
  }

  Expanded genderTile(BuildContext context,int genderIndex,String gender) {
    return Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: (){
            context.read<GenderSelectionCubit>().selectGender(genderIndex);
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: context.read<GenderSelectionCubit>().selectedIndex == genderIndex ?
               AppColors.primary : AppColors.secondBackground,
              borderRadius: BorderRadius.circular(30)
            ),
            child: Center(
              child: Text(
                gender,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget howOld() {
    return const Text(
      '¿Qué Edad Tienes?',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500
      ),
    );
  }

  Widget _age() {
    return BlocBuilder<AgeSelectionCubit,String>(
      builder: (context,state) {
      return GestureDetector(
        onTap: (){
          AppBottomsheet.display(
            context,
            MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AgeSelectionCubit>(),),
              BlocProvider.value(value: context.read<AgesDisplayCubit>()..displayAges())
            ],
            child: const Ages()
            )
          );
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondBackground,
            borderRadius: BorderRadius.circular(30)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state
              ),
              const Icon(
                Icons.keyboard_arrow_down
              )
            ],
          ),
        ),
      );
      }
    );
  }
  Widget phoneNum() {
    return const Text(
      'Ingresa de número de télefono a 10 dígitos',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500
      ),
    );
  }
  Widget _phone(BuildContext context){
    return IntlPhoneField(
      controller: _phoneCon,
      onCountryChanged: (value) => _countryCodeText,
      initialCountryCode: 'MX',
      showCursor: true,
      invalidNumberMessage: 'Número de teléfono inválido',
    );
  }

  Widget _finishButton(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Builder(
          builder: (context) {
            return BasicReactiveButton(
              onPressed: (){
                userCreationReq.gender = context.read<GenderSelectionCubit>().selectedIndex;
                userCreationReq.age = context.read<AgeSelectionCubit>().selectedAge;
                userCreationReq.phone = "$_countryCodeText${_phoneCon.text}";
                context.read<ButtonStateCubit>().execute(
                  usecase: SignupUseCase(),
                  params: userCreationReq
                );
              },
              title: 'Terminar'
            );
          }
        ),
      ),
    );
  }
}

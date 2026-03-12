import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/auth/usecases/signout.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_state.dart';
import 'package:paklan/presentation/transactions/widgets/person_card.dart';



class ProfileHome extends StatelessWidget {
  const ProfileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    MultiBlocProvider(
      providers: [
        BlocProvider(create:(context) => PersonInfoDisplayCubit()),
        BlocProvider(create: (context) => ButtonStateCubit()),
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
                AppNavigator.pushAndRemove(context, SigninPage());
              }
            },
      child:
      Scaffold(
        appBar: BasicAppbar(
          height: 80,
          title: Text("Información del perfil")
          
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<PersonInfoDisplayCubit, PersonInfoDisplayState>(
            builder: (context, state){
              if (state is PersonInfoLoading){
                return const Center(child: CircularProgressIndicator(),);
              }
              if (state is PersonInfoLoaded){
                return PersonCard(userEntity: state.users);
              }
              if (state is PersonInitialState){
                return Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Column(
                          children: [
                            SizedBox(
                              height: 200,
                              width: 350,
                              child: Card(
                                          shadowColor: Colors.amber,
                                          elevation: 11,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0)
                                            ),
                                            tileColor: AppColors.secondBackground,
                                            trailing: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                ),
                                                height: 120,
                                                width: 50,
                                                child: SvgPicture.asset(
                                                    AppVectors.cash,
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                              ),
                                            title: Container(
                                              height: 85,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: 
                                                AssetImage(AppImages.appLogo)
                                                )
                                                ),
                                             
                                            ),
                                              subtitle: Text(
                                                "Miguel Angel Sanchez Ramirez\nmiguelsanchezr@gmail.com",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13
                                                ),
                                                
                                              ),
                                              leading: 
                                                        SizedBox(
                              width: 50,
                              child: Text(
                                '\$${(double.parse("1.2") + double.parse("0.2"))
                                .truncateToDouble().
                                toStringAsFixed(2).
                                replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} '
                                ,style: TextStyle(fontSize: 16, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                ),
                                                        ),
                                
                                          ),
                                        ),
                            ),
                            SizedBox(height: 50,),
                            SizedBox(
                              height: 200,
                              width: 350,
                              child: Card(
                                          shadowColor: Colors.amber,
                                          elevation: 11,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0)
                                            ),
                                            tileColor: AppColors.secondBackground,
                                            trailing: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                ),
                                                height: 120,
                                                width: 50,
                                                child: SvgPicture.asset(
                                                    AppVectors.cash,
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                              ),
                                            title: Container(
                                              height: 85,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: 
                                                AssetImage(AppImages.appLogo)
                                                )
                                                ),
                                             
                                            ),
                                              subtitle: Text(
                                                "Miguel Angel Sanchez Ramirez\nmiguelsanchezr@gmail.com",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13
                                                ),
                                                
                                              ),
                                              leading: 
                                                        SizedBox(
                              width: 50,
                              child: Text(
                                '\$${(double.parse("1.2") + double.parse("0.2"))
                                .truncateToDouble().
                                toStringAsFixed(2).
                                replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} '
                                ,style: TextStyle(fontSize: 16, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                ),
                                                        ),
                                
                                          ),
                                        ),
                            ),
                            SizedBox(height: 50,),
                            Builder(
                              builder: (context) {
                                return CustomReactiveButton(
                                  onPressed: (){
                                    context.read<ButtonStateCubit>().execute(
                                    usecase: SignoutUseCase()
                                  );
                                  },
                                  color: Colors.red[600], 
                                  title: "Logout",
                                  );
                              }
                            )
                          ],
                        ),
                    ],
                  )
                );
              }
              if (state is PersonInfoEmpty){
                return Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           SvgPicture.asset(
                             AppVectors.notFound,
                           ),
                           const Padding(
                             padding: EdgeInsets.all(16),
                             child: Text(
                               "Lo siento no pudimos encontrar a ninguna persona. Intenta invitándolo a registrarse",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 fontSize: 20
                               ),
                             ),
                           )
                         ],
                        );
          
              }
              return Container();
            },
              
              ),
        ),
        )
        )
    );
    }
}


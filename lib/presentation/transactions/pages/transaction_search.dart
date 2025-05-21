import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_state.dart';
import 'package:paklan/presentation/transactions/widgets/person_card.dart';
import 'package:paklan/presentation/transactions/widgets/search_field.dart';



class TransactionSearch extends StatelessWidget {
  const TransactionSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PersonInfoDisplayCubit(),
      child: Scaffold(
        appBar: BasicAppbar(
          title: 
              SearchField(),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Column(
            children: [
              Text(
                "Paso 1 de 2", 
                textAlign: TextAlign.center,),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 150,
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                    
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blueGrey, 
                      ),
                    ),
                    
                  ],
                )
            ],
          ),
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
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Text(
                          "Busca a Tu Comprador o Vendedor para hacer un trato",
                          style: TextStyle(
                            fontSize: 23
                          ),
                          ),
                      ),
                        SizedBox(height: 20,),
                Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: const AssetImage(
                        AppImages.findPerson
                      ),
                      )
                  ),
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
        );
    }
}


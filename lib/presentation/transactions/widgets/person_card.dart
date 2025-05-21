import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/transactions/entity/user.dart';
import 'package:paklan/presentation/transactions/pages/transaction_amount.dart';


class PersonCard extends StatelessWidget {
  final List<UserEntityTransaction> userEntity;
  const PersonCard({super.key, required this.userEntity});

  @override
  Widget build(BuildContext context) {
    return Column(
                 children: [
                  SizedBox(height: 50,),
                  Text(
                    "Personas Encontradas",
                    style: TextStyle(
                      fontSize: 20
                    ),
                    ),
                  SizedBox(height: 20,),
                  SizedBox(
                    height: 420,
                    child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: (){
                    AppNavigator.push(context, TransactionAmount(userEntity: userEntity[index],));
                                },
                                child: Container(
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondBackground,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      children: [
                             Column(
                           children: [
                            Text(
                              textAlign: TextAlign.center,
                              "Nombre",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54
                              ),
                              ),
                              SizedBox(height: 2,),
                             SizedBox(
                              width: 125,
                               child: Text(
                                textAlign: TextAlign.center,
                                userEntity[index].firstName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),
                                                   ),
                             ),
                           ],
                         ),
                        const VerticalDivider(),
                         Column(
                           children: [
                            Text(
                              textAlign: TextAlign.center,
                              "Teléfono",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54
                              ),
                              ),
                              SizedBox(height: 2,),
                             SizedBox(
                              width: 125,
                               child: Text(
                                textAlign: TextAlign.center,
                                userEntity[index].phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),
                                                   ),
                             ),
                           ],
                         ),
                        const SizedBox(width: 5),
                        const VerticalDivider(),
                        const SizedBox(width: 15),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                                AppVectors.rightArrow,
                                fit: BoxFit.none,
                                ),
                        ),
                        
                      ],
                      
                    ),
                                ),
                              );
                            },
                             separatorBuilder: (context, index) => const SizedBox(height: 10,),
                             itemCount: userEntity.length
                          ),
                  ),
                  ]
                  );


  }
}
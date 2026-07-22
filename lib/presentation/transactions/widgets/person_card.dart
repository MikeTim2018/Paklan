import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
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
                  SizedBox(height: 30,),
                  Text(
                    "Personas Encontradas",
                    style: TextStyle(
                      fontSize: 20
                    ),
                    ),
                  SizedBox(height: 20,),
                  SizedBox(
                    height: 350,
                    child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: (){
                    AppNavigator.push(context, TransactionAmount(userEntity: userEntity[index],));
                                },
                                child: _buildPersonTile(userEntity[index]),
                                
                              );
                            },
                             separatorBuilder: (context, index) => const SizedBox(height: 10,),
                             itemCount: userEntity.length
                          ),
                  ),
                  ]
                  );


  }
  Widget _buildPersonTile(user){
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0.0,
      child: ListTile(
        shape: StadiumBorder(side: BorderSide(width: 1)),
        tileColor: AppColors.secondBackground,
        leading: CircleAvatar(
          backgroundColor: AppColors.secondBackground,
          radius: 30,
          backgroundImage: user.photoLink.isEmpty ? 
            const AssetImage(
              AppImages.userLogo
            ) : NetworkImage(
              user.photoLink
            ),
        ),
        title: Text(
          user.displayName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold
          ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              color: Colors.black54
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryButton,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppVectors.rightArrow,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              fit: BoxFit.none,
            ),
          ),
      ),
    );
  }
}
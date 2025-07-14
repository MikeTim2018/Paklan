import 'package:flutter/material.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:u_credit_card/u_credit_card.dart';

class CreditCardUiCustom extends StatelessWidget {
  final Map<String, dynamic> userData;
  final int index;
  const CreditCardUiCustom({super.key, required this.userData, required this.index});

  @override
  Widget build(BuildContext context) {
    if (userData['CLABEs'][index].substring(0,3) == '002'){
      return CreditCardUi(      
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.blueAccent,
               cardProviderLogo: 
                  Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                 image: const AssetImage(
                                   AppImages.banamex
                                 ),
                                 )
                                 ),
                                 ),
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );
    }
    if (userData['CLABEs'][index].substring(0,3) == '012'){
      return CreditCardUi(
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.blue,
               cardProviderLogo: 
                  Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                 image: const AssetImage(
                                   AppImages.bbva
                                 ),
                                 )
                                 ),
                                 ),
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );
    }
    if (userData['CLABEs'][index].substring(0,3) == '072'){
      return CreditCardUi(
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.red,
               cardProviderLogo: 
                  Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                 image: const AssetImage(
                                   AppImages.banorte
                                 ),
                                 )
                                 ),
                                 ),
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );

    }
    if(userData['CLABEs'][index].substring(0,3) == '021'){
      return CreditCardUi(
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.redAccent,
               cardProviderLogo: 
                  Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                 image: const AssetImage(
                                   AppImages.hsbc
                                 ),
                                 )
                                 ),
                                 ),
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );

    }
    if(userData['CLABEs'][index].substring(0,3) == '014'){
      return CreditCardUi(
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.red,
               cardProviderLogo: 
                  Container(
                          width: 65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                 image: const AssetImage(
                                   AppImages.santander,
                                 ),
                                 )
                                 ),
                                 ),
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );

    }
    return CreditCardUi(
               shouldMaskCardNumber: true,
               cardHolderFullName: userData['firstName'],
               cardNumber: "${userData['CLABEs'][index].substring(0,4)}${userData['CLABEs'][index].substring(6,18)}",
               validFrom: 'xx/xx',
               showValidFrom: false,
               showValidThru: false,
               validThru: 'xx/xx',
               bottomRightColor: AppColors.primary,
               topLeftColor: Colors.grey,
               cardType: CardType.debit,
               creditCardType: CreditCardType.none,
               );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/bloc/transactions/transactions_display_cubit.dart';
import 'package:paklan/common/bloc/transactions/transactions_display_state.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/transactions/pages/transaction_search.dart';

class TransactionDisplay extends StatelessWidget {
  const TransactionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsDisplayCubit, TransactionsDisplayState>(
                 builder: (context, state){
          if (state is TransactionsLoading){
            return SizedBox(
              height: 450,
              child: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator()
                ),
            );
          }
          if (state is TransactionsLoaded){
            return Column(
              children: [
                SizedBox(height: 50,),
                Text(
                  "Tratos en Curso",
                  style: TextStyle(
                    fontSize: 20
                  ),
                  ),
                SizedBox(height: 20,),
                listTransactions(context, state),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BasicAppButton(
                    onPressed: (){
                      AppNavigator.push(context, TransactionSearch());
                      },
                      width: 200,
                      title: 'Iniciar Trato'
                  ),
                ),

              ],
            );
          }
          if (state is TransactionsLoadFailed){
            return SizedBox(
              height: 450,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  state.errorMessage,
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
              ),
            );
          }
          if (state is TransactionsEmpty){
            return listNoTransaction(context);
          }
          return const SizedBox();
        }
        );
  }
}

Column listNoTransaction(BuildContext context) {
    return Column(
      children: [
              SizedBox(height: 100,),
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: const AssetImage(
                      AppImages.noTrades
                    ),
                    )
                ),
              ),
              SizedBox(height: 50,),
              Text(
                "Sin Tratos Activos",
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.white70
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "¡Comienza ahora!",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary
                ),
              ),
              SizedBox(height: 30,),
              Align(
                alignment: Alignment.bottomCenter,
                child: BasicAppButton(
                  onPressed: (){
                    AppNavigator.push(context, TransactionSearch());
                    },
                    width: 200,
                    title: 'Iniciar Trato'
                ),
              ),
              ]
              );
  }


  Widget listTransactions(BuildContext context, state) {
    return SizedBox(
      height: 450,
      child: RawScrollbar(
        thumbColor: AppColors.secondBackground,
        shape: const StadiumBorder(),
        thickness: 7,
        child: ListView.separated(
          padding: EdgeInsets.all(13),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: (){
                      //AppNavigator.push(context, CategoryProductsPage(categoryEntity: state.categories[index],));
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
                                "Vendedor",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54
                                ),
                                ),
                                SizedBox(height: 2,),
                               Flexible(
                                 child: SizedBox(
                                  width: 75,
                                   child: Text(
                                    textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible,
                                      state.transaction[index].sellerFirstName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400
                                      ),
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
                                "Comprador",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54
                                ),
                                ),
                                SizedBox(height: 2,),
                               Flexible(
                                 child: SizedBox(
                                  width: 75,
                                     child: Text(
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible,
                                      state.transaction[index].buyerFirstName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400
                                      ),
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
                                "Monto",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54
                                ),
                                ),
                                SizedBox(height: 2,),
                               SizedBox(
                                width: 75,
                                 child: Text(
                                  textAlign: TextAlign.center,
                                  "\$${state.transaction[index].amount}",
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
                          const SizedBox(width: 3),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                                  AppVectors.info,
                                  fit: BoxFit.none,
                                  ),
                          ),
                          
                        ],
                        
                      ),
                                  ),
                                );
                              },
                               separatorBuilder: (context, index) => const SizedBox(height: 10,),
                               itemCount: state.transaction.length
                            ),
      ),
    );
  }
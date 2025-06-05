import 'package:flutter/cupertino.dart';
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
import 'package:paklan/presentation/transactions/pages/transaction_detail.dart';
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
            return RefreshIndicator(
              onRefresh: () => context.read<TransactionsDisplayCubit>().displayTransactions(),
              child: Column(
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
                  const SizedBox(height: 25),
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
              ),
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

Widget listNoTransaction(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<TransactionsDisplayCubit>().displayTransactions(),
      child: SingleChildScrollView(
        child: Column(
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
                  ),
      ),
    );
  }


  Widget listTransactions(BuildContext context, state) {
    return SizedBox(
      height: 450,
      child: RawScrollbar(
        thumbColor: AppColors.secondBackground,
        shape: const StadiumBorder(),
        timeToFade: Duration(seconds: 1),
        thickness: 8,
        child: ListView.separated(
          padding: EdgeInsets.all(9),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     builder: (BuildContext context) => TransactionDetail(transaction: state.transaction[index]),
                                    ),
                                    );
                                  },
                                  child: transactionTile(state, index),
                                );
                              },
                               separatorBuilder: (context, index) => const SizedBox(height: 10,),
                               itemCount: state.transaction.length
                            ),
      ),
    );
  }

  Widget transactionTile(state, int index) {
    return Card(
      child: ListTile(
        shape: StadiumBorder(side: BorderSide(width: 2,color: Colors.white24)),
        tileColor: AppColors.secondBackground,
        leading: CircleAvatar(
          backgroundColor: AppColors.secondBackground,
          radius: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            height: 40,
            width: 40,
            child: SvgPicture.asset(
                AppVectors.cash,
                fit: BoxFit.fill,
              ),
          ),
        ),
        title: Text(
          'Monto: \$${state.transaction[index].amount}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
          ),
          subtitle: Text(
            'Vendedor: ${state.transaction[index].sellerFirstName}\nComprador: ${state.transaction[index].buyerFirstName}',
            style: TextStyle(
              color: Colors.grey
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppVectors.info,
              fit: BoxFit.none,
            ),
          ),
      ),
    );
  }
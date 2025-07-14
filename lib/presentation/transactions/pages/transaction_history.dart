import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_completed_transactions.dart';
import 'package:paklan/presentation/transactions/pages/transaction_detail.dart';
import 'package:paklan/service_locator.dart';
import 'package:paklan/presentation/transactions/bloc/status_filter_history_selection_cubit.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;


class TransactionHistory extends StatelessWidget {
  final Stream<QuerySnapshot> _transactionsStream =  sl<GetCompletedTransactionsUseCase>().call();
  final ScrollController _scrollController = ScrollController();
  TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => StatusFilterHistorySelectionCubit())
          ],
          child: StreamBuilder<QuerySnapshot>(
          stream: _transactionsStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> state){
          if (state.connectionState == ConnectionState.waiting){
            return SizedBox(
              height: 400,
              child: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator()
                ),
            );
          }
          if (state.hasError){
            return SizedBox(
              height: 400,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Ha ocurrido un error, por favor intenta más tarde",
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
              ),
            );
          }
          if (state.data == null || state.data!.docs.isEmpty){
            return Scaffold(
              body: listNoDeal(context)
            );
          }
          List<TransactionEntity> listEntities = state.data!.docs.map(
                          (element) => TransactionModel.fromMap(element.data() as Map<String, dynamic>).toEntity()
                          ).toList();
          return Scaffold(
            body: Column(
                  children: [
                    SizedBox(height: 100,),
                    Text(
                      "Tratos Completados y Cancelados",
                      style: TextStyle(
                        fontSize: 20
                      ),
                      ),
                    Container(
                          padding: EdgeInsets.all(13),
                          height: 60,
                          child: MultiSelectContainer(
                              itemsDecoration: MultiSelectDecorations(
                               decoration: BoxDecoration(
                                   gradient: LinearGradient(colors: [
                                     Colors.blue.withValues(alpha: 0.1),
                                     Colors.yellow.withValues(alpha: 0.1),
                                     
                                   ]),
                                   border: Border.all(color: Colors.green[200]!),
                                   borderRadius: BorderRadius.circular(20)),
                              
                               selectedDecoration: BoxDecoration(
                                   gradient: const LinearGradient(colors: [
                                    Colors.lightBlueAccent,
                                    Colors.blueAccent,
                                    Color.fromARGB(255, 6, 111, 197)
                                     
                                   ]),
                                   border: Border.all(color: Colors.green[700]!),
                                   borderRadius: BorderRadius.circular(13)),
                               disabledDecoration: BoxDecoration(
                                   color: Colors.grey,
                                   border: Border.all(color: Colors.grey[500]!),
                                   borderRadius: BorderRadius.circular(10)),
                             ),
                            prefix: MultiSelectPrefix(
                              selectedPrefix: const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              enabledPrefix: const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.disabled_visible,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              ),
                              showInListView: true,
                              listViewSettings: ListViewSettings(
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (_, _) => const SizedBox(
                                        width: 10,
                                      )),
                              
                              items: [
                                MultiSelectCard(
                                  value: 'Completado', 
                                  label: 'Completado', 
                                  selected: true,
                                  textStyles: MultiSelectItemTextStyles(
                                    selectedTextStyle: TextStyle(color: Colors.white)
                                    )
                                  ),
                                MultiSelectCard(
                                  value: 'Cancelado', 
                                  label: 'Cancelado', 
                                  selected: true,
                                  textStyles: MultiSelectItemTextStyles(
                                    selectedTextStyle: TextStyle(color: Colors.white)
                                    )
                                    ),
                                
                              ],
                              onChange: (allSelectedItems, selectedItem) {
                                context.read<StatusFilterHistorySelectionCubit>().selectFilters(allSelectedItems);
                              }
                              ),
                        ),
                    SizedBox(height: 10,),
                    BlocBuilder<StatusFilterHistorySelectionCubit, List<String>>(
                          builder: (context, state) {
                            return listTransactions(context, listEntities.where((element) {
                                  return context.read<StatusFilterHistorySelectionCubit>().selectedFilters.contains(element.status);
                                }).toList(),
                              _scrollController
                              );
                          }
                        ),
                  ],
              ),
          );
          }
        ),
        );
  }
}

Widget listNoDeal(BuildContext context) {
    return SingleChildScrollView(
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
                          AppImages.dealSuccess
                        ),
                        )
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "Sin Tratos Completados o Cancelados",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white70
                    ),
                  ),
                  ]
                  ),
    );
  }


  Widget listTransactions(BuildContext context, List<TransactionEntity> state, ScrollController scrollController) {
    return SizedBox(
      height: 400,
      child: RawScrollbar(
        controller: scrollController,
        thumbVisibility: true,
        thumbColor: Colors.white24,
        shape: const StadiumBorder(),
        timeToFade: Duration(seconds: 1),
        thickness: 8,
        child: ListView.separated(
          controller: scrollController,
          padding: EdgeInsets.all(9),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(
                                    CupertinoSheetRoute<void>(
                                     builder: (BuildContext context) => TransactionDetail(
                                      transaction: state[index]
                                      ),
                                    ),
                                    );
                                  },
                                  child: transactionTile(state, index),
                                );
                              },
                               separatorBuilder: (context, index) => const SizedBox(height: 10,),
                               itemCount: state.length
                            ),
      ),
    );
  }

  Widget transactionTile(List<TransactionEntity> state, int index) {
    return Card(
      shadowColor: Colors.amber,
      elevation: 11,
      shape: StadiumBorder(),
      child: ListTile(
        shape: StadiumBorder(
          side: BorderSide(
            width: 2,
            color: state[index].status=='Cancelado' ? Colors.red : Colors.blue
            )
            ),
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
              '${toBeginningOfSentenceCase(state[index].name)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              ),
              subtitle: Text(
                'Monto: \$${state[index].amount}\nVendedor: ${state[index].sellerFirstName}\nComprador: ${state[index].buyerFirstName}',
                style: TextStyle(
                  color: Colors.grey
                ),
                overflow: TextOverflow.ellipsis,
              ),
          trailing: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              state[index].status=='Completado'? AppVectors.check : AppVectors.error,
              fit: BoxFit.fill,
            ),
          ),
      ),
    );
  }
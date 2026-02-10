import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final MultiSelectController<String> _multicontroller2 = MultiSelectController<String>();
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
                              controller: _multicontroller2,
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
                                    Colors.white70,
                                    Colors.white60,
                                    Colors.white54,
                                     
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
                                        value: 'Todos', 
                                        label: 'Todos', 
                                        selected: true,
                                        textStyles: MultiSelectItemTextStyles(
                                          selectedTextStyle: TextStyle(color: Colors.black87)
                                          )
                                        ),
                                MultiSelectCard(
                                  value: 'Completado', 
                                  label: 'Completado', 
                                  selected: false,
                                  textStyles: MultiSelectItemTextStyles(
                                    selectedTextStyle: TextStyle(color: Colors.black87)
                                    )
                                  ),
                                MultiSelectCard(
                                  value: 'Cancelado', 
                                  label: 'Cancelado', 
                                  selected: false,
                                  textStyles: MultiSelectItemTextStyles(
                                    selectedTextStyle: TextStyle(color: Colors.black87)
                                    )
                                    ),
                                
                              ],
                              onChange: (allSelectedItems, selectedItem) {
                                _multicontroller2.select(selectedItem);
                                allSelectedItems = [selectedItem];
                                context.read<StatusFilterHistorySelectionCubit>().selectFilters(allSelectedItems.toSet().toList());
                              }
                              ),
                        ),
                    SizedBox(height: 10,),
                    BlocBuilder<StatusFilterHistorySelectionCubit, List<String>>(
                          builder: (context, state) {
                            if (context.read<StatusFilterHistorySelectionCubit>().selectedFilters.contains("Todos")){
                              return listTransactions(context, listEntities,_scrollController
                              );
                            }
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
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
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
        trailing: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                  ),
                  height: 105,
                  width: 80,
                  child: SvgPicture.asset(
                      AppVectors.cash,
                      fit: BoxFit.fitHeight,
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
                  currentUserId == state[index].sellerId ? '${state[index].buyerFirstName}':'${state[index].sellerFirstName}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              leading:  SizedBox(
                width: 95,
                child: Text(
                                '\$${(double.parse(state[index].amount!) + double.parse(state[index].fee!))
                                .truncateToDouble().
                                toStringAsFixed(2).
                                replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} '
                                ,style: TextStyle(fontSize: 16, color: Colors.white, decoration: state[index].status=='Completado' ? TextDecoration.none: TextDecoration.lineThrough),
                                overflow: TextOverflow.ellipsis,
                                ),
              )
      ),
    );
  }
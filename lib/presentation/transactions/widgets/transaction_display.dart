import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/entity/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_transactions.dart';
import 'package:paklan/presentation/transactions/bloc/status_filter_selection_cubit.dart';
import 'package:paklan/presentation/transactions/pages/transaction_detail.dart';
import 'package:paklan/service_locator.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;


class TransactionDisplay extends StatelessWidget{
  TransactionDisplay({super.key});
  final Stream<QuerySnapshot> _transactionsStream =  sl<GetTransactionsUseCase>().call();
  final ScrollController _scrollController = ScrollController();
  final MultiSelectController<String> _multicontroller = MultiSelectController<String>();

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => StatusFilterSelectionCubit()),
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
                        "Ha ocurrido un error, por favor intenta más tarde.",
                        style: TextStyle(
                          fontSize: 24
                        ),
                      ),
                    ),
                  );
                }
                if (state.data == null || state.data!.docs.isEmpty){
                  return listNoTransaction(context);
                }
                List<TransactionEntity> listEntities = state.data!.docs.map(
                          (element) => TransactionModel.fromMap(element.data() as Map<String, dynamic>).toEntity()
                          ).toList();
                return Column(
                      children: [
                        SizedBox(height: 20,),
                        Text(
                          "Tratos en curso",
                          style: TextStyle(
                            fontSize: 20
                          ),
                          ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.all(13),
                            height: 60,
                            child: Row(
                              children: [
                                SizedBox(width: 10,),
                                MultiSelectContainer(
                                  maxSelectableCount: 1,
                                  controller: _multicontroller,
                                  wrapSettings: WrapSettings(direction: Axis.horizontal),
                                    itemsDecoration: MultiSelectDecorations(
                                     decoration: BoxDecoration(
                                         gradient: LinearGradient(colors: [
                                           Colors.blue.withValues(alpha: 0.1),
                                           Colors.yellow.withValues(alpha: 0.1),
                                           
                                         ]),
                                         border: Border.all(color: Colors.green[200]!),
                                         borderRadius: BorderRadius.circular(20)),
                                    
                                     selectedDecoration: BoxDecoration(
                                         gradient: LinearGradient(colors: [
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
                                        color: Colors.black87,
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
                                        value: 'Depositado', 
                                        label: 'Depositado', 
                                        selected: false,
                                        textStyles: MultiSelectItemTextStyles(
                                          selectedTextStyle: TextStyle(color: Colors.black87)
                                          )
                                        ),
                                      MultiSelectCard(
                                        value: 'Aceptado', 
                                        label: 'Aceptado', 
                                        selected: false,
                                        textStyles: MultiSelectItemTextStyles(
                                          selectedTextStyle: TextStyle(color: Colors.black87)
                                          )
                                          ),
                                      MultiSelectCard(
                                        value: 'Enviado', 
                                        label: 'Enviado', 
                                        selected: false,
                                        textStyles: MultiSelectItemTextStyles(
                                          selectedTextStyle: TextStyle(color: Colors.black87)
                                          )
                                          ),
                                      
                                    ],
                                    onChange: (allSelectedItems, selectedItem) {
                                      _multicontroller.select(selectedItem);
                                      allSelectedItems = [selectedItem];
                                      context.read<StatusFilterSelectionCubit>().selectFilters(allSelectedItems.toSet().toList());
                                    }
                                    ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        BlocBuilder<StatusFilterSelectionCubit, List<String>>(
                          builder: (context, state) {
                            if (context.read<StatusFilterSelectionCubit>().selectedFilters.contains("Todos")){
                              return listTransactions(context, listEntities,_scrollController, currentUserId);
                            }
                            return listTransactions(context, listEntities.where((element) {
                                  return context.read<StatusFilterSelectionCubit>().selectedFilters.contains(element.status);
                                }).toList(),
                              _scrollController, currentUserId
                              );
                          }
                        )
                      ],
                  );
                }
              ),  
    );
  }

Widget listNoTransaction(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
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
                    "Sin Tratos Activos",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "¡Comienza ahora!",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary
                    ),
                  ),
                  ]
                  ),
    );
  }

  Widget transactionTile(List<TransactionEntity> status, int index, String user) {
    return Column(
          children: [
            // Align(
            //  alignment: AlignmentGeometry.directional(0.7, 10),
            //  child: Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(colors: [
            //                       Colors.greenAccent.withValues(alpha: 0.7),
            //                       Colors.green.withValues(alpha: 0.9),
            //                       const Color.fromARGB(255, 25, 112, 28).withValues(alpha: 0.2),
            //                     ]),
            //     // gradient: switch (status[index].timeLimit!.difference(DateTime.parse(serverTime)).inHours) {
            //     //                <= 12 && >= 6 => LinearGradient(colors: [
            //     //                  Colors.yellowAccent.withValues(alpha: 0.7),
            //     //                  Colors.yellow.withValues(alpha: 0.9),
            //     //                  const Color.fromARGB(255, 161, 147, 20).withValues(alpha: 0.2),
            //     //                ]),
            //     //                <= 5 && >= 0 => LinearGradient(colors: [
            //     //                  Colors.redAccent.withValues(alpha: 0.7),
            //     //                  Colors.red.withValues(alpha: 0.9),
            //     //                  const Color.fromARGB(255, 126, 20, 12).withValues(alpha: 0.2),
            //     //                ]),
            //     //                _ => LinearGradient(colors: [
            //     //                  Colors.greenAccent.withValues(alpha: 0.7),
            //     //                  Colors.green.withValues(alpha: 0.9),
            //     //                  const Color.fromARGB(255, 25, 112, 28).withValues(alpha: 0.2),
            //     //                ]),
            //     //                },
            //     borderRadius: BorderRadius.circular(15)
            //     ),
            //     child: Text("test"),
            // )
            // ),
          Card(
            shadowColor: Colors.amber,
            elevation: 11,
            shape: StadiumBorder(),
            child: ListTile(
              shape: StadiumBorder(side: BorderSide(
                width: 2,
                color: const Color.fromARGB(216, 71, 145, 50)
                // color: switch (status[index].timeLimit!.difference(DateTime.parse(serverTime)).inHours) {
                //                <= 12 && >= 6 => const Color.fromARGB(255, 225, 179, 14),
                //                <= 5 && >= 0 => const Color.fromARGB(255, 225, 70, 14),
                //                _ => const Color.fromARGB(216, 71, 145, 50),
                //                },
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
                '${toBeginningOfSentenceCase(status[index].name)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
                ),
                ),
                subtitle: Text(
                  user == status[index].sellerId ? '${status[index].buyerFirstName}':'${status[index].sellerFirstName}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                leading: 
                          SizedBox(
                            width: 95,
                            child: Text(
                              '\$${(double.parse(status[index].amount!) + double.parse(status[index].fee!))
                              .truncateToDouble().
                              toStringAsFixed(2).
                              replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} '
                              ,style: TextStyle(fontSize: 16, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              ),
                          ),
  
            ),
          ),
        ],
      );

  }

    Widget listTransactions(BuildContext context, List<TransactionEntity> status, ScrollController scrollController, String user) {
    return SizedBox(
          height: 400,
          child: RawScrollbar(
          thumbVisibility: true,
          controller: scrollController,
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
                                              transaction: status[index]
                                              ),
                                            ),
                                            );
                                          },
                                          child: transactionTile(status, index, user),
                                        );
                                      },
                                       separatorBuilder: (context, index) => const SizedBox(height: 10,),
                                       itemCount: status.length
                                    ),
              ),
            );
  }
}





  
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
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
                                           Colors.white30,
                                           AppColors.primary,
                                         ]),
                                         border: Border.all(color: Colors.black26),
                                         borderRadius: BorderRadius.circular(20)),
                                    
                                     selectedDecoration: BoxDecoration(
                                         gradient: LinearGradient(colors: [
                                           const Color.fromARGB(255, 32, 68, 117).withValues(alpha: 0.6),
                                           Colors.white38.withValues(alpha: 0.1),
                                         ]),
                                         border: Border.all(color: Colors.black38),
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
                                        color: Colors.black38,
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
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 120,
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
                    "Aún no tienes tratos",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black87
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "¡Comienza ahora!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black
                    ),
                  ),
                  ]
                  ),
    );
  }

  Widget transactionTile(List<TransactionEntity> status, int index, String user, context) {
    return SizedBox(
             width: MediaQuery.sizeOf(context).width * 0.6,
             child: Card(
               shadowColor: Colors.amber,
               elevation: 9,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(20),
               ),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(20),
                 child: Container(
                   decoration: BoxDecoration(
                     color: AppColors.secondBackground,
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       width: 1.2,
                       color: const Color.fromARGB(215, 0, 0, 0),
                     ),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       // 1. Interactive Image Gallery (Top Area)
            SizedBox(
              height: 120, 
              width: double.infinity,
              child: Stack(
                children: [
                  // Base Layer: Photos (either fallback or full multi-page stream)
                  Positioned.fill(
                    child: status[index].images!.isEmpty
                        ? const Image(
                            image: AssetImage(AppImages.userLogo),
                            fit: BoxFit.cover,
                          )
                        : PageView.builder(
                            itemCount: status[index].images!.length,
                            controller: PageController(viewportFraction: 1.0),
                            itemBuilder: (context, imageIndex) {
                              return Image(
                                image: NetworkImage(status[index].images![imageIndex]),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                           Positioned(
                             top: 8,  // Slightly offset outward to tuck nicely under borders
                             left: -20, // Pulled left to create the corner anchor overflow look
                             child: Transform.rotate(
                               angle: -0.785398, // Rotates exactly -45 degrees into a diagonal layout
                               child: Container(
                                 width: 90, // Strict fixed width to align text perfectly across the corner
                                 padding: const EdgeInsets.symmetric(vertical: 4), // Vertical padding for text breathing room
                                 decoration: BoxDecoration(
                                   // Dynamic conditional color formatting
                                   color: status[index].typeOfProduct == 'Original' 
                                       ? Colors.green.withValues(alpha: 0.95) 
                                       : Colors.orange.withValues(alpha: 0.95),
                                   boxShadow: const [
                                     BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                   ],
                                 ),
                                 child: Text(
                                   // Evaluates condition parameter dynamically or defaults to standard fallback
                                   status[index].typeOfProduct == 'Reproducción' ? 'Repro' : 'Original',
                                   textAlign: TextAlign.center,
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 11,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 1.0,
                                   ),
                                 ),
                               ),
                             ),
                           ),
         
                           // Floating Indicator (Only shows if there are multiple images to navigate)
                           if (status[index].images!.length > 1)
                             Positioned(
                               bottom: 8,
                               right: 8,
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: Colors.black54,
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: const Icon(
                                   Icons.swipe_right_alt,
                                   size: 16,
                                   color: Colors.white70,
                                 ),
                               ),
                             ),
                         ],
                       ),
                     ),
                       
                       // Text padding content block
                       Padding(
                         padding: const EdgeInsets.all(12.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // 2. Name of the product
                             Center(
                               child: Text(
                                 '${toBeginningOfSentenceCase(status[index].name)}',
                                 maxLines: 2,
                                 style: const TextStyle(
                                   color: Colors.black87,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 18,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                             ),
                             const SizedBox(height: 4),
                             
                             // 3. Name of the seller
                             Center(
                               child: Text(
                                 user == status[index].sellerId 
                                     ? '${status[index].buyerDisplayName}'
                                     : '${status[index].sellerDisplayName}',
                                 style: const TextStyle(
                                   color: Colors.black54,
                                   fontSize: 13,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                                 maxLines: 1,
                               ),
                             ),
                             const SizedBox(height: 8),
                             
                             // 4. Price (Bottom)
                             Center(
                               child: Text(
                                 '\$${(double.parse(status[index].amount!) + double.parse(status[index].fee!))
                                     .truncateToDouble()
                                     .toStringAsFixed(2)
                                     .replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ',
                                 style: const TextStyle(
                                   fontSize: 15, 
                                   color: Colors.black54,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 1,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
              );


   }

    Widget listTransactions(BuildContext context, List<TransactionEntity> status, ScrollController scrollController, String user) {
    return SizedBox(
          height: 250,
          width: MediaQuery.sizeOf(context).width * 0.95,
          child: RawScrollbar(
          controller: scrollController,
          thumbColor: Colors.black12,
          timeToFade: Duration(seconds: 1),
          thickness: 3.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            padding: EdgeInsets.all(9),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: (){
                                            Navigator.of(context).push(
                                            CupertinoSheetRoute<void>(
                                             scrollableBuilder: (BuildContext context, ScrollController controller) {
      WidgetBuilder widgetBuilder = (BuildContext context) => TransactionDetail(
                                              transaction: status[index]
                                              );
      return widgetBuilder(context);
    },
                                            ),
                                            );
                                          },
                                          child: transactionTile(status, index, user, context),
                                        );
                                      },
                                       separatorBuilder: (context, index) => const SizedBox(width: 10,),
                                       itemCount: status.length
                                    ),
              ),
            );
  }
}





  
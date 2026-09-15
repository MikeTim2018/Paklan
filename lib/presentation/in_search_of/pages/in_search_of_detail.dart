import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:intl/intl.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/auth/models/user.dart';
import 'package:paklan/data/common/models/buyer.dart';
import 'package:paklan/data/common/models/message.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/domain/common/entity/buyer.dart';
import 'package:paklan/domain/common/usecases/get_buyer_profile.dart';
import 'package:paklan/domain/common/usecases/get_user_info.dart';
import 'package:paklan/domain/common/usecases/register_message.dart';
import 'package:paklan/domain/in_search_of/entity/in_search_of.dart';
import 'package:paklan/domain/in_search_of/usecases/get_iso_post.dart';
import 'package:paklan/presentation/chat/widgets/chat_input_with_emoji.dart';
import 'package:paklan/presentation/chat/widgets/chat_view.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/presentation/in_search_of/pages/in_search_of_send_deal.dart';
import 'package:paklan/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class InSearchOfDetail extends StatefulWidget {
  final InSearchOfEntity isoEntity;
  
  const InSearchOfDetail({super.key, required this.isoEntity});

  @override
  State<InSearchOfDetail> createState() => _InSearchOfDetailState();
}

class _InSearchOfDetailState extends State<InSearchOfDetail> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _isoStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _buyerProfileStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userProfileStream;
  final TextEditingController _cancelCon1 = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKeyCancel = GlobalKey<FormState>();
  late var _combinedStreams;

  @override
  void initState() {
    super.initState();
    _isoStream = sl<GetIsoPostUseCase>().call(
      params: widget.isoEntity.transactionId,
    );
    _buyerProfileStream = sl<GetBuyerProfileUseCase>().call(
      params: widget.isoEntity.buyerId,
    );
    _userProfileStream = sl<GetUserInfoUseCase>().call(
      params: widget.isoEntity.buyerId,
    );
    _combinedStreams = CombineLatestStream.combine3(_isoStream,_buyerProfileStream, _userProfileStream, 
    (DocumentSnapshot isoStreamData, DocumentSnapshot buyerProfileStreamData, DocumentSnapshot userStreamData) => [isoStreamData, buyerProfileStreamData, userStreamData],);

  }

  @override
  void dispose() {
    _cancelCon1.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Icon(Icons.horizontal_rule, size: 45),
      ),
      resizeToAvoidBottomInset: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ButtonStateCubit()),
        ],
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              var snackbar = SnackBar(
                content: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.white70),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.black87,
                showCloseIcon: true,
                closeIconColor: Colors.white70,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
            if (state is ButtonSuccessState) {
              var snackbar = const SnackBar(
                content: Text(
                  "¡Trato Actualizado!",
                  style: TextStyle(color: Colors.white70),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.black87,
                showCloseIcon: true,
                closeIconColor: Colors.white70,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
          },
          child: Scaffold(
            appBar: BasicAppbar(
              height: 80,
              hideBack: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 4. Update isoEntity to widget.isoEntity where it sits outside the StreamBuilder
                  Text(toBeginningOfSentenceCase(widget.isoEntity.name!) ?? ''),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text("Detalles del producto"),
                            content: Text(
                              widget.isoEntity.details!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(fontSize: 15, height: 1.3),
                            ),
                            actions: [
                              BasicAppButton(
                                onPressed: () => Navigator.of(context).pop(),
                                content: const Text(
                                  "Entendido",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const BottomAppBar(
              height: 20,
              color: Colors.transparent,
              child: SizedBox(height: 5),
            ),
            body: SingleChildScrollView(
              child: StreamBuilder<List<DocumentSnapshot<Object?>>>(
                // 5. Use the cached stream from initState
                stream: _combinedStreams, 
                builder: (context, state) {
                  if (state.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state.hasError) {
                    return const Center(
                      child: Text(
                          "Ha ocurrido un Error, porfavor intenta de nuevo."),
                    );
                  }
                  InSearchOfEntity isoEntity = InSearchOfModel.fromMap(
                          state.data![0].data()! as Map<String, dynamic>)
                      .toEntity();
                  UserEntity buyerEntity = UserModel.fromMap(
                          state.data![2].data()! as Map<String, dynamic>)
                      .toEntity();
                  late BuyerEntity buyerProfileEntity;
                  if (!state.data![1].exists){
                    buyerProfileEntity = BuyerEntity(
                      totalRatingSum: 0, 
                      transactionId: '', 
                      totalRatingCount: 0, 
                      averageRating: 0.0, 
                      lastRatingMessage: '', 
                      updatedDate: ''
                    );
                  }
                  else{
                      buyerProfileEntity = BuyerModel.fromMap(
                          state.data![1].data()! as Map<String, dynamic>)
                      .toEntity();
                  }
                  String transactionAmount = isoEntity.reward!;
                  
                      return BlocBuilder < UserInfoDisplayCubit, UserInfoDisplayState > (
                          builder: (context, stateUser) {
                            if (stateUser is UserInfoLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (stateUser is UserInfoLoaded) {
                              UserEntity user = stateUser.user;
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: SizedBox(
                          height: MediaQuery.sizeOf(context).height*0.3, // Taller display canvas optimized for detailed product views
                          width: double.infinity,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Gallery Viewer Layer
                                  GestureDetector(
                                    onTap: () {
                                             if (isoEntity.imageUrls != null && isoEntity.imageUrls!.isNotEmpty) {
                                               showDialog(
                                  context: context,
                                  barrierDismissible: true, 
                                  barrierColor: Colors.black87, 
                                  builder: (BuildContext context) {
                                    return Dialog(
                                            backgroundColor: AppColors.background,
                                            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                          // 1. Core Popup Card Container
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.6, 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.black,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: PageView.builder(
                                itemCount: isoEntity.imageUrls!.length,
                                controller: PageController(viewportFraction: 1.0),
                                itemBuilder: (context, imageIndex) {
                                  return InteractiveViewer(
                                    clipBehavior: Clip.none,
                                    minScale: 1.0,
                                    maxScale: 4.0, 
                                    child: Image(
                                      image: NetworkImage(isoEntity.imageUrls![imageIndex]),
                                      fit: BoxFit.contain, 
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                                
                          // 2. Clear Close Action Trigger (Top Right corner) - inside the Stack
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 22, color: Colors.white),
                              ),
                            ),
                          ),
                                
                          // 3. Pinch Hint text overlay (Bottom Center) - inside the Stack
                          const Positioned(
                            bottom: 16,
                            child: IgnorePointer(
                              child: Row(
                                children: [
                                  Icon(Icons.zoom_in, size: 16, color: Colors.white60),
                                  SizedBox(width: 6),
                                  Text(
                                    "Pellizca para hacer zoom",
                                    style: TextStyle(color: Colors.white60, fontSize: 13),
                                  ),
                                  SizedBox(width: 12,),
                                  Icon(Icons.swipe_left, size: 16, color: Colors.white60),
                                  Icon(Icons.swipe_right, size: 16, color: Colors.white60)
                                ],
                              ),
                            ),
                          ),
                                              ],
                                            ),
                                          );
                              
                            },
                          );
                                              }
                                            },
                                          child:SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: (isoEntity.imageUrls == null || isoEntity.imageUrls!.isEmpty)
                                              ? const Image(
                            image: AssetImage(AppImages.userLogo),
                            fit: BoxFit.cover,
                          )
                                              : PageView.builder(
                            itemCount: isoEntity.imageUrls!.length,
                            controller: PageController(viewportFraction: 1.0),
                            itemBuilder: (context, imageIndex) {
                              return Image(
                                image: NetworkImage(isoEntity.imageUrls![imageIndex]),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                                        ),
                                      ),
                          
                                  // Product Condition Corner Band Layer
                                  Positioned(
                                    top: 6,
                                    left: -20,
                                    child: Transform.rotate(
                                      angle: -0.785398, // -45 Degrees rotation angle
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        decoration: BoxDecoration(
                                          color: (isoEntity.typeOfProduct == 'Original')
                                              ? Colors.green.withValues(alpha: 0.95)
                                              : Colors.orange.withValues(alpha: 0.95),
                                          boxShadow: const [
                                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                          ],
                                        ),
                                        child: Text(
                                          isoEntity.typeOfProduct == 'Reproducción' ? 'Repro' : 'Original',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          
                                  // Swipe Navigation Indicator (Only visible if multi-image array populates)
                                  if (isoEntity.imageUrls != null && isoEntity.imageUrls!.length > 1)
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.swipe_left, size: 16, color: Colors.white70),
                                            SizedBox(width: 4),
                                            Icon(Icons.swipe_right, size: 16, color: Colors.white70),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                                              ),
                                            ),
                                            GestureDetector(
                                       onTap: () {
                                        showModalBottomSheet(
                                                        context: context,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                        ),
                                                        builder: (modalContext) {
                                                          return Container(
                                                            height: 400,
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 5,
                                            margin: const EdgeInsets.only(bottom: 15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          Text(
                                            buyerEntity.displayName,
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Text(buyerEntity.email, style: const TextStyle(fontSize: 15, color: Colors.grey),),
                                          const SizedBox(height: 10),
                                          Container(
                                                                height: 100,
                                                                width: 100,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image: buyerEntity.photoLink.isEmpty ? 
                                                                    const AssetImage(
                                                                      AppImages.userLogo
                                                                    ) : NetworkImage(
                                                                      buyerEntity.photoLink,
                                                                    ),
                                                                    fit: BoxFit.cover
                                                                  ),
                                                                  color: Colors.white,
                                                                  shape: BoxShape.circle,
                                                                  border: BoxBorder.all(
                                                                  color: buyerEntity.active ? 
                                                                  Colors.greenAccent[200]!
                                                                  :Colors.yellowAccent[400]!
                                                                  ,
                                                                  width: 1.5
                                                                )
                                                                ),
                                           ),
                                          const SizedBox(height: 10),
                                          StarRating(
                                                    borderColor: Colors.amberAccent,
                                                    size: 25,
                                                    rating: buyerProfileEntity.averageRating,
                                                    allowHalfRating: true,
                                                    
                                                   ),
                                          Text(
                                            "Rating Promedio: ${buyerProfileEntity.averageRating.toStringAsFixed(1)}",
                                            maxLines: 2,
                                            
                                            ),
                                          const SizedBox(height: 5),
                                          Text("Total de Ratings: ${buyerProfileEntity.totalRatingCount}"),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Último Mensaje de Rating:\n ${buyerProfileEntity.lastRatingMessage}",
                                            maxLines: 2,),
                                        ],
                                      ),
                                                          );
                                                        }
                                        );
                                       },
                                       child: Row(
                                         children: [
                                          SizedBox(width: 15,),
                                           Container(
                                                                height: 60,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image: buyerEntity.photoLink.isEmpty ? 
                                                                    const AssetImage(
                                                                      AppImages.userLogo
                                                                    ) : NetworkImage(
                                                                      buyerEntity.photoLink,
                                                                    ),
                                                                    fit: BoxFit.cover
                                                                  ),
                                                                  color: Colors.white,
                                                                  shape: BoxShape.circle,
                                                                  border: BoxBorder.all(
                                                                  color: buyerEntity.active ? 
                                                                  Colors.greenAccent[200]!
                                                                  :Colors.yellowAccent[400]!
                                                                  ,
                                                                  width: 1.5
                                                                )
                                                                ),
                                           ),
                                           SizedBox(width: 10,),
                                           Column(
                                             children: [
                                               Row(
                                                 children: [
                                                   SizedBox(
                                                        width: 120,
                                                        child: Text(
                                                          buyerEntity.displayName,
                                                          style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis, decoration: TextDecoration.underline),
                                                          ),
                                                                                         ),
                                                    Text("(${buyerProfileEntity.totalRatingSum})", style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis),),
                                                 ],
                                               ),
                                              SizedBox(height: 5,),
                                              Row(
                                                children: [
                                                  StarRating(
                                                    borderColor: Colors.amberAccent,
                                                    size: 15,
                                                    rating: buyerProfileEntity.averageRating,
                                                    allowHalfRating: true,
                                                    
                                                   ),
                                                                                         Text(
                                                    buyerProfileEntity.averageRating.toStringAsFixed(1),
                                                    style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis),
                                                                                         ),
                                                ],
                                              ),
                                             ],
                                           ),
                                         ],
                                       ),
                                              ),
                                            SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                          SizedBox(width: 15,),
                          Text(
                              "Recompensa: \$$transactionAmount",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 18,),
                              ),
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                            BasicAppButton(
                            width: MediaQuery.sizeOf(context).width*0.85,
                            onPressed: (){
                              AppNavigator.push(context, InSearchOfSendDeal(userEntity: buyerEntity, isoEntity: isoEntity));
                            },
                            title: "Mandar trato"
                            ),
                          
                                            const SizedBox(height: 5),
                                SizedBox(height: 15),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(23),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width / 1.1,
                                    height: MediaQuery.sizeOf(context).height * 0.49,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(23),
                                      border: Border.all(color: Colors.black12, width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(13.0),
                                              child: Text(
                                                "Chat general",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                
                                        // Messages List - WhatsApp Style
                                        Expanded(
                                          child: ChatMessagesWidgetWithReadReceipts(
                                            chatId: isoEntity.chatId!,
                                            currentUserId: user.userId,
                                          ),
                                        ),
                                
                                        // Divider
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Divider(height: 1),
                                        ),
                                
                                        // Input Section
                                        ChatInputWithEmoji(
                                         messageController: _messageController,
                                         hintText: 'Mensaje',
                                         onSend: () {
                                           if (_messageController.text.trim().isNotEmpty) {
                                             sl<RegisterMessageUseCase>().call(
                                               params: MessageModel(
                                                 message: _messageController.text,
                                                 chatId: isoEntity.chatId!,
                                                 senderId: user.userId,
                                                 messageId: '',
                                                 senderName: user.displayName,
                                                 createdTime: '',
                                               ),
                                             );
                                             _messageController.clear();
                                           }
                                         },
                                       ),
                                      ],
                                    ),
                                  ),
                                )
                                  
                              ],
                            ),
                          );
                        }
                        return Container();
                          }
                      );
                  },
                  ),
            ),
            ),
        )
          ),
    );
  }


  Form reasonToCancelForm(BuildContext context) {
    return Form(
        key: _formKeyCancel,
        child: TextFormField(
        controller: _cancelCon1,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        validator: (value){
        if (value!.isEmpty){
          return 'El campo no debe estar vacío';
        }
        if (value.length>150){
          return 'El Campo no debe exceder los 150 caracteres';
        }
        if (value.length<5){
          return 'El Campo debe ser mayor a 5 caracteres';
        }
        else{
          return null;
        }
                },
            
          ),
      );
  }
  
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/bottomsheet/app_bottomsheet.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/domain/transactions/entity/user.dart';
import 'package:paklan/domain/transactions/usecases/create_transaction.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/presentation/transactions/bloc/clabe_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/photo_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/photo_selection_state.dart';
import 'package:paklan/presentation/transactions/bloc/user_type_selection_cubit.dart';
import 'package:paklan/presentation/transactions/pages/transaction_success_wo_confirmation.dart';



// ignore: must_be_immutable
class TransactionAmount extends StatelessWidget {
  final TextEditingController _amountCon = TextEditingController();
  final TextEditingController _descriptionCon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCon = TextEditingController();
  final UserEntityTransaction userEntity;
  String userId = '';
  String userFirstName = '';
  TransactionAmount({super.key, required this.userEntity});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserTypeSelectionCubit()),
        BlocProvider(create: (context) => ButtonStateCubit()),
        BlocProvider(create: (context) => UserInfoDisplayCubit()..displayUserInfo()),
        BlocProvider(create: (context) => ImagePickerCubit()),
        ],
      child: MultiBlocListener(
        listeners: [
        BlocListener<ButtonStateCubit, ButtonState>(
        listener: (context, state) {
          if (state is ButtonFailureState){
                var snackbar = SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: TextStyle(
                      color: Colors.white70
                    ),),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  showCloseIcon: true,
                  closeIconColor: Colors.white70,
                  );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              }
          if (state is ButtonSuccessState){
            AppNavigator.pushAndRemove(context, TransactionSuccessWoConfirmation());
          }
        },
        ),
        BlocListener<UserInfoDisplayCubit, UserInfoDisplayState>(listener: (context, state){
              if (state is UserInfoLoaded) {
                 userId = state.user.userId;
                 userFirstName = state.user.displayName;
              }
        }
        )
        ],
        child: Scaffold(
          appBar: BasicAppbar(
            height: 60,
          ),
          bottomNavigationBar: BottomAppBar(
            child: Column(
              children: [
                Text(
                  "Paso 2 de 2", 
                  textAlign: TextAlign.center,),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        alignment: Alignment.bottomLeft,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: AppColors.primaryButton, 
                        ),
                      ),
                      
                    ],
                  )
              ],
            ),
            ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _name(context),
                  SizedBox(height: 10,),
                  _nameField(context),
                  SizedBox(height: 10,),
                  _description(context),
                  SizedBox(height: 10,),
                  _descriptionField(context),
                  SizedBox(height: 10,),
                  _typeOfProduct(context),
                  SizedBox(height: 10,),
                  _users(context),
                  SizedBox(height: 10,),
                  _photosRequest(context),
                  SizedBox(height: 10,),
                  _photoUpload(context),
                  SizedBox(height: 10,),
                  _amount(context),
                  SizedBox(height: 10,),
                  _amountField(context),
                  SizedBox(height: 10,),
                  _sendDeal(context),
                      
                ],
              ),
            ),
          )
          ),
        )
    );
    }

 Widget _amount(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        '¿Cuánto estás pidiendo por el producto?',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _name(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        '¿Qué producto estás ofreciendo?',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

 Widget _photosRequest(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        'Sube fotos del producto desde:',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
  
  Widget _photoUpload(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocListener<ImagePickerCubit, ImagePickerState>(
                  listener: (context, state) {
                    if (state is ImagePickerErrorState){
                    ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
              );
                  }
                  },
                  child: BlocBuilder<ImagePickerCubit, ImagePickerState>(builder: (context, state){
                    if (state is ImagePickerInitialState){
                      return const Text(
                        'No se ha seleccionado ninguna imagen',
                        style: TextStyle(color: Colors.black87),
                      );
                    }
                    List<dynamic> imagesToDisplay = [];
                    if (state is ImagePickerLoadingState){
                      return const CircularProgressIndicator();
                    }
                    if (state is ImagePickerLoadedState){
                      imagesToDisplay = state.images;
                      return Column(
                        children: [
                          SizedBox(
                            height: 130,
                            child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: imagesToDisplay.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          imagesToDisplay[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Delete Action Button Overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => context.read<ImagePickerCubit>().deleteImage(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${state.images.length} imagen(es) seleccionada(s)',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      );
                    }
                    return Container();
                  }),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<ImagePickerCubit, ImagePickerState> (builder: (context, state) 
                    {
                    return ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          AppColors.secondBackground
                        ),
                      ),
                      onPressed: () => context.read<ImagePickerCubit>().pickCameraImage(),
                      icon: const Icon(Icons.camera_alt, color: Colors.black87,),
                      label: const Text('Cámara', style: TextStyle(color: Colors.black87),),
                    );
                    },
                    ),
                    const SizedBox(width: 10),
                      BlocBuilder<ImagePickerCubit, ImagePickerState> (builder: (context, state) {
                        return ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                              AppColors.secondBackground
                            ),
                          ),
                          onPressed: () => context.read<ImagePickerCubit>().pickMultipleImages(),
                          icon: const Icon(Icons.photo_library, color: Colors.black87,),
                          label: const Text('Galería', style: TextStyle(color: Colors.black87),),
                        );
                      }
                    ),
                    
                  ],
                ),
              ],
            ),
        ),
      ),
    );
  }
  Widget _descriptionField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        maxLines: 4,
        validator: (value){
          if (value!.isEmpty || value.length<5){
            return 'El campo debe tener al menos 5 caracteres';
          }
          if(value.length>250){
            return 'El campo debe tener menos de 250 caracteres';
          }
          else{
            return null;
          }
        },
        controller: _descriptionCon,
        decoration: InputDecoration(
          hintText: "Etiqueta desgastada, no tiene pila, etc."
        ),
      ),
    );
  }
  Widget _typeOfProduct(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        '¿Qué tipo de producto es?',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _amountField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        validator: (value){
          if (value!.isEmpty || RegExp(r'\D+').hasMatch(value)){
            return 'Ingresa una cantidad correcta';
          }
          else{
            return null;
          }
        },
        controller: _amountCon,
        decoration: InputDecoration(
          hintText: "\$1000.00"
        ),
      ),
    );
  }

  Widget _nameField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        validator: (value){
          if (value!.isEmpty || value.length<3){
            return 'El campo debe tener al menos 3 caracteres';
          }
          if(value.length>24){
            return 'El campo debe tener menos de 25 caracteres';
          }
          else{
            return null;
          }
        },
        controller: _nameCon,
        decoration: InputDecoration(
          hintText: "Nombre del producto"
        ),
      ),
    );
  }


  Widget _description(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        'Describe el producto que estás ofreciendo',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _users(BuildContext context) {
    return BlocBuilder<UserTypeSelectionCubit,int>(
      builder: (context,state) {
        return Padding(
          padding: const EdgeInsets.all(13.0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            userTile(context,1,'Original'),
            const SizedBox(width: 20,),
            userTile(context,2,'Reproducción'),
          ],
                ),
        );
      }

    );
  }
  

  Expanded userTile(BuildContext context,int userIndex,String gender) {
    return Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: (){
            context.read<UserTypeSelectionCubit>().selectUser(userIndex);
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: context.read<UserTypeSelectionCubit>().selectedIndex == userIndex ?
               AppColors.primaryButton : AppColors.secondBackground,
              borderRadius: BorderRadius.circular(30)
            ),
            child: Center(
              child: Text(
                gender,
                style: TextStyle(
                  color: context.read<UserTypeSelectionCubit>().selectedIndex == userIndex ?
                  AppColors.primary : Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 16
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _sendDeal(context){
        return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Builder(
          builder: (context) {
            return BasicReactiveButton(
              onPressed: (){
                int image_count = context.read<ImagePickerCubit>().getCurrentImageCount();
                if (_formKey.currentState!.validate() && image_count>0){
                int userType = context.read<UserTypeSelectionCubit>().selectedIndex;
                NewTransactionModel newTransaction = NewTransactionModel(
                  name: _nameCon.text.trim(),
                  amount: '${_amountCon.text}.00',
                  sellerDisplayName: userFirstName,
                  sellerId: userId,
                  buyerDisplayName: userEntity.displayName,
                  buyerId: userEntity.userId,
                  buyerConfirmation: false,
                  sellerConfirmation: true,
                  details: "En caso de no ser aceptado el trato dentro de 24hrs se cancelará",
                  status: "Enviado",
                  dealDetails: _descriptionCon.text.trim(),
                  images: context.read<ImagePickerCubit>().getCurrentImages(),
                  typeOfProduct: userType == 1 ? "Original" : "Reproducción",

                );
                context.read<ButtonStateCubit>().execute(
                  usecase: CreateTransactionUseCase(),
                  params: newTransaction
                );
              }
              else if(image_count==0){
                var snackbar = SnackBar(
                  content: Text(
                    "Debes subir al menos una foto o imagen del producto",
                    style: TextStyle(
                      color: Colors.white70
                    ),),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  showCloseIcon: true,
                  closeIconColor: Colors.white70,
                  );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              }
              },
              title: 'Enviar Trato',
            );
          }
        ),
      ),
    );
  }
}


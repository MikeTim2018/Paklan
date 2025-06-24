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
import 'package:paklan/domain/transactions/usecases/get_clabes.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/presentation/home/widgets/credit_card_ui.dart';
import 'package:paklan/presentation/transactions/bloc/clabe_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/user_type_selection_cubit.dart';
import 'package:paklan/presentation/transactions/pages/transaction_success_wo_confirmation.dart';
import 'package:paklan/service_locator.dart';


// ignore: must_be_immutable
class TransactionAmount extends StatelessWidget {
  final TextEditingController _amountCon = TextEditingController();
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _clabeStream = sl<GetClabesUseCase>().call();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
        BlocProvider(create: (context) => ClabeSelectionCubit()),
        
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
                 userFirstName = state.user.firstName;
              }
        }
        )
        ],
        child: Scaffold(
          appBar: BasicAppbar(
            title: Text("Definir el Trato"),
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
                        width: 330,
                        alignment: Alignment.bottomLeft,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blueGrey, 
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
                  SizedBox(height: 25,),
                  _selectType(context),
                  SizedBox(height: 10,),
                  _users(context),
                  SizedBox(height: 10,),
                  _amount(context),
                  SizedBox(height: 10,),
                  _amountField(context),
                  SizedBox(height: 10,),
                  _clabe(context),
                  SizedBox(height: 10,),
                  _clabes(),
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
        'Define el monto del trato',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

 Widget _selectType(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        '¿Qué quieres hacer?',
        style: TextStyle(
          fontSize: 25,
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

  Widget _clabe(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        'Ingresa tu cuenta CLABE',
        style: TextStyle(
          fontSize: 25,
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
            userTile(context,1,'Vender'),
            const SizedBox(width: 20,),
            userTile(context,2,'Comprar'),
          ],
                ),
        );
      }

    );
  }
  
  Widget _clabes() {
    return StreamBuilder(
      stream: _clabeStream, 
      builder: (context, AsyncSnapshot<DocumentSnapshot> state){
              if(state.hasError){
                return SizedBox(
                  height: 100,
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
              if(state.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> userData = state.data!.data() as Map<String, dynamic>;
              if (!userData.keys.contains("CLABEs") || userData['CLABEs'].length == 0){
                return SizedBox(
                  height: 120,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        "No Tienes Cuentas registradas, primero registra una en el apartado de Cuentas en la página principal.",
                        style: TextStyle(
                          fontSize: 17
                        ),
                      ),
                    ),
                  ),
                );
              }
        
              return BlocBuilder<ClabeSelectionCubit, String>(
                builder: (context, state) {
                return  GestureDetector(
                        onTap: (){
                          AppBottomsheet.display(
                            context,
                            SizedBox(
                             height: MediaQuery.of(context).size.height / 3.6,
                             child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (innerContext, index){
                          return GestureDetector(
                            onTap: (){
                Navigator.pop(innerContext);
                context.read<ClabeSelectionCubit>().selectClabe(
                  userData['CLABEs'][index],
                );
                            },
                            child: CreditCardUiCustom(
                                   userData: userData, 
                                   index: index
                               ),
                          );
                        }, 
                        separatorBuilder: (context, index) => SizedBox(width: 20,), 
                        itemCount: userData['CLABEs'].length
                        )
                            )
                            );
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.secondBackground,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                             Text(
                               state
                             ),
                             const Icon(
                               Icons.keyboard_arrow_down
                             )
                            ],
                          ),
                        ),
                      );
      }
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
               AppColors.primary : AppColors.secondBackground,
              borderRadius: BorderRadius.circular(30)
            ),
            child: Center(
              child: Text(
                gender,
                style: const TextStyle(
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
                String clabe = context.read<ClabeSelectionCubit>().selectedClabe;
                if (_formKey.currentState!.validate() && clabe.isNotEmpty){
                int userType = context.read<UserTypeSelectionCubit>().selectedIndex;
                NewTransactionModel newTransaction = NewTransactionModel(
                  amount: '${_amountCon.text}.00',
                  sellerFirstName: userType == 1 ? userFirstName  : userEntity.firstName,
                  sellerId: userType == 1 ? userId  : userEntity.userId,
                  buyerFirstName: userType == 1 ? userEntity.firstName : userFirstName,
                  buyerId: userType == 1 ? userEntity.userId : userId,
                  buyerConfirmation: userType == 1 ? false : true,
                  sellerConfirmation: userType == 1 ? true : false,
                  details: "Falta Confirmación de Trato",
                  status: "En proceso",
                  clabe: clabe,
                );
                context.read<ButtonStateCubit>().execute(
                  usecase: CreateTransactionUseCase(),
                  params: newTransaction
                );
              }
              else if(clabe.isEmpty){
                var snackbar = SnackBar(
                  content: Text(
                    "No has seleccionado una cuenta CLABE",
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
              title: 'Terminar'
            );
          }
        ),
      ),
    );
  }
}


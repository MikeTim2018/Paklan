import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/assets/app_vectors.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/transactions/usecases/create_clabe.dart';
import 'package:paklan/domain/transactions/usecases/delete_clabe.dart';
import 'package:paklan/domain/transactions/usecases/get_clabes.dart';
import 'package:paklan/service_locator.dart';

class Settings extends StatelessWidget{
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _clabeStream = sl<GetClabesUseCase>().call();
  final TextEditingController _clabeCon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ButtonStateCubit(),
      child: BlocListener<ButtonStateCubit, ButtonState>(
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
            var snackbar = SnackBar(
                  content: Text(
                    "¡Operación Exitosa!",
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
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
              stream: _clabeStream,
              builder: (context, AsyncSnapshot<DocumentSnapshot> state){
              if(state.hasError){
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
              if(state.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              if(state.data == null || !state.hasData){
                return listNoClabes(context);
              }
              Map<String, dynamic> userData = state.data!.data() as Map<String, dynamic>;
        
              return Scaffold(
                  appBar: BasicAppbar(hideBack: true,),
                  body: SingleChildScrollView(
                        child: Center(
                          child: Form(
                            key: _formKey,
                            child: Column(
                                  children: [
                                    Text(
                                      "Cuentas CLABE registradas",
                                      style: TextStyle(fontSize: 23),),
                                    SizedBox(height: 25,),
                                    listClabes(context, userData["CLABEs"],),
                                    SizedBox(height: 10,),
                                    _clabe(context),
                                    SizedBox(height: 10,),
                                    _clabeField(context),
                                    SizedBox(height: 10,),
                                    Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: BasicReactiveButton(
                                        title: "Añadir CLABE",
                                        onPressed: () {
                                      if (_formKey.currentState!.validate()){
                                         context.read<ButtonStateCubit>().execute(
                                         usecase: CreateClabenUseCase(),
                                         params: _clabeCon.text);
                                         _clabeCon.clear();
                                      }
                                      },),
                                    ),
                                  ],
                                ),
                          ),
                        ),
              ),
              );    
              }
          ),
      ),
    )
    );
    }
  Widget _clabe(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        'Registra una cuenta CLABE',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
  Widget _clabeField(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        autocorrect: false,
        enableSuggestions: false,
        
        validator: (value){
          if (value!.isEmpty || value.length != 18 || RegExp(r'\D+').hasMatch(value)){
            return 'Tu cuenta clabe debe contener 18 dígitos';
          }
          else{
            return null;
          }
        },
        controller: _clabeCon,
        decoration: InputDecoration(
          helper: Text(
            "Tu cuenta CLABE es indispensable para hacer tratos",
            style: TextStyle(fontSize: 12),),
          hintText: "Cuenta CLABE a 18 dígitos"
        ),
      ),
    );
  }

Widget listNoClabes(BuildContext context) {
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
                  SizedBox(height: 50,),
                  Text(
                    "¡No tienes cuentas CLABE registradas!",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "Registra una para iniciar un trato",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary
                    ),
                  ),
                  SizedBox(height: 30,),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BasicReactiveButton(
                      onPressed: (){
                          if (_formKey.currentState!.validate()){
                              context.read<ButtonStateCubit>().execute(
                              usecase: CreateClabenUseCase(),
                              params: _clabeCon.text);
                            }
                        },
                        title: 'Añadir CLABE'
                    ),
                  ),
                  ]
                  ),
    );
  }

  Widget listClabes(BuildContext context, List<dynamic> clabes) {
    return SizedBox(
      height: 220,
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
                                    // Navigator.of(context).push(
                                    // CupertinoSheetRoute<void>(
                                    //  builder: (BuildContext context) => TransactionDetail(
                                    //   transaction: clabes[index]
                                    //   ),
                                    // ),
                                    // );
                                  },
                                  child: clabeTile(context, clabes, index),
                                );
                              },
                               separatorBuilder: (context, index) => const SizedBox(height: 10,),
                               itemCount: clabes.length
                            ),
      ),
    );
  }

  Widget clabeTile(context, List<dynamic> clabes, int index) {
    return Builder(
      builder: (context){
      return Dismissible(
        key: Key(index.toString()),
        confirmDismiss: (direction) async{
           return await showDialog(
            context: context, 
            builder: (innerContext){
              return BlocProvider.value(
                      value: context.read<ButtonStateCubit>(),
                      child: AlertDialog(
          title: const Text("Eliminar Cuenta"),
          content: const Text("¿Estás seguro de borrar esta cuenta?"),
          actions: <Widget>[
            ElevatedButton(
                          style: ElevatedButton.styleFrom(
                           minimumSize: Size(50, 50),
                          ),
                    child: Text(
                       "Regresar",
                       style: const TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.w400
                       ),
                    ),
                    onPressed: () => Navigator.of(innerContext).pop(false)
                        ),
            CustomReactiveButton(
              onPressed: (){
                context.read<ButtonStateCubit>().execute(
                  usecase: DeleteClabenUseCase(),
                  params: clabes[index]
                );
                Navigator.of(innerContext).pop(false);
              },
              color: Colors.redAccent,
              title: "Borrar"
            ),
          ],
                      )
        );
            }
            );
        },
        background: Container( 
          decoration: BoxDecoration(
                  color: Colors.redAccent,
                ),
                child: SvgPicture.asset(
                  AppVectors.delete,
                  
                ),),
        child: Card(
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
                    AppVectors.bank,
                    fit: BoxFit.fill,
                  ),
              ),
            ),
            title: Text(
              'Cuenta Clabe: ${clabes[index]}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              ),
              trailing: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppVectors.rightArrow,
                  fit: BoxFit.none,
                ),
              ),
          ),
        ),
      );
      }
      );
  }
}


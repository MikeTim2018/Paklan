import 'package:flutter/material.dart';
import 'package:paklan/common/bloc/app_lifecycle/app_lifecycle_cubit.dart';
import 'package:paklan/presentation/home/widgets/header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/presentation/transactions/widgets/transaction_display.dart';

class TransactionHome extends StatefulWidget {
  const TransactionHome({super.key});

  @override
  State<TransactionHome> createState() => _TransactionHomeState();
}

class _TransactionHomeState extends State<TransactionHome> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AppLifecycleCubit>().registerState(active: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try{
      context.read<AppLifecycleCubit>().registerState(active: false);
    } catch(e){
      print(e);
    }
    finally{
    super.dispose();
  }
  }

  // 4. Override the lifecycle method to call your Cubit
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<AppLifecycleCubit>().registerState(active: true);
      
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      context.read<AppLifecycleCubit>().registerState(active: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: const [ 
                Header(),
                TransactionDisplay(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
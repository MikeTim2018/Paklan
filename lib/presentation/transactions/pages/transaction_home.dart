import 'package:flutter/material.dart';
import 'package:paklan/common/helper/stream_provider/app_stream_provider.dart';
import 'package:paklan/presentation/home/widgets/header.dart';
import 'package:paklan/presentation/transactions/widgets/transaction_display.dart';

class TransactionHome extends StatefulWidget {
  const TransactionHome({super.key});

  @override
  State<TransactionHome> createState() => _TransactionHomeState();
}

class _TransactionHomeState extends State<TransactionHome> 
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final streams = AppStreamsProvider.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      const Header(),
                      TransactionDisplay(
                        transactionsStream: streams.transactionsStream,
                        isoPostsStream: streams.isoPostsStream,
                        currentUserId: streams.currentUserId,
                      ),
                    ],
        ),
      ),
    );
  }
}
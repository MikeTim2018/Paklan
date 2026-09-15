import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paklan/domain/transactions/usecases/get_transactions.dart';
import 'package:paklan/domain/in_search_of/usecases/get_iso_posts.dart';
import 'package:paklan/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class AppStreamsProvider extends StatefulWidget {
  final Widget child;
  
  const AppStreamsProvider({
    Key? key, 
    required this.child,
  }) : super(key: key);
  
  @override
  State<AppStreamsProvider> createState() => _AppStreamsProviderState();
  
  static _InheritedAppStreams of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_InheritedAppStreams>();
    assert(result != null, 'No AppStreamsProvider found in context');
    return result!;
  }
}

class _AppStreamsProviderState extends State<AppStreamsProvider> {
  late final Stream<QuerySnapshot> _transactionsStream;
  late final Stream<QuerySnapshot> _isoPostsStream;
  late final String _currentUserId;
  
  @override
  void initState() {
    super.initState();
    
    // ✅ Use shareReplay to cache the last value and replay it to new subscribers
    _transactionsStream = sl<GetTransactionsUseCase>()
      .call()
      .shareReplay(maxSize: 1);  // ✅ Replays last event to new listeners
    
    _isoPostsStream = sl<GetIsoPostsUseCase>()
      .call()
      .shareReplay(maxSize: 1);  // ✅ Replays last event to new listeners
    
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    debugPrint('✅ AppStreamsProvider: Streams initialized with shareReplay');
  }
  
  @override
  void dispose() {
    debugPrint('✅ AppStreamsProvider: Disposed');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _InheritedAppStreams(
      transactionsStream: _transactionsStream,
      isoPostsStream: _isoPostsStream,
      currentUserId: _currentUserId,
      child: widget.child,
    );
  }
}

class _InheritedAppStreams extends InheritedWidget {
  final Stream<QuerySnapshot> transactionsStream;
  final Stream<QuerySnapshot> isoPostsStream;
  final String currentUserId;
  
  const _InheritedAppStreams({
    required this.transactionsStream,
    required this.isoPostsStream,
    required this.currentUserId,
    required Widget child,
  }) : super(child: child);
  
  @override
  bool updateShouldNotify(_InheritedAppStreams oldWidget) => false;
}

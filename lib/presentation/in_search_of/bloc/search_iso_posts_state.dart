import 'package:paklan/domain/in_search_of/entity/in_search_of.dart';

abstract class SearchIsoPostsState {}

class ISOPostLoaded extends SearchIsoPostsState{ 
  final List<InSearchOfEntity> posts;
  ISOPostLoaded({required this.posts});
 }

class ISOPostLoading extends SearchIsoPostsState{}

class ISOPostFailed extends SearchIsoPostsState{
  final String error;
  ISOPostFailed({required this.error});
}

class ISOPostEmpty extends SearchIsoPostsState{}

class ISOPostInitial extends SearchIsoPostsState{}
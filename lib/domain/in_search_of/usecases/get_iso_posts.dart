import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paklan/domain/in_search_of/repository/in_search_of_repository.dart';
import 'package:paklan/service_locator.dart';

class GetIsoPostsUseCase {
  Stream<QuerySnapshot<Map<String, dynamic>>> call({dynamic params}) {
    return sl<InSearchOfRepository>().getISOPosts();
  }
}
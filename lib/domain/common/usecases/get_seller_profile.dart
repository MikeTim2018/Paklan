import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class GetSellerProfileUseCase {
  Stream<DocumentSnapshot<Map<String, dynamic>>> call({dynamic params}) {
    return sl<CommonRepository>().getSellerProfileStream(params!);
  }
}
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class MarkChatAsReadParams {
  final String chatId;
  final String userId;

  MarkChatAsReadParams({
    required this.chatId,
    required this.userId,
  });
}

class MarkChatAsReadUseCase implements UseCase<void, MarkChatAsReadParams> {
  @override
  Future<void> call({MarkChatAsReadParams? params}) async {
    sl<CommonRepository>().markChatAsRead(params!.chatId, params.userId);
  }
}
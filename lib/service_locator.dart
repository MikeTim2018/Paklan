import 'package:get_it/get_it.dart';
import 'package:paklan/data/auth/repository/auth_repository_impl.dart';
import 'package:paklan/data/auth/source/auth_firebase_service.dart';
import 'package:paklan/data/profile/repository/profile_repository_impl.dart';
import 'package:paklan/data/profile/source/profile_firebase_service.dart';
import 'package:paklan/data/transactions/repository/transactions_repository_impl.dart';
import 'package:paklan/data/transactions/source/transaction_firebase_service.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/domain/auth/usecases/get_ages.dart';
import 'package:paklan/domain/auth/usecases/get_user.dart';
import 'package:paklan/domain/auth/usecases/is_logged_in.dart';
import 'package:paklan/domain/auth/usecases/send_password_reset_email.dart';
import 'package:paklan/domain/auth/usecases/signin.dart';
import 'package:paklan/domain/auth/usecases/signin_with_facebook.dart';
import 'package:paklan/domain/auth/usecases/signin_with_google.dart';
import 'package:paklan/domain/auth/usecases/signout.dart';
import 'package:paklan/domain/auth/usecases/signup.dart';
import 'package:paklan/domain/profile/repository/profile.dart';
import 'package:paklan/domain/profile/usecases/upload_profile_picture.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/domain/transactions/usecases/create_clabe.dart';
import 'package:paklan/domain/transactions/usecases/delete_clabe.dart';
import 'package:paklan/domain/transactions/usecases/get_clabes.dart';
import 'package:paklan/domain/transactions/usecases/get_completed_transactions.dart';
import 'package:paklan/domain/transactions/usecases/get_server_datetime.dart';
import 'package:paklan/domain/transactions/usecases/update_deal.dart';
import 'package:paklan/domain/transactions/usecases/create_transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_transactions.dart';
import 'package:paklan/domain/transactions/usecases/get_users_by_search.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  //Services
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
    );

  sl.registerSingleton<TransactionFirebaseService>(
    TransactionFirebaseServiceImpl()
    );
  sl.registerSingleton<ProfileFirebaseService>(
    ProfileFirebaseServiceImpl()
    );
  //Repositories

  sl.registerSingleton<AuthRepository>(
  AuthRepositoryImpl()
);

  sl.registerSingleton<TransactionRepository>(
    TransactionsRepositoryImpl()
  );
  
  sl.registerSingleton<ProfileRepository>(
  ProfileRepositoryImpl()
  );
  //Usecases
  sl.registerSingleton<UploadProfilePictureUseCase>(
    UploadProfilePictureUseCase()
  );
  sl.registerSingleton<SignupUseCase>(
  SignupUseCase()
);

  sl.registerSingleton<SignoutUseCase>(
    SignoutUseCase()
  );

  sl.registerSingleton<GetAgesUseCase>(
  GetAgesUseCase()
);
  
  sl.registerSingleton<SigninUseCase>(
  SigninUseCase()
);

  sl.registerSingleton<SigninWithGoogleUseCase>(
  SigninWithGoogleUseCase()
);

  sl.registerSingleton<SigninWithFacebookUseCase>(
  SigninWithFacebookUseCase()
);

  sl.registerSingleton<SendPasswordResetEmailUseCase>(
  SendPasswordResetEmailUseCase()
);

  sl.registerSingleton<IsLoggedInUseCase>(
  IsLoggedInUseCase()
);

  sl.registerSingleton<GetUserUseCase>(
  GetUserUseCase()
);

sl.registerSingleton<GetTransactionsUseCase>(
  GetTransactionsUseCase()
);

sl.registerSingleton<GetUsersBySearchUseCase>(
  GetUsersBySearchUseCase()
);

sl.registerSingleton<CreateTransactionUseCase>(
  CreateTransactionUseCase()
);

sl.registerSingleton<GetTransactionUseCase>(
  GetTransactionUseCase()
);

sl.registerSingleton<UpdateDealUseCase>(
  UpdateDealUseCase()
);

sl.registerSingleton<GetCompletedTransactionsUseCase>(
  GetCompletedTransactionsUseCase()
);

sl.registerSingleton<GetClabesUseCase>(
  GetClabesUseCase()
);

sl.registerSingleton<DeleteClabenUseCase>(
  DeleteClabenUseCase()
);

sl.registerSingleton<CreateClabenUseCase>(
  CreateClabenUseCase()
);

sl.registerSingleton<GetServerDatetimeUseCase>(
  GetServerDatetimeUseCase()
);


}
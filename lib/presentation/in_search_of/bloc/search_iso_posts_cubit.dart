import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/domain/in_search_of/usecases/search_iso_posts.dart';
import 'package:paklan/presentation/in_search_of/bloc/search_iso_posts_state.dart';
import 'package:paklan/service_locator.dart';

class SearchIsoPostsCubit extends Cubit<SearchIsoPostsState> {
  SearchIsoPostsCubit(): super(ISOPostInitial());

  void searchISOPosts({String ? searchVal}) async{
    emit(
      ISOPostLoading()
    );

    var returnedData = await sl<SearchIsoPostsUseCase>().call(params: searchVal!);

    returnedData.fold(
      (error){
        emit(
          ISOPostFailed(error: error)
        );
      }, 
      (data){
        if (data.length == 0){
          emit(ISOPostEmpty());
        }
        else{
        emit(
          ISOPostLoaded(
            posts: data
          )
        );
        }
      }
  );
  }
  
  void resetSearch(){
    emit (ISOPostInitial());
  }
}
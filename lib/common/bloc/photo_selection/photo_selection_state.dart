import 'dart:io';


abstract class ImagePickerState {}

class ImagePickerInitialState extends ImagePickerState {}

class ImagePickerLoadingState extends ImagePickerState {}

class ImagePickerLoadedState extends ImagePickerState {
  final List<File> images;
  ImagePickerLoadedState(this.images);
}

class ImagePickerErrorState extends ImagePickerState {
  final String errorMessage;
  ImagePickerErrorState(this.errorMessage);
}
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paklan/presentation/transactions/bloc/photo_selection_state.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ImagePickerCubit extends Cubit<ImagePickerState> {
  final ImagePicker _picker = ImagePicker();
  static const int maxImageLimit = 6;

  ImagePickerCubit() : super(ImagePickerInitialState());
  
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return compressedXFile != null ? File(compressedXFile.path) : null;
    } catch (e) {
      return file;
    }
  }

  Future<void> pickMultipleImages() async {
    // Get existing images if we are already in the loaded state
    List<File> currentImages = getCurrentImages();
    if (state is ImagePickerLoadedState) {
      currentImages = List.from((state as ImagePickerLoadedState).images);
    }

    // Stop early if the limit is already reached
    if (currentImages.length >= maxImageLimit) {
      emit(ImagePickerErrorState("Solo puedes seleccionar hasta $maxImageLimit imágenes."));
      // Restore the loaded state so images don't disappear from UI
      emit(ImagePickerLoadedState(currentImages.sublist(0, maxImageLimit)));
      return;
    }
    try {
      emit(ImagePickerLoadingState());
      
      final List<XFile> selectedImages = await _picker.pickMultiImage();

      if (selectedImages.isNotEmpty) {
        // Convert XFile list to standard File list
        final List<File> imageFiles = selectedImages.map((xFile) => File(xFile.path)).toList();
        List<File> combinedImages = [...currentImages, ...imageFiles];
        // Enforce the strict maximum limit of 6
        if (combinedImages.length > maxImageLimit) {
          combinedImages = combinedImages.sublist(0, maxImageLimit);
          emit(ImagePickerErrorState("Sólo las primeras $maxImageLimit imágenes fueron añadidas"));
          emit(ImagePickerLoadedState(combinedImages));
        }
        else {
          emit(ImagePickerLoadedState(combinedImages));
        }
      } else {
        // User canceled the picker without selecting anything
        emit(ImagePickerInitialState());
      }
    } catch (e) {
      emit(ImagePickerErrorState("Error al cargar las imágenes: ${e.toString()}"));
    }
  }
  
  Future<void> pickCameraImage() async {
    List<File> currentImages = getCurrentImages();
    if (currentImages.length >= maxImageLimit) return;

    try {
      final XFile? cameraImage = await _picker.pickImage(source: ImageSource.camera);
      if (cameraImage == null) return;

      emit(ImagePickerLoadingState());

      File? compressed = await _compressImage(File(cameraImage.path));
      if (compressed != null) {
        List<File> combinedImages = [...currentImages, compressed];
        emit(ImagePickerLoadedState(combinedImages));
      } else {
        emit(ImagePickerLoadedState(currentImages));
      }
    } catch (e) {
      emit(ImagePickerErrorState("Failed to capture image: ${e.toString()}"));
      if (currentImages.isNotEmpty) emit(ImagePickerLoadedState(currentImages));
    }
  }

  List<File> getCurrentImages() {
    if (state is ImagePickerLoadedState) {
      return List.from((state as ImagePickerLoadedState).images);
    }
    return [];
  }
  int getCurrentImageCount() {
    if (state is ImagePickerLoadedState) {
      return (state as ImagePickerLoadedState).images.length;
    }
    return 0;
  }
  void deleteImage(int index) {
    if (state is ImagePickerLoadedState) {
      final currentImages = List.from((state as ImagePickerLoadedState).images);
      currentImages.removeAt(index);

      if (currentImages.isEmpty) {
        emit(ImagePickerInitialState());
      } else {
        emit(ImagePickerLoadedState(currentImages.cast<File>()));
      }
    }
  }
}
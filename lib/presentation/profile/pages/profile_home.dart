import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/common/widgets/button/basic_reactive_button.dart';
import 'package:paklan/common/widgets/button/custom_reactive_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/domain/auth/usecases/signout.dart';
import 'package:paklan/domain/profile/usecases/upload_profile_picture.dart';
import 'package:paklan/presentation/auth/pages/signin.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/presentation/transactions/bloc/photo_selection_cubit.dart';
import 'package:paklan/presentation/transactions/bloc/photo_selection_state.dart';

class ProfileHome extends StatelessWidget {
  const ProfileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ButtonStateCubit()),
      ],
      child: BlocListener<ButtonStateCubit, ButtonState>(
        listener: (context, state) {
          if (state is ButtonFailureState) {
            var snackbar = SnackBar(
              content: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.white70),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              showCloseIcon: true,
              closeIconColor: Colors.white70,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          } else if (state is ButtonSuccessState) {
            AppNavigator.pushAndRemove(context, SigninPage());
          }
        },
        child: Scaffold(
          appBar: const BasicAppbar(
            height: 80,
            title: Text("Información del perfil"),
          ),
          body: SingleChildScrollView(
            child: BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
              builder: (context, state) {
                if (state is UserInfoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UserInfoLoaded) {
                  UserEntity user = state.user;
                  return Center(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: Card(
                        shadowColor: Colors.amber,
                        elevation: 9,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 1.2,
                                color: const Color.fromARGB(215, 0, 0, 0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: ClipOval(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      height: 100,
                                      width: 100,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: user.photoLink.isEmpty
                                                ? const Image(
                                                    image: AssetImage(AppImages.userLogo),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image(
                                                    image: NetworkImage(user.photoLink),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            bottom: 9,
                                            right: 8,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.camera_alt,
                                                  size: 18,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                    ),
                                                    builder: (modalContext) {
                                                      // 2. Wrap the bottom sheet content in BlocProvider.value
                                                      return MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(create: (context) => ImagePickerCubit(maxImageLimit: 1)),
                                                          BlocProvider(create: (context) => ButtonStateCubit()),
                                                          BlocProvider.value(value: context.read<UserInfoDisplayCubit>(),),
                                                        ],
                                                        
                                                        child: BlocListener<ButtonStateCubit, ButtonState>(
                                                            listener: (context, state) {
                                                              if (state is ButtonFailureState) {
                                                                var snackbar = SnackBar(
                                                                  content: Text(
                                                                    state.errorMessage,
                                                                    style: const TextStyle(color: Colors.white70),
                                                                  ),
                                                                  behavior: SnackBarBehavior.floating,
                                                                  backgroundColor: Colors.black87,
                                                                  showCloseIcon: true,
                                                                  closeIconColor: Colors.white70,
                                                                );
                                                                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                              } else if (state is ButtonSuccessState) {
                                                                Navigator.of(modalContext).pop();
                                                                context.read<UserInfoDisplayCubit>().displayUserInfo();
                                                              }
                                                            },
                                                            child: Container(
                                                            height: 350,
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.all(16.0),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Text(
                                                                  'Subir foto de perfil',
                                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                ),
                                                                const SizedBox(height: 10),
                                                                BlocListener<ImagePickerCubit, ImagePickerState>(
                                                                    listener: (context, state) {
                                                                      if (state is ImagePickerErrorState){
                                                                      showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                          title: const Text("Nota de Información"),
                                                                          content: Text(
                                                                                    state.errorMessage,
                                                                                    textAlign: TextAlign.justify,
                                                                                    style: const TextStyle(fontSize: 15, height: 1.3),
                                                                                  ),
                                                                          actions: [
                                                                            BasicAppButton(
                                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                                      content: const Text("Entendido", 
                                                                                      style: TextStyle(color: AppColors.primary)),
                                                                                        ),
                                                                                      ],
                                                                                        );
                                                                                      },
                                                                                    );
                                                                    }
                                                                    },
                                                                    child: BlocBuilder<ImagePickerCubit, ImagePickerState>(builder: (context, state){
                                                                      if (state is ImagePickerInitialState){
                                                                        return const Text(
                                                                          'No se ha seleccionado ninguna imagen',
                                                                          style: TextStyle(color: Colors.black87),
                                                                        );
                                                                      }
                                                                      List<dynamic> imagesToDisplay = [];
                                                                      if (state is ImagePickerLoadingState){
                                                                        return const CircularProgressIndicator();
                                                                      }
                                                                      if (state is ImagePickerLoadedState){
                                                                      return Center(
                                                                        child: SizedBox(
                                                                          height: 100,
                                                                          child: ListView.builder(
                                                                            shrinkWrap: true,
                                                                            scrollDirection: Axis.horizontal,
                                                                            itemCount: state.images.length,
                                                                            itemBuilder: (context, index) {
                                                                              return SizedBox(
                                                                                width: 100,
                                                                                child: Stack(
                                                                                children: [
                                                                                  Positioned.fill(
                                                                                 child: Image.file(
                                                                                   state.images[index],
                                                                                   fit: BoxFit.cover,
                                                                                 ),
                                                                                ),
                                                                                Positioned(
                                                                                 top: 4,
                                                                                 right: 4,
                                                                                 child: GestureDetector(
                                                                                   onTap: () => context.read<ImagePickerCubit>().deleteImage(index),
                                                                                   child: const CircleAvatar(
                                                                                     radius: 12,
                                                                                     backgroundColor: Colors.black54,
                                                                                     child: Icon(Icons.close, size: 16, color: Colors.white),
                                                                                   ),
                                                                                 ),
                                                                                ),
                                                                              ],
                                                                              ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                      }
                                                                      return Container();
                                                                                                              })
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    BlocBuilder<ImagePickerCubit, ImagePickerState>(
                                                                      builder: (context, state) {
                                                                        return ElevatedButton.icon(
                                                                          style: const ButtonStyle(
                                                                            backgroundColor: WidgetStatePropertyAll<Color>(
                                                                              AppColors.secondBackground,
                                                                            ),
                                                                          ),
                                                                          onPressed: () => context.read<ImagePickerCubit>().pickCameraImage(),
                                                                          icon: const Icon(Icons.camera_alt, color: Colors.black87),
                                                                          label: const Text('Cámara', style: TextStyle(color: Colors.black87)),
                                                                        );
                                                                      },
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    BlocBuilder<ImagePickerCubit, ImagePickerState>(
                                                                      builder: (context, state) {
                                                                        return ElevatedButton.icon(
                                                                          style: const ButtonStyle(
                                                                            backgroundColor: WidgetStatePropertyAll<Color>(
                                                                              AppColors.secondBackground,
                                                                            ),
                                                                          ),
                                                                          onPressed: () => context.read<ImagePickerCubit>().pickSingleGalleryImage(),
                                                                          icon: const Icon(Icons.photo_library, color: Colors.black87),
                                                                          label: const Text('Galería', style: TextStyle(color: Colors.black87)),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 20),
                                                                Builder(
                                                                  builder: (context) {
                                                                    return BasicReactiveButton(
                                                                        onPressed: (){
                                                                          if (context.read<ImagePickerCubit>().state is ImagePickerLoadedState && context.read<ImagePickerCubit>().getCurrentImages().isNotEmpty){
                                                                          context.read<ButtonStateCubit>().execute(
                                                                            usecase: UploadProfilePictureUseCase(),
                                                                            params: context.read<ImagePickerCubit>().getCurrentImages()[0]
                                                                          );
                                                                          }
                                                                        },
                                                                        title: "Subir Foto",
                                                                      );
                                                          
                                                                  }
                                                                ),
                                                                const SizedBox(height: 25),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          toBeginningOfSentenceCase(user.displayName) ?? '',
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Center(
                                        child: Text(
                                          user.email,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Editar datos de perfil',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Builder(
                                    builder: (context) {
                                      return CustomReactiveButton(
                                        onPressed: () async {
                                          await context.read<ButtonStateCubit>().execute(usecase: SignoutUseCase());
                                        },
                                        title: "Cerrar sesión",
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
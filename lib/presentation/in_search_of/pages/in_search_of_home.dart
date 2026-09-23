import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/helper/navigator/app_navigator.dart';
import 'package:paklan/common/helper/stream_provider/app_stream_provider.dart';
import 'package:paklan/common/widgets/appbar/app_bar.dart';
import 'package:paklan/common/widgets/button/basic_app_button.dart';
import 'package:paklan/core/configs/assets/app_images.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/domain/in_search_of/entity/in_search_of.dart';
import 'package:paklan/presentation/in_search_of/bloc/search_iso_posts_cubit.dart';
import 'package:paklan/presentation/in_search_of/bloc/search_iso_posts_state.dart';
import 'package:paklan/presentation/in_search_of/pages/in_search_of_create_post.dart';
import 'package:paklan/presentation/in_search_of/pages/in_search_of_detail.dart';
import 'package:paklan/presentation/in_search_of/widgets/search_field_iso.dart';
import 'package:paklan/presentation/transactions/bloc/status_filter_history_selection_cubit.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;


class InSearchOfHome extends StatefulWidget {
  const InSearchOfHome({super.key});

  @override
  State<InSearchOfHome> createState() => _InSearchOfHomeState();
}

class _InSearchOfHomeState extends State<InSearchOfHome> 
    with AutomaticKeepAliveClientMixin { 
  
  late final MultiSelectController<String> _multicontroller2;

  // ✅ Keep page alive in PageView
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _multicontroller2 = MultiSelectController<String>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final streams = AppStreamsProvider.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => StatusFilterHistorySelectionCubit()),
        BlocProvider(create: (context) => SearchIsoPostsCubit())
      ],
      child: Scaffold(
        appBar: BasicAppbar(
          height: 110,
          title: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.96,
            height: 100,
            child: Column(
              children: [
                Text("Personas en busca de tu producto"),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: SearchFieldIso()),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.28,
                      child: BasicAppButton(
                        onPressed: (){
                          AppNavigator.push(context, InSearchOfCreatePost());
                        },
                        title: "Publicar"
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          hideBack: true,
        ),
        body: BlocBuilder<SearchIsoPostsCubit, SearchIsoPostsState>(
          builder: (context, state) {
            if (state is ISOPostLoading){
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ISOPostLoaded){
              return SingleChildScrollView(
                child: _buildCategoryCarousel(
                  'Productos encontrados',
                  state.posts, 
                  context,
                  streams.currentUserId,
                  onTapSeeMore: () => context.read<SearchIsoPostsCubit>().resetSearch()
                ),
              );
            }
            if (state is ISOPostEmpty){
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "No se encontró el producto que buscabas",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              );
            }
            return BuildIsoPosts(
              isoPostsStream: streams.isoPostsStream, 
              multicontroller2: _multicontroller2, 
              currentUserId: streams.currentUserId
            );
          }
        ),
      )
    );
  }

  Widget _buildCategoryCarousel(
    String categoryTitle, 
    List<InSearchOfEntity> items, 
    BuildContext context,
    String currentUserId,
    {VoidCallback? onTapSeeMore}
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          thickness: 1, 
          height: 24, 
          color: Colors.black26,
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                categoryTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              
              GestureDetector(
                onTap: onTapSeeMore,
                child: Row(
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Ver más',
                        style: TextStyle(
                          color: AppColors.primaryButton,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryButton, 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        listTransactions(context, items, ScrollController(), currentUserId),
      ],
    );
  }
}

class BuildIsoPosts extends StatefulWidget {  // ✅ Change to StatefulWidget
  final Stream<QuerySnapshot<Object?>> isoPostsStream;
  final MultiSelectController<String> multicontroller2;
  final String currentUserId;
  
  const BuildIsoPosts({
    super.key,
    required this.isoPostsStream,
    required this.multicontroller2,
    required this.currentUserId,
  });

  @override
  State<BuildIsoPosts> createState() => _BuildIsoPostsState();
}

class _BuildIsoPostsState extends State<BuildIsoPosts> {
  late final ScrollController _scrollController;  // ✅ Create once
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();  // ✅ Dispose properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.isoPostsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> state) {
        if (!state.hasData && state.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator()
            ),
          );
        }
        
        if (state.hasError) {
          return SizedBox(
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Ha ocurrido un error, por favor intenta más tarde",
                style: TextStyle(fontSize: 24),
              ),
            ),
          );
        }
        
        if (!state.hasData) {
          return SizedBox(
            height: 400,
            child: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator()
            ),
          );
        }
        
        if (state.data!.docs.isEmpty) {
          return listNoDeal(context);
        }
        
        List<InSearchOfEntity> listEntities = state.data!.docs.map(
          (element) => InSearchOfModel.fromMap(element.data() as Map<String, dynamic>).toEntity()
        ).toList();
        
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(13),
                height: 60,
                child: MultiSelectContainer(
                  controller: widget.multicontroller2,
                  itemsDecoration: MultiSelectDecorations(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white30,
                        AppColors.primary,
                      ]),
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color.fromARGB(255, 32, 68, 117).withValues(alpha: 0.8),
                        Colors.white38.withValues(alpha: 0.3),
                      ]),
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(13)
                    ),
                    disabledDecoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.grey[500]!),
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  showInListView: true,
                  listViewSettings: ListViewSettings(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, _) => const SizedBox(width: 10,)
                  ),
                  items: [
                    MultiSelectCard(
                      value: 'Todos', 
                      label: 'Todos', 
                      selected: true,
                      textStyles: MultiSelectItemTextStyles(
                        selectedTextStyle: TextStyle(color: Colors.black87)
                      )
                    ),
                    MultiSelectCard(
                      value: 'Reproducción', 
                      label: 'Reproducción', 
                      selected: false,
                      textStyles: MultiSelectItemTextStyles(
                        selectedTextStyle: TextStyle(color: Colors.black87)
                      )
                    ),
                    MultiSelectCard(
                      value: 'Original', 
                      label: 'Original', 
                      selected: false,
                      textStyles: MultiSelectItemTextStyles(
                        selectedTextStyle: TextStyle(color: Colors.black87)
                      )
                    ),
                  ],
                  onChange: (allSelectedItems, selectedItem) {
                    widget.multicontroller2.select(selectedItem);
                    allSelectedItems = [selectedItem];
                    context.read<StatusFilterHistorySelectionCubit>().selectFilters(allSelectedItems.toSet().toList());
                  }
                ),
              ),
              SizedBox(height: 10),
              BlocBuilder<StatusFilterHistorySelectionCubit, List<String>>(
                builder: (context, state) {
                  if (context.read<StatusFilterHistorySelectionCubit>().selectedFilters.contains("Todos")) {
                    return listTransactions(
                      context, 
                      listEntities, 
                      _scrollController,  // ✅ Reuse same controller
                      widget.currentUserId
                    );
                  }
                  return listTransactions(
                    context, 
                    listEntities.where((element) {
                      return context.read<StatusFilterHistorySelectionCubit>().selectedFilters.contains(element.typeOfProduct);
                    }).toList(),
                    _scrollController,  // ✅ Reuse same controller
                    widget.currentUserId
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }
}


Widget listNoDeal(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        SizedBox(height: 10,),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.4,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            image: DecorationImage(
              image: const AssetImage(AppImages.dealSuccess),
            )
          ),
        ),
        SizedBox(height: 10,),
        Text(
          "Aún no hay artículos que buscan",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87
          ),
        ),
      ]
    ),
  );
}

Widget listTransactions(BuildContext context, List<InSearchOfEntity> status, ScrollController scrollController, String user) {
  return RawScrollbar(
    controller: scrollController,
    thumbColor: Colors.black12,
    timeToFade: const Duration(seconds: 1),
    thickness: 3,
    child: GridView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      controller: scrollController,
      padding: const EdgeInsets.all(9),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, 
      ),
      itemCount: status.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              CupertinoSheetRoute<void>(
                scrollableBuilder: (BuildContext context, ScrollController controller) {
                  WidgetBuilder widgetBuilder = (BuildContext context) => InSearchOfDetail(
                    isoEntity: status[index]
                  );
                  return widgetBuilder(context);
                },
              ),
            );
          },
          child: isoTile(status, index, user, context),
        );
      },
    ),
  );
}

Widget isoTile(List<InSearchOfEntity> status, int index, String user, context) {
  return SizedBox(
    width: MediaQuery.sizeOf(context).width * 0.45,
    height: MediaQuery.sizeOf(context).height * 0.4,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 123, 
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: status[index].imageUrls!.isEmpty
                      ? const Image(
                          image: AssetImage(AppImages.userLogo),
                          fit: BoxFit.cover,
                        )
                      : PageView.builder(
                          itemCount: status[index].imageUrls!.length,
                          controller: PageController(viewportFraction: 1.0),
                          itemBuilder: (context, imageIndex) {
                            return Image(
                              image: NetworkImage(status[index].imageUrls![imageIndex]),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                  ),
                  Positioned(
                    top: 8,
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.secondBackground,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        "Se busca",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  if (status[index].imageUrls!.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.swipe_right_alt,
                          size: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '${toBeginningOfSentenceCase(status[index].name)}',
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      user = '${status[index].buyerDisplayName}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 9,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Recompensa\n \$${status[index].reward! == '????' ? status[index].reward! : 
                      (double.parse(status[index].reward!))
                        .truncateToDouble()
                        .toStringAsFixed(2)
                        .replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ',
                      style: const TextStyle(
                        fontSize: 11, 
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

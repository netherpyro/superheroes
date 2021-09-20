import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final http.Client? client;
  const MainPage({Key? key, this.client}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;


  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: const Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  const MainPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        MainPageStateWidget(),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12),
          child: SearchWidget(),
        ),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();
  bool haveSearchedText = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final mainBloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        mainBloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (haveSearchedText != haveText) {
          setState(() {
            haveSearchedText = haveText;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.white,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        suffix: GestureDetector(
          onTap: () => controller.clear(),
          child: const Icon(Icons.clear, color: Colors.white),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.white54,
          size: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: haveSearchedText
              ? const BorderSide(color: Colors.white24)
              : const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  const MainPageStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainBloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<MainPageState>(
        stream: mainBloc.observeMainPageState(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox();
          }
          final MainPageState state = snapshot.data!;
          switch (state) {
            case MainPageState.loading:
              return const LoadingIndicator();
            case MainPageState.minSymbols:
              return const MinSymbolsWidget();
            case MainPageState.noFavorites:
              return Stack(
                children: [
                  const NoFavoritesWidget(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ActionButton(
                      text: "Remove",
                      onTap: mainBloc.removeFavorite,
                    ),
                  ),
                ],
              );
            case MainPageState.favorites:
              return Stack(
                children: [
                  const NoFavoritesWidget(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SuperheroesList(
                      title: "Your Favorites",
                      stream: mainBloc.observeFavoriteSuperheroes(),
                    ),
                  ),
                ],
              );
            case MainPageState.searchResults:
              return SuperheroesList(
                  title: "Search results",
                  stream: mainBloc.observeSearchedSuperheroes());
            case MainPageState.nothingFound:
              return const NothingFoundWidget();
            case MainPageState.loadingError:
              return const LoadingErrorWidget();
            default:
              return Center(
                  child: Text(
                state.toString(),
                style: const TextStyle(color: Colors.white),
              ));
          }
        });
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
          padding: EdgeInsets.only(top: 110),
          child: Text(
            "Enter at least 3 symbols",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          )),
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  const NoFavoritesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "No favorites yet",
        subtitle: "Search and add",
        buttonText: "Search",
        assetImage: SuperheroesImages.ironman,
        imageHeight: 119,
        imageWidth: 108,
        imageTopPadding: 9,
      ),
    );
  }
}

class NothingFoundWidget extends StatelessWidget {
  const NothingFoundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "Nothing found",
        subtitle: "Search for something else",
        buttonText: "Search",
        assetImage: SuperheroesImages.hulk,
        imageHeight: 112,
        imageWidth: 84,
        imageTopPadding: 16,
      ),
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  const LoadingErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "Error happened",
        subtitle: "Please, try again",
        buttonText: "Retry",
        assetImage: SuperheroesImages.superman,
        imageHeight: 106,
        imageWidth: 126,
        imageTopPadding: 22,
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
          padding: EdgeInsets.only(top: 110),
          child: CircularProgressIndicator(
            color: SuperheroesColors.blue,
            strokeWidth: 4,
          )),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          List<SuperheroInfo> list = snapshot.data!;
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: list.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 90, bottom: 12),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                );
              }
              final SuperheroInfo item = list[index - 1];
              return SuperheroCard(
                info: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SuperheroPage(name: "Venom"),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
          );
        });
  }
}

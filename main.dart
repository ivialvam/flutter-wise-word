import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Aplikasiku",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    history.add(current);
    notifyListeners();
  }

  var favorites = <WordPair>[];
  var history = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritePage();
        break;
      case 2:
        page = const HistoryPage();
        break;
      default:
        page = const Placeholder();
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favorite',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
        ],
      ),
      body: page,
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("My Py App"),
          BigCard(pair: pair),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();

                  // Snackbar
                  ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('Fav/UnFav word ${appState.current}'),
                    ),
                  );
                },
                icon: Icon(icon),
                label: const Text("Favorite"),
              ),
              const SizedBox(width: 25),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text("Click here"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pairTextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 36.0,
    );

    return Card(
      color: Color.fromARGB(255, 234, 180, 255),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(pair.asLowerCase, style: pairTextStyle),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorite words yet.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return ListView(
      children: [
        Text(
          'You have ${appState.favorites.length} favorite words:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...appState.favorites.map(
          (wp) => ListTile(
            title: Text(wp.asCamelCase),
            onTap: () {
              appState.removeFavorite(wp);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Removed ${wp.asCamelCase} from favorites!'),
                  ),
                );
            },
          ),
        ),
      ],
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.history.isEmpty) {
      return Center(
        child: Text(
          'No words generated yet.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Generated words history:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ElevatedButton(
          onPressed: () {
            appState.clearHistory();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('History cleared!'),
                ),
              );
          },
          child: Text('Clear History'),
        ),
        Expanded(
          child: ListView(
            children: [
              ...appState.history.map(
                (wp) => ListTile(
                  title: Text(wp.asCamelCase),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("It's ${wp.asCamelCase}!"),
                        ),
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

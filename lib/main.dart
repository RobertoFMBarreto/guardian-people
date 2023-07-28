import 'package:august_testing/widgets/sliver_at_app_bar.dart';
import 'package:flutter/material.dart';
import 'widgets/path/top_bar_wave_clipper.dart';
import 'colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'August Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: atTextColor),
          bodyMedium: TextStyle(color: atTextColor),
          bodySmall: TextStyle(color: atTextColor),
          headlineLarge: TextStyle(color: atTextColor),
          headlineMedium: TextStyle(color: atTextColor, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: atTextColor),
          labelLarge: TextStyle(color: atTextColor),
          labelMedium: TextStyle(color: atTextColor),
          labelSmall: TextStyle(color: atTextColor),
        ),
        scaffoldBackgroundColor: atBackgroundColor,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: atSecondaryColor,
          selectionHandleColor: atSecondaryColor,
          selectionColor: atSecondaryColor,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: atPrimaryColor,
          onPrimary: atOnPrimaryColor,
          secondary: atSecondaryColor,
          onSecondary: atOnSecondaryColor,
          error: atErrorColor,
          onError: atOnErrorColor,
          background: atBackgroundColor,
          onBackground: atOnBackgroundColor,
          surface: atBackgroundColor,
          onSurface: atOnBackgroundColor,
        ),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: atBackgroundColor),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: SliverATAppBar(),
              // Set this param so that it won't go off the screen when scrolling
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Cruelty-free brand',
                      style: TextStyle(fontSize: 20),
                    ));
              }, childCount: 20),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Adicionar Produtor',
        backgroundColor: theme.colorScheme.secondary,
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

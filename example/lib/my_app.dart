import 'package:flutter/material.dart';
import 'package:lazy_indexed_stack_plus/lazy_indexed_stack_plus.dart';

/// {@template my_app}
/// A [StatelessWidget] that utilizes the
/// [lazy_indexed_stack_plus](https://pub.dev/packages/lazy_indexed_stack_plus)
/// package to manage lazy loading and preloading via [LazyIndexedStackPlus].
/// {@endtemplate}
class MyApp extends StatelessWidget {
  /// {@macro my_app}
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DashboardPage(),
    );
  }
}

/// {@template dashboard_page}
/// A [StatefulWidget] that demonstrates how to consume and interact with
/// [LazyIndexedStackPlus]
/// {@endtemplate}
class DashboardPage extends StatefulWidget {
  /// {@macro dashboard_page}
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  void _onDestinationSelected(int index) =>
      setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      // LazyIndexedStackPlus allows for lazy loading of its children.
      // It only builds a child when it's indexed to be displayed.
      body: LazyIndexedStackPlus(
        // A placeholder widget to show while a child is being built for the first time.
        placeholder: const CircularProgressIndicator(),
        // A set of indexes to preload. These children will be built in the background.
        preloadIndexes: const {2},
        // The index of the child to show.
        index: currentIndex,
        // The list of widgets to display.
        children: const [HomePage(), ProfilePage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// {@template home_page}
/// A [StatelessWidget] that displays a [Text] widget.
/// {@endtemplate}
class HomePage extends StatelessWidget {
  /// {@macro home_page}
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const Center(child: Text('Home Page')));
  }
}

/// {@template profile_page}
/// A [StatelessWidget] that displays a [Text] widget.
/// {@endtemplate}
class ProfilePage extends StatelessWidget {
  /// {@macro profile_page}
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const Center(child: Text('Profile Page')));
  }
}

/// {@template settings_page}
/// A [StatelessWidget] that displays a [Text] widget.
/// {@endtemplate}
class SettingsPage extends StatelessWidget {
  /// {@macro settings_page}
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const Center(child: Text('Settings Page')));
  }
}

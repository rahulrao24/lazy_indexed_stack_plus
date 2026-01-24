import 'package:example/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_indexed_stack_plus/lazy_indexed_stack_plus.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders a MaterialApp (MyApp) with a DashboardPage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });

  group('DashboardPage', () {
    const title = 'Example';
    const homePageContent = 'Home Page';
    const profilePageContent = 'Profile Page';
    const settingsPageContent = 'Settings Page';

    testWidgets(
      'renders LazyIndexedStackPlus with default index and preloadIndexes',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.byType(LazyIndexedStackPlus), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(ProfilePage, skipOffstage: false), findsNothing);
        expect(find.byType(SettingsPage, skipOffstage: false), findsOneWidget);
        expect(find.text(homePageContent), findsOneWidget);
        expect(
          find.text(profilePageContent, skipOffstage: false),
          findsNothing,
        );
        expect(
          find.text(settingsPageContent, skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders ProfilePage when index changed to one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage, skipOffstage: false), findsOneWidget);
      expect(find.byType(ProfilePage, skipOffstage: false), findsOneWidget);
      expect(find.byType(SettingsPage, skipOffstage: false), findsOneWidget);
      expect(find.text(homePageContent, skipOffstage: false), findsOneWidget);
      expect(
        find.text(profilePageContent, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(settingsPageContent, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  group('HomePage', () {
    testWidgets('renders HomePage with a Center widget and a Text widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('ProfilePage', () {
    testWidgets('renders ProfilePage with a Center widget and a Text widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Profile Page'), findsOneWidget);
    });
  });

  group('SettingsPage', () {
    testWidgets('renders SettingsPage with a Center widget and a Text widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });
}

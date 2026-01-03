<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

The ultimate enhanced IndexedStack with lazy loading, preloading, and state preservation made easy for optimized Flutter apps.

## Features

- 🚀 **Lazy Loading:** Children are only built when they first become active.
- ⚡ **Preloading:** Specify indexes to load in the background before the user navigates to them.
- 💾 **State Preservation:** Keeps the state of children alive (scroll position, text inputs, etc.) once loaded.
- 🛠️ **Custom Placeholders:** Show a custom widget (like a loader) for uninitialized tabs.
- 🔄 **Placeholder Sync:** Automatically updates placeholders across all tabs if the placeholder widget changes.

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  lazy_indexed_stack_plus: ^0.0.1
```

## Usage


```dart
LazyIndexedStackPlus(
  index: 0,
  preloadIndexes: {1}, // Optional: Preload specific tabs
  placeholder: Center(child: CircularProgressIndicator()),
  children: [
    HomeTab(),
    ProfileTab(),
    SettingsTab(),
  ],
);
```

[//]: # (## Additional information)

[//]: # ()
[//]: # (TODO: Tell users more about the package: where to find more information, how to)

[//]: # (contribute to the package, how to file issues, what response they can expect)

[//]: # (from the package authors, and more.)

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
  lazy_indexed_stack_plus: ^0.0.2
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

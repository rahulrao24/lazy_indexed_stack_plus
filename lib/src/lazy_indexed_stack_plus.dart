import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:flutter/widgets.dart';

/// {@template lazy_indexed_stack_plus}
/// A widget that behaves like [IndexedStack] but loads its children lazily.
///
/// Unlike a standard [IndexedStack], which inflates all children immediately,
/// [LazyIndexedStackPlus] only builds a child when it first becomes active
/// (the [index] matches) or if it is included in [preloadIndexes].
///
/// Once a child has been built, it is kept in the widget tree to maintain
/// its state (e.g., scroll position, text input).
///
///
/// This sample shows the usage of [LazyIndexedStackPlus]
///
/// ```dart
/// LazyIndexedStackPlus(
///   index: 0,
///   preloadIndexes: {1}, // Optional: Preload specific tabs /indexes
///   placeholder: Center(child: CircularProgressIndicator()),
///   children: [
///     HomeTab(),
///     ProfileTab(),
///     SettingsTab(),
///   ],
/// );
/// ```
///
/// See also:
///
/// * [IndexedStack], for more details about the widget.
/// * [Stack], for more details about the widget.
/// * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
/// {@endtemplate}
class LazyIndexedStackPlus extends StatefulWidget {
  /// {@macro lazy_indexed_stack_plus}
  const LazyIndexedStackPlus({
    super.key,
    this.index = 0,
    this.alignment = AlignmentDirectional.topStart,
    this.sizing = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.textDirection,
    this.placeholder = const SizedBox.shrink(),
    this.preloadIndexes = const <int>{},
    this.children = const <Widget>[],
  });

  /// {@template lazy_indexed_stack_plus.index}
  /// The index of the child to show.
  ///
  /// When this value changes, the child at the new index will be built
  /// if it hasn't been built already.
  ///
  /// Defaults to 0
  /// {@endtemplate}
  final int index;

  /// {@template lazy_indexed_stack_plus.alignment}
  /// How to align the children in the stack.
  ///
  /// Defaults to [AlignmentDirectional.topStart].
  ///
  /// See [Stack.alignment] for more information.
  /// {@endtemplate}
  final AlignmentGeometry alignment;

  /// {@template lazy_indexed_stack_plus.sizing}
  /// How to size the non-positioned children in the stack.
  ///
  /// Defaults to [StackFit.loose].
  ///
  /// See [Stack.fit] for more information.
  /// {@endtemplate}
  final StackFit sizing;

  /// {@template lazy_indexed_stack_plus.clip}
  /// Whether to clip the overflow of children.
  ///
  /// Defaults to [Clip.hardEdge].
  /// {@endtemplate}
  final Clip clipBehavior;

  /// {@template lazy_indexed_stack_plus.textDirection}
  /// The text direction with which to resolve [alignment].
  ///
  /// Defaults to the ambient [Directionality].
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template lazy_indexed_stack_plus.placeholder}
  /// The widget to display for children that have not been initialized yet.
  ///
  /// Defaults to [SizedBox.shrink].
  /// {@endtemplate}
  final Widget placeholder;

  /// {@template lazy_indexed_stack_plus.indexes}
  /// A set of indexes that should be built immediately, even if they are
  /// not the current [index].
  ///
  /// This is useful for pre-fetching data or warming up heavy UI components
  /// before the user navigates to them.
  /// {@endtemplate}
  final Set<int> preloadIndexes;

  /// {@template lazy_indexed_stack_plus.children}
  /// The list of widgets to be displayed in the stack.
  ///
  /// Children are built lazily; they are replaced by [placeholder] until
  /// they are activated by [index] or [preloadIndexes].
  ///
  /// See [Stack.children] for more information.
  /// {@endtemplate}
  final List<Widget> children;

  @override
  State<LazyIndexedStackPlus> createState() => _LazyIndexedStackPlusState();
}

class _LazyIndexedStackPlusState extends State<LazyIndexedStackPlus> {
  final Set<int> _builtIndexes = <int>{};
  late List<Widget> _cachedChildren;

  @override
  void initState() {
    super.initState();
    _updateBuiltIndexes();
    _cachedChildren = _updateCacheChildren();
  }

  @override
  void dispose() {
    _builtIndexes.clear();
    _cachedChildren = [];
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStackPlus oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool indexChanged = widget.index != oldWidget.index;
    final bool preloadChanged = !setEquals(
      widget.preloadIndexes,
      oldWidget.preloadIndexes,
    );
    final bool childrenChanged = !listEquals(
      widget.children,
      oldWidget.children,
    );
    final bool placeholderChanged = widget.placeholder != oldWidget.placeholder;

    if (childrenChanged) {
      if (widget.children.length < oldWidget.children.length) {
        _builtIndexes.removeWhere((i) => i >= widget.children.length);
      }

      _updateBuiltIndexes();
      _cachedChildren = _updateCacheChildren();
    } else if (indexChanged || preloadChanged || placeholderChanged) {
      final bool newIndexVisited = !_builtIndexes.contains(widget.index);

      if (newIndexVisited || preloadChanged || placeholderChanged) {
        _updateBuiltIndexes();
        _updateCacheAtNeededIndexes(forcePlaceholderUpdate: placeholderChanged);
      }
    }
  }

  void _updateBuiltIndexes() {
    if (widget.index >= 0 && widget.index < widget.children.length) {
      _builtIndexes.add(widget.index);
    }
    if (widget.preloadIndexes.isNotEmpty) {
      final sanitizedPreloadIndexes = widget.preloadIndexes.where(
        (i) => i >= 0 && i < widget.children.length,
      );
      _builtIndexes.addAll(sanitizedPreloadIndexes);
    }
  }

  void _updateCacheAtNeededIndexes({required bool forcePlaceholderUpdate}) {
    final List<Widget> newCachedChildren = List<Widget>.of(
      _cachedChildren,
      growable: false,
    );
    bool hasChanges = false;

    for (final int index in _builtIndexes) {
      if (index < newCachedChildren.length &&
          newCachedChildren[index] == widget.placeholder) {
        newCachedChildren[index] = widget.children[index];
        hasChanges = true;
      }
    }

    if (forcePlaceholderUpdate) {
      for (int i = 0; i < newCachedChildren.length; i++) {
        if (!_builtIndexes.contains(i)) {
          newCachedChildren[i] = widget.placeholder;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      _cachedChildren = newCachedChildren;
    }
  }

  List<Widget> _updateCacheChildren() {
    return List<Widget>.generate(
      widget.children.length,
      (i) =>
          _builtIndexes.contains(i) ? widget.children[i] : widget.placeholder,
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      sizing: widget.sizing,
      clipBehavior: widget.clipBehavior,
      textDirection: widget.textDirection,
      children: _cachedChildren,
    );
  }
}

import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:flutter/widgets.dart';

class LazyIndexedStackPlus extends StatefulWidget {
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

  final int index;
  final AlignmentGeometry alignment;
  final StackFit sizing;
  final Clip clipBehavior;
  final TextDirection? textDirection;
  final Widget placeholder;
  final Set<int> preloadIndexes;
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

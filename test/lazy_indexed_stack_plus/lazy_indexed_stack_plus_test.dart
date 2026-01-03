import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_indexed_stack_plus/lazy_indexed_stack_plus.dart';

void main() {
  setUp(() {
    _LazyIndexChildState.initCounts.clear();
  });

  group('LazyIndexedStackPlus Tests', () {
    Future<void> buildWidget({
      required WidgetTester tester,
      int index = 0,
      Set<int> preloadIndexes = const <int>{},
      Widget placeholder = const SizedBox.shrink(),
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LazyIndexedStackPlus(
            index: index,
            preloadIndexes: preloadIndexes,
            placeholder: placeholder,
            children: [
              const LazyIndexChild(key: ValueKey('A'), name: 'A'),
              const LazyIndexChild(key: ValueKey('B'), name: 'B'),
              const LazyIndexChild(key: ValueKey('C'), name: 'C'),
            ],
          ),
        ),
      );
    }

    group('index property behaviour', () {
      testWidgets('only builds the initial index child (default)', (
        tester,
      ) async {
        await buildWidget(tester: tester);

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsNothing);
        expect(find.text('Child C', skipOffstage: false), findsNothing);

        expect(
          _LazyIndexChildState.initCounts['A'],
          1,
          reason: 'Child A should be built once as default index value is 0',
        );
        expect(_LazyIndexChildState.initCounts['B'], isNull);
        expect(_LazyIndexChildState.initCounts['C'], isNull);
      });

      testWidgets(
        'only builds the initial index child with with default index 1',
        (tester) async {
          await buildWidget(tester: tester, index: 1);

          expect(find.text('Child A', skipOffstage: false), findsNothing);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(find.text('Child C', skipOffstage: false), findsNothing);

          expect(_LazyIndexChildState.initCounts['A'], isNull);
          expect(
            _LazyIndexChildState.initCounts['B'],
            1,
            reason: 'Child B should be built once as default index value is 1',
          );
          expect(_LazyIndexChildState.initCounts['C'], isNull);
        },
      );

      testWidgets('lazily builds second child when index changes', (
        tester,
      ) async {
        // Start at index 0
        await buildWidget(tester: tester);

        // Switch to index 1
        await buildWidget(tester: tester, index: 1);

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsOneWidget);
        expect(find.text('Child C', skipOffstage: false), findsNothing);

        expect(
          _LazyIndexChildState.initCounts['A'],
          1,
          reason: 'Child A was already built once',
        );
        expect(
          _LazyIndexChildState.initCounts['B'],
          1,
          reason: 'Child B should be built once as current index value is 1',
        );
        expect(_LazyIndexChildState.initCounts['C'], isNull);
      });

      testWidgets(
        'does not re-initialize already built children when returning',
        (tester) async {
          await buildWidget(tester: tester);

          // Move to B, then back to A
          await buildWidget(tester: tester, index: 1);
          await buildWidget(tester: tester, index: 0);

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(find.text('Child C', skipOffstage: false), findsNothing);

          // A should still only have 1 init count, not 2
          expect(
            _LazyIndexChildState.initCounts['A'],
            1,
            reason: 'Child A was already built once',
          );
          expect(
            _LazyIndexChildState.initCounts['B'],
            1,
            reason: 'Child B was built once while moving from A to B',
          );
          expect(_LazyIndexChildState.initCounts['C'], isNull);
        },
      );
    });

    group('preload indexes property', () {
      testWidgets('initializes children specified in preloadIndexes', (
        tester,
      ) async {
        await buildWidget(tester: tester, preloadIndexes: const {2});

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsNothing);
        expect(find.text('Child C', skipOffstage: false), findsOneWidget);

        expect(
          _LazyIndexChildState.initCounts['A'],
          1,
          reason: 'Child A should be build once as default index is zero',
        );
        expect(_LazyIndexChildState.initCounts['B'], isNull);
        expect(
          _LazyIndexChildState.initCounts['C'],
          1,
          reason: 'Child C should be build once as index is preloaded',
        );
      });

      testWidgets(
        'should not double-initialize when a child is both the current index and in preloadIndexes',
        (tester) async {
          await buildWidget(tester: tester, preloadIndexes: const {0, 2});

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsNothing);
          expect(find.text('Child C', skipOffstage: false), findsOneWidget);

          expect(
            _LazyIndexChildState.initCounts['A'],
            1,
            reason: 'Child A should be build once as default index is zero',
          );
          expect(_LazyIndexChildState.initCounts['B'], isNull);
          expect(
            _LazyIndexChildState.initCounts['C'],
            1,
            reason: 'Child C should be build once as index is preloaded',
          );
        },
      );

      testWidgets('dynamically changing preloadIndexes builds new children', (
        tester,
      ) async {
        await buildWidget(tester: tester);

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsNothing);
        expect(find.text('Child C', skipOffstage: false), findsNothing);
        expect(
          _LazyIndexChildState.initCounts['A'],
          1,
          reason: 'Child A should be build once as default index is zero',
        );
        expect(_LazyIndexChildState.initCounts['B'], isNull);
        expect(_LazyIndexChildState.initCounts['C'], isNull);

        await buildWidget(tester: tester, preloadIndexes: const {1});

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsOneWidget);
        expect(find.text('Child C', skipOffstage: false), findsNothing);
        expect(
          _LazyIndexChildState.initCounts['A'],
          1,
          reason: 'Child A should be build once as default index is zero',
        );
        expect(
          _LazyIndexChildState.initCounts['B'],
          1,
          reason: 'Child B should be build once as index is preloaded',
        );
        expect(_LazyIndexChildState.initCounts['C'], isNull);
      });

      testWidgets('decrementing the preload', (tester) async {
        await buildWidget(tester: tester, preloadIndexes: const {0, 1, 2});

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsOneWidget);
        expect(find.text('Child C', skipOffstage: false), findsOneWidget);

        await buildWidget(tester: tester, preloadIndexes: const {0});

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsOneWidget);
        expect(find.text('Child C', skipOffstage: false), findsOneWidget);
      });
    });

    group('placeholder property', () {
      testWidgets('shows placeholder for non-built indexes', (tester) async {
        await buildWidget(
          tester: tester,
          placeholder: const SizedBox.shrink(key: Key('placeholder')),
        );

        expect(find.text('Child A', skipOffstage: false), findsOneWidget);
        expect(find.text('Child B', skipOffstage: false), findsNothing);
        expect(find.text('Child C', skipOffstage: false), findsNothing);

        final indexedStack = tester.widget<IndexedStack>(
          find.byType(IndexedStack),
        );
        expect(indexedStack.children[1], isA<SizedBox>());
      });

      testWidgets('changing placeholder updates unbuilt children', (
        tester,
      ) async {
        await buildWidget(
          tester: tester,
          placeholder: const SizedBox.shrink(key: Key('placeholder')),
        );

        var indexedStack = tester.widget<IndexedStack>(
          find.byType(IndexedStack),
        );
        expect(indexedStack.children[1], isA<SizedBox>());

        await buildWidget(
          tester: tester,
          placeholder: const Text('Custom Placeholder'),
        );

        indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
        expect((indexedStack.children[1] as Text).data, 'Custom Placeholder');
      });
    });

    group('lazy indexed stack plus properties', () {
      testWidgets(
        'should respect Stack properties (alignment, clipBehavior) default',
        (tester) async {
          await buildWidget(tester: tester);

          final IndexedStack indexedStack = tester.widget(
            find.byType(IndexedStack),
          );
          expect(indexedStack.alignment, AlignmentDirectional.topStart);
          expect(indexedStack.clipBehavior, Clip.hardEdge);
        },
      );
    });

    group('edge cases', () {
      testWidgets(
        'should prune built indexes and cache when children count decreases',
        (tester) async {
          await buildWidget(tester: tester, preloadIndexes: const {1, 2});

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(find.text('Child C', skipOffstage: false), findsOneWidget);
          expect(_LazyIndexChildState.initCounts.length, 3);

          await tester.pumpWidget(
            const MaterialApp(
              home: LazyIndexedStackPlus(
                index: 0,
                children: [LazyIndexChild(name: 'A')],
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          final indexedStack = tester.widget<IndexedStack>(
            find.byType(IndexedStack),
          );
          expect(
            indexedStack.children.length,
            1,
            reason: 'The underlying stack should now only have 1 child',
          );
          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsNothing);
          expect(find.text('Child C', skipOffstage: false), findsNothing);
        },
      );

      testWidgets(
        'should maintain state of existing children when a new child is inserted in the middle',
        (tester) async {
          // Initial State: Two children [A, B]
          await tester.pumpWidget(
            const MaterialApp(
              home: LazyIndexedStackPlus(
                index: 0,
                children: [
                  LazyIndexChild(key: ValueKey('A'), name: 'A'),
                  LazyIndexChild(key: ValueKey('B'), name: 'B'),
                ],
              ),
            ),
          );

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsNothing);

          // Initialize B by visiting it
          await tester.pumpWidget(
            const MaterialApp(
              home: LazyIndexedStackPlus(
                index: 1,
                children: [
                  LazyIndexChild(key: ValueKey('A'), name: 'A'),
                  LazyIndexChild(key: ValueKey('B'), name: 'B'),
                ],
              ),
            ),
          );

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(_LazyIndexChildState.initCounts['A'], 1);
          expect(_LazyIndexChildState.initCounts['B'], 1);

          // Insert Child 'NEW' into the middle: [A, NEW, B]
          // Index of B changes from 1 to 2.
          await tester.pumpWidget(
            const MaterialApp(
              home: LazyIndexedStackPlus(
                index: 2, // Still pointing at 'B'
                children: [
                  LazyIndexChild(key: ValueKey('A'), name: 'A'),
                  LazyIndexChild(key: ValueKey('NEW'), name: 'NEW'),
                  LazyIndexChild(key: ValueKey('B'), name: 'B'),
                ],
              ),
            ),
          );

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child NEW', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(
            _LazyIndexChildState.initCounts['A'],
            1,
            reason: 'A should not re-init',
          );
          expect(
            _LazyIndexChildState.initCounts['NEW'],
            1,
            reason:
                'NEW was inserted to existing index, so should be initialized',
          );
          expect(
            _LazyIndexChildState.initCounts['B'],
            2,
            reason: 'B should would re-init as index changed (force changed)',
          );

          // Move to the new middle child
          await tester.pumpWidget(
            const MaterialApp(
              home: LazyIndexedStackPlus(
                index: 1,
                children: [
                  LazyIndexChild(key: ValueKey('A'), name: 'A'),
                  LazyIndexChild(key: ValueKey('NEW'), name: 'NEW'),
                  LazyIndexChild(key: ValueKey('B'), name: 'B'),
                ],
              ),
            ),
          );

          expect(find.text('Child A', skipOffstage: false), findsOneWidget);
          expect(find.text('Child NEW', skipOffstage: false), findsOneWidget);
          expect(find.text('Child B', skipOffstage: false), findsOneWidget);
          expect(_LazyIndexChildState.initCounts['NEW'], 1);
        },
      );
    });
  });
}

class LazyIndexChild extends StatefulWidget {
  const LazyIndexChild({super.key, required this.name});

  final String name;

  @override
  State<LazyIndexChild> createState() => _LazyIndexChildState();
}

class _LazyIndexChildState extends State<LazyIndexChild> {
  static final Map<String, int> initCounts = {};

  @override
  void initState() {
    super.initState();
    initCounts[widget.name] = (initCounts[widget.name] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Text('Child ${widget.name}');
  }
}

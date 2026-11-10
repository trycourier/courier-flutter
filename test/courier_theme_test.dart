import 'package:courier_flutter/ui/courier_background.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _context(WidgetTester tester, ThemeData theme) async {
  late BuildContext context;
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    home: Builder(builder: (c) {
      context = c;
      return const SizedBox();
    }),
  ));
  return context;
}

void main() {
  group('Accent color', () {
    test('a light theme keeps primaryColor', () {
      final theme = ThemeData();
      expect(theme.courierAccentColor, theme.primaryColor);
    });

    test('a dark theme that sets no primaryColor uses colorScheme.primary', () {
      final theme = ThemeData(brightness: Brightness.dark);
      expect(theme.primaryColor, theme.colorScheme.surface);
      expect(theme.courierAccentColor, theme.colorScheme.primary);
    });

    test('a primaryColor the app sets is kept', () {
      final theme = ThemeData(brightness: Brightness.dark, primaryColor: Colors.pink);
      expect(theme.courierAccentColor, Colors.pink);
    });
  });

  group('Partial text styles', () {
    testWidgets('an inbox title with only a color keeps the default size and weight', (tester) async {
      final context = await _context(tester, ThemeData());
      final defaults = Theme.of(context).textTheme.titleMedium!;
      final theme = CourierInboxTheme(titleStyle: const CourierInboxTextStyle(unread: TextStyle(color: Colors.red)));

      final style = theme.getTitleStyle(context, false)!;
      expect(style.color, Colors.red);
      expect(style.fontSize, defaults.fontSize);
      expect(style.fontWeight, defaults.fontWeight);

      // The read state wasn't set, so it is the default
      expect(theme.getTitleStyle(context, true), defaults);
    });

    testWidgets('a selected tab badge font with only a size keeps white text', (tester) async {
      final context = await _context(tester, ThemeData());
      final theme = CourierInboxTheme(
        tabStyle: const CourierInboxTabStyle(
          selected: CourierInboxTabItemStyle(indicator: CourierInboxTabIndicatorStyle(font: TextStyle(fontSize: 10))),
        ),
      );
      final style = theme.getSelectedIndicatorTabTextStyle(context)!;
      expect(style.color, Colors.white);
      expect(style.fontSize, 10);
    });

    testWidgets('a preferences section title with only a color keeps the default size', (tester) async {
      final context = await _context(tester, ThemeData());
      final theme = CourierPreferencesTheme(sectionTitleStyle: const TextStyle(color: Colors.red));
      final style = theme.getSectionTitleStyle(context)!;
      expect(style.color, Colors.red);
      expect(style.fontSize, Theme.of(context).textTheme.titleLarge!.fontSize);
    });
  });

  group('Background color', () {
    const background = Color(0xFF0C111D);

    test('a dark background in a light theme makes the default text white', () {
      final theme = courierThemeForBackground(ThemeData(), background);
      expect(theme.scaffoldBackgroundColor, background);
      expect(theme.canvasColor, background);
      expect(theme.bottomSheetTheme.backgroundColor, background);
      expect(theme.textTheme.titleMedium!.color, Colors.white);
      expect(theme.textTheme.bodyMedium!.color, Colors.white);
      expect(theme.colorScheme.onSurface, Colors.white);
      expect(theme.iconTheme.color, Colors.white);
    });

    test('a dark background in a dark theme keeps the theme text colors', () {
      final base = ThemeData(brightness: Brightness.dark);
      final theme = courierThemeForBackground(base, background);
      expect(theme.scaffoldBackgroundColor, background);
      expect(theme.textTheme.bodyMedium!.color, base.textTheme.bodyMedium!.color);
    });

    test('a light background in a dark theme makes the default text black', () {
      final theme = courierThemeForBackground(ThemeData(brightness: Brightness.dark), Colors.white);
      expect(theme.textTheme.bodyMedium!.color, Colors.black);
      // The dark theme's default accent is resolved before the switch, so it stays visible
      expect(theme.courierAccentColor, ThemeData(brightness: Brightness.dark).colorScheme.primary);
    });

    testWidgets('CourierBackground paints the color and themes its child', (tester) async {
      late BuildContext inner;
      await tester.pumpWidget(MaterialApp(
        home: CourierBackground(
          color: background,
          child: Builder(builder: (c) {
            inner = c;
            return const SizedBox();
          }),
        ),
      ));
      expect(find.byWidgetPredicate((w) => w is ColoredBox && w.color == background), findsOneWidget);
      expect(Theme.of(inner).scaffoldBackgroundColor, background);
    });

    testWidgets('no color leaves the child alone', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CourierBackground(color: null, child: SizedBox())));
      expect(find.descendant(of: find.byType(CourierBackground), matching: find.byType(ColoredBox)), findsNothing);
    });
  });

  group('Cell style', () {
    test('separator insets rebuild the default divider', () {
      final theme = CourierInboxTheme(
        cellStyle: const CourierCellStyle(separatorInsets: EdgeInsets.only(left: 72, right: 8)),
      );
      final separator = theme.getSeparator() as Divider;
      expect(separator.indent, 72);
      expect(separator.endIndent, 8);
    });

    test('a custom separator is kept', () {
      const custom = SizedBox(height: 4);
      final theme = CourierInboxTheme(
        separator: custom,
        cellStyle: const CourierCellStyle(separatorInsets: EdgeInsets.only(left: 72)),
      );
      expect(theme.getSeparator(), custom);
    });

    testWidgets('separator color applies to the divider', (tester) async {
      final theme = CourierInboxTheme(cellStyle: const CourierCellStyle(separatorColor: Colors.red));
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: theme.getSeparator()!)));
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(DividerTheme.of(tester.element(find.byWidget(divider))).color, Colors.red);
    });

    test('no separator stays none', () {
      expect(CourierInboxTheme(separator: null).getSeparator(), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:surgeahead_data_input_tool/main.dart';

void main() {
  testWidgets('MyApp should render with correct theme settings', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    
    expect(app.title, 'Input App');
    expect(app.debugShowCheckedModeBanner, false);

    final ThemeData theme = app.theme!;
    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, Colors.grey[50]);
    expect(theme.scaffoldBackgroundColor, Colors.grey[50]);

    final TextTheme textTheme = theme.textTheme;
    expect(textTheme.displayMedium?.fontSize, 32.0);
    expect(textTheme.displayMedium?.fontWeight, FontWeight.w300);
    expect(textTheme.bodyMedium?.fontSize, 16.0);
    expect(textTheme.bodyMedium?.height, 1.5);

    final AppBarTheme appBarTheme = theme.appBarTheme;
    expect(appBarTheme.backgroundColor, Colors.grey[50]);
    expect(appBarTheme.elevation, 0);
    expect(appBarTheme.titleTextStyle?.fontSize, 20.0);
    expect(appBarTheme.titleTextStyle?.fontWeight, FontWeight.w500);

    final CardTheme cardTheme = theme.cardTheme;
    expect(cardTheme.elevation, 2);

    final DividerThemeData dividerTheme = theme.dividerTheme;
    expect(dividerTheme.thickness, 1);
  });
}
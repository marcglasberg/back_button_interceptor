import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main_complex_example.dart';

void main() {
  testWidgets('Tests intercepting the back-button.', (WidgetTester tester) async {
    //
    // Pump Main to set up routes and show Home.
    await tester.pumpWidget(AnotherExample());

    // Tap 'Open new screen' button to open NewScreen.
    Finder homeButtonFinder = find.widgetWithText(RaisedButton, 'Open new screen');
    expect(homeButtonFinder, isNotNull);

    await tester.tap(homeButtonFinder);
    await tester.pumpAndSettle();

    // ---

    Finder newScreenButtonFinder = find.widgetWithText(RaisedButton, 'Pop');
    expect(newScreenButtonFinder, isNotNull);

    // Tap #1 --------------
    await tester.tap(newScreenButtonFinder);
    await tester.pump();

    InterceptorResults interceptorResults = BackButtonInterceptor.results;
    expect(interceptorResults.count, 1);
    expect(interceptorResults.ifDefaultButtonEventWasFired, false);

    expect(interceptorResults.getNamed('first').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('second').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('third').stopDefaultButtonEvent, true);

    // Tap #2 --------------
    await tester.tap(newScreenButtonFinder);
    await tester.pump();

    expect(interceptorResults.count, 2);
    expect(interceptorResults.ifDefaultButtonEventWasFired, false);

    expect(interceptorResults.getNamed('first').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('second').stopDefaultButtonEvent, true);
    expect(interceptorResults.getNamed('third').stopDefaultButtonEvent, false);

    // Tap #3 --------------
    await tester.tap(newScreenButtonFinder);
    await tester.pump();

    expect(interceptorResults.count, 3);
    expect(interceptorResults.ifDefaultButtonEventWasFired, false);

    expect(interceptorResults.getNamed('first').stopDefaultButtonEvent, true);
    expect(interceptorResults.getNamed('second').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('third').stopDefaultButtonEvent, false);

    // Tap #4 --------------
    await tester.tap(newScreenButtonFinder);
    await tester.pumpAndSettle();

    expect(interceptorResults.count, 4);
    expect(interceptorResults.ifDefaultButtonEventWasFired, true);

    expect(interceptorResults.getNamed('first').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('second').stopDefaultButtonEvent, false);
    expect(interceptorResults.getNamed('third').stopDefaultButtonEvent, false);
  });
}

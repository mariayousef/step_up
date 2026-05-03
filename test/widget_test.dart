import 'package:flutter_test/flutter_test.dart';
import 'package:step_up/main.dart';

void main() {
  testWidgets('StepUpApp shows the home dashboard', (tester) async {
    await tester.pumpWidget(const StepUpApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Health Overview'), findsOneWidget);
  });
}

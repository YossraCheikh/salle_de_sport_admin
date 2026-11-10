import 'package:flutter_test/flutter_test.dart';
import 'package:salle_de_sport_admin/main.dart';

void main() {
  testWidgets('GymAdminApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GymAdminApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GymAdminApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_vida_como_luna/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MiVidaComoLunaApp());
    expect(find.byType(MiVidaComoLunaApp), findsOneWidget);
  });
}

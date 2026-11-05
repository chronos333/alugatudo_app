import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:alugatudo_app/controllers/aluga_controller.dart';
import 'package:alugatudo_app/main.dart';

void main() {
  testWidgets('AlugaTudo App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AlugaController()),
        ],
        child: const AlugaTudoApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main screen elements
    expect(find.text('Explorar perto'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Ferramentas'), findsOneWidget);
  });
}

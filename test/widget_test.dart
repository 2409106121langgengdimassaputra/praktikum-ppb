import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ucpubg/main.dart';
import 'package:ucpubg/providers/topup_provider.dart';

void main() {
  testWidgets('Home page loads', (WidgetTester tester) async {
    // Aplikasi harus dibungkus provider, sama seperti di main()
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TopUpProvider(),
        child: const TopUpApp(),
      ),
    );
    expect(find.text('TopUp UC PUBGM'), findsOneWidget);
  });
}

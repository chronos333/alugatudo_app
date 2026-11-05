import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'controllers/aluga_controller.dart';
import 'theme/app_theme.dart';
import 'views/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlugaController()),
      ],
      child: const AlugaTudoApp(),
    ),
  );
}

class AlugaTudoApp extends StatelessWidget {
  const AlugaTudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlugaTudo - Plataforma de Aluguel P2P',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}

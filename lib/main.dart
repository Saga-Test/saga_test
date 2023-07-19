import 'package:flutter/material.dart';
import 'package:saga_test/login/login_page.dart';
import 'package:saga_test/saga_lib/sa_api.dart';
import 'package:saga_test/saga_lib/sa_core.dart';
import 'package:saga_test/saga_lib/sa_widgets.dart';
import './saga_lib/sa_dialogs.dart' as dialogs;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    showProgress = dialogs.Progress.show;
    hideProgress = dialogs.Progress.hide;

    // carregando theme no saWidgets
    appTheme = Theme.of(context);

    return MaterialApp(
      title: 'Saga Test',
      navigatorKey: SAMain.navigatorKey,
      theme: ThemeData(
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: OldStyles.raisedButton,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class OldStyles {
  static final ButtonStyle raisedButton = ElevatedButton.styleFrom(
    minimumSize: const Size(88, 52),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );
}

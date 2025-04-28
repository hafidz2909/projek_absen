import 'package:absen_sqflite/db_helper/database_helper.dart';
import 'package:absen_sqflite/models/model_user.dart';
import 'package:absen_sqflite/pref_handler/preference_handler.dart';
import 'package:absen_sqflite/theme/theme_provider.dart';
import 'package:absen_sqflite/views/home_page.dart';
import 'package:absen_sqflite/views/login_page.dart';
import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: FutureBuilder<int?>(
        future: SharedPrefsHelper.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data != null) {
              // Kalau userId ketemu
              return FutureBuilder<UserModel?>(
                future: DatabaseHelper().getUserById(snapshot.data!),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data != null) {
                    return HomePage(user: userSnapshot.data!);
                  } else {
                    // Kalau gagal ambil user, tetap ke login
                    return const LoginPage();
                  }
                },
              );
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';


import 'pages/login_page.dart';
import 'pages/alumnos_page.dart';
import 'pages/deportes_page.dart';
import 'pages/divisiones_page.dart';
import 'pages/estadisticas_page.dart';
import 'pages/registros_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Entrenador Deportivo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/deportes': (context) => const DeportesPage(),
          '/divisiones': (context) => const DivisionesPage(),
          '/alumnos': (context) => const AlumnosPage(),
          
          //'/estadisticas': (context) => const EstadisticasPage(),
          //'/registros': (context) => const RegistrosPage(),
          
          
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Aquí podés guardar estados globales de tu aplicación si lo necesitás
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sports Evolution',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/sports_logo.png',
                height: 230,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Theme(
                          data: ThemeData.dark().copyWith(
                            scaffoldBackgroundColor: const Color(0xFF070B1A),
                            inputDecorationTheme: const InputDecorationTheme(
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                            ),
                            textTheme: const TextTheme(
                              bodyLarge: TextStyle(color: Colors.white),
                              bodyMedium: TextStyle(color: Colors.white),
                            ),
                          ),
                          child: SignInScreen(
                            providers: providers,
                            actions: [
                              AuthStateChangeAction<SignedIn>((context, state) {
                                Navigator.pushReplacementNamed(context, '/deportes');
                              }),
                            ],
                            headerBuilder: (context, constraints, _) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/images/sports_logo.png',
                                  height: 100,
                                ),
                              );
                            },
                            subtitleBuilder: (context, action) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Iniciá sesión para continuar',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              );
                            },
                            footerBuilder: (context, _) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '© 2025 Sports Evolution',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Theme(
                          data: ThemeData.dark().copyWith(
                            scaffoldBackgroundColor: const Color(0xFF070B1A),
                            inputDecorationTheme: const InputDecorationTheme(
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                            ),
                            textTheme: const TextTheme(
                              bodyLarge: TextStyle(color: Colors.white),
                              bodyMedium: TextStyle(color: Colors.white),
                            ),
                          ),
                          child: RegisterScreen(
                            providers: providers,
                            actions: [
                              AuthStateChangeAction<UserCreated>((context, state) {
                                Navigator.pushReplacementNamed(context, '/deportes');
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.orange,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange),
      ),
    );
  }
}

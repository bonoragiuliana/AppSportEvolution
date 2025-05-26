import 'package:flutter/material.dart';
import 'package:app_sports_2/services/auth_service.dart';

class DivisionesPage extends StatefulWidget {
  const DivisionesPage({super.key});

  @override
  State<DivisionesPage> createState() => _DivisionesPageState();
}

class _DivisionesPageState extends State<DivisionesPage> {
  List<TextEditingController> divisionControllers = [];
  final TextEditingController _nuevoController = TextEditingController();
  bool _agregando = false;

  @override
  void dispose() {
    for (var controller in divisionControllers) {
      controller.dispose();
    }
    _nuevoController.dispose();
    super.dispose();
  }

  void _agregarDivision() {
    final texto = _nuevoController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        divisionControllers.insert(0, TextEditingController(text: texto));
        _nuevoController.clear();
        _agregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String sportName =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Divisiones de $sportName'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona una División para $sportName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ...divisionControllers.map((controller) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              '/alumnos',
                              arguments: {
                                'sport': sportName,
                                'division': controller.text.trim(),
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Colors.orange, width: 2),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          controller.text,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                    );
                  }),

                  // Botón "Add Division..." o TextField para nueva división
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _agregando
                        ? TextField(
                            controller: _nuevoController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Nombre de la división',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.orange, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.orangeAccent, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.orange),
                                onPressed: _agregarDivision,
                              ),
                            ),
                            onSubmitted: (_) => _agregarDivision(),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _agregando = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F0F1A),
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.orange, width: 2),
                              ),
                              elevation: 5,
                            ),
                            child: const Text('Add Division...',
                                style: TextStyle(fontSize: 18)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Deportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar sesión',
          ),
        ],
        onTap: (idx) async {
          if (idx == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/deportes', (route) => false);
          } else {
            // cerrar sesión en Firebase
            await AuthService().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login_page', (route) => false);
          }
        },
      ),
    );
  }
}

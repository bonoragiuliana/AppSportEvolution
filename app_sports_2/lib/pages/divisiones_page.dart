import 'package:flutter/material.dart';
import 'package:app_sports_2/services/auth_service.dart';
import 'package:app_sports_2/services/db_services.dart';

class DivisionesPage extends StatefulWidget {
  const DivisionesPage({Key? key}) : super(key: key);

  @override
  State<DivisionesPage> createState() => _DivisionesPageState();
}

class _DivisionesPageState extends State<DivisionesPage> {
  final TextEditingController _nuevoController = TextEditingController();
  bool _agregando = false;

  @override
  void dispose() {
    _nuevoController.dispose();
    super.dispose();
  }

  Future<void> _agregarDivision(String sportName) async {
    final texto = _nuevoController.text.trim();
    if (texto.isNotEmpty) {
      await DbService().addDivision(sportName, texto);
      _nuevoController.clear();
      setState(() => _agregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sportName = ModalRoute.of(context)!.settings.arguments as String;

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
              'Selecciona una división para $sportName',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: DbService().streamDivisions(sportName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final divisiones = snapshot.data ?? [];
                  return ListView(
                    children: [
                      for (var division in divisiones) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/alumnos',
                                arguments: {
                                  'sport': sportName,
                                  'division': division,
                                },
                              );
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
                            child: Text(division,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_agregando)
                        TextField(
                          controller: _nuevoController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nombre de la división',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF0F0F1A),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.orange),
                              onPressed: () => _agregarDivision(sportName),
                            ),
                          ),
                          onSubmitted: (_) => _agregarDivision(sportName),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _agregando = true),
                          icon: const Icon(Icons.add, color: Colors.orange),
                          label: const Text('Añadir división',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0F1A),
                            side: const BorderSide(
                                color: Colors.orange, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Deportes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout), label: 'Cerrar sesión'),
        ],
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.orange,
        onTap: (idx) async {
          if (idx == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/deportes', (route) => false);
          } else {
            await AuthService().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login_page', (route) => false);
          }
        },
      ),
    );
  }
}

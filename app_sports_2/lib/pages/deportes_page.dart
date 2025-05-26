import 'package:flutter/material.dart';
import 'package:app_sports_2/services/auth_service.dart';

class DeportesPage extends StatefulWidget {
  const DeportesPage({super.key});

  @override
  State<DeportesPage> createState() => _DeportesPageState();
}

class _DeportesPageState extends State<DeportesPage> {
  final List<String> _deportes = [];
  final TextEditingController _controller = TextEditingController();

  bool _agregando = false;

  void _agregarDeporte() {
    final nombre = _controller.text.trim();
    if (nombre.isNotEmpty) {
      setState(() {
        _deportes.insert(0, nombre);
        _controller.clear();
        _agregando = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deportes'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lista de Deportes',
              style: TextStyle(
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
                  // Botones de deportes existentes
                  ..._deportes.map((deporte) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/divisiones',
                            arguments: deporte,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Colors.orange, width: 2),
                          ),
                          elevation: 5,
                        ),
                        child:
                            Text(deporte, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }),

                  // Botón "Add..." o campo de texto
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _agregando
                        ? TextField(
                            controller: _controller,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Nombre del deporte',
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
                                onPressed: _agregarDeporte,
                              ),
                            ),
                            onSubmitted: (_) => _agregarDeporte(),
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
                            child: const Text('Add...',
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
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.orange,
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
            // pop hasta la ruta de deportes para **preservar** la lista
            Navigator.popUntil(context, ModalRoute.withName('/deportes'));
          } else {
            await AuthService().signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login_page',
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

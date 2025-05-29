import 'package:flutter/material.dart';
import 'package:app_sports_2/services/auth_service.dart';
import 'package:app_sports_2/services/db_services.dart';

class DeportesPage extends StatefulWidget {
  const DeportesPage({Key? key}) : super(key: key);

  @override
  State<DeportesPage> createState() => _DeportesPageState();
}

class _DeportesPageState extends State<DeportesPage> {
  final TextEditingController _controller = TextEditingController();
  bool _agregando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _agregarDeporte() async {
    final nombre = _controller.text.trim();
    if (nombre.isNotEmpty) {
      await DbService().addSport(nombre);
      _controller.clear();
      setState(() => _agregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1A1A2E)),
              child: Text('Menú',
                  style: TextStyle(color: Colors.orange, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.orange),
              title: const Text('Ver Base de Datos',
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/database');
              },
            ),
          ],
        ),
      ),
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
                  color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: DbService().streamSports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final deportes = snapshot.data ?? [];
                  return ListView(
                    children: [
                      // Botones para cada deporte
                      for (var deporte in deportes) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/divisiones',
                              arguments: deporte,
                            ),
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
                            child: Text(deporte,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Campo / botón para añadir deporte
                      if (_agregando)
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          style: const TextStyle(color: Colors.orange),
                          decoration: InputDecoration(
                            hintText: 'Nombre del deporte',
                            hintStyle: const TextStyle(color: Colors.orange),
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
                                  color: Colors.orange, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.orange),
                              onPressed: _agregarDeporte,
                            ),
                          ),
                          onSubmitted: (_) => _agregarDeporte(),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _agregando = true),
                          icon: const Icon(Icons.add, color: Colors.orange),
                          label: const Text('Añadir deporte',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0F1A),
                            side: const BorderSide(
                                color: Colors.orange, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Deportes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout), label: 'Cerrar sesión'),
        ],
        onTap: (idx) async {
          if (idx == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/deportes'));
          } else {
            await AuthService().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login_page', (_) => false);
          }
        },
      ),
    );
  }
}

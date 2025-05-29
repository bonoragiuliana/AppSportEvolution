import 'package:flutter/material.dart';
import 'package:app_sports_2/services/auth_service.dart';
import 'package:app_sports_2/services/db_services.dart';

class AlumnosPage extends StatefulWidget {
  const AlumnosPage({Key? key}) : super(key: key);

  @override
  State<AlumnosPage> createState() => _AlumnosPageState();
}

class _AlumnosPageState extends State<AlumnosPage> {
  final _nuevoCtrl = TextEditingController();
  bool _agregando = false;

  @override
  void dispose() {
    _nuevoCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregaAlumno(String sport, String division) async {
    final txt = _nuevoCtrl.text.trim();
    if (txt.isNotEmpty) {
      await DbService().addPlayer(sport, division, txt);
      _nuevoCtrl.clear();
      setState(() => _agregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args     = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final sport    = args['sport']!;
    final division = args['division']!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alumnos de $sport → $division'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: DbService().streamPlayers(sport, division),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final alumnos = snap.data!;
                  return ListView(
                    children: [
                      for (var alumno in alumnos) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context, '/registros',
                              arguments: {
                                'sport': sport,
                                'division': division,
                                'player': alumno
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F0F1A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.orange, width: 2),
                              ),
                              elevation: 5,
                            ),
                            child: Text(alumno, style: const TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_agregando)
                        TextField(
                          controller: _nuevoCtrl,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nombre del alumno',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF1A1A2E),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check, color: Colors.orange),
                              onPressed: () => _agregaAlumno(sport, division),
                            ),
                          ),
                          onSubmitted: (_) => _agregaAlumno(sport, division),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _agregando = true),
                          icon: const Icon(Icons.add, color: Colors.orange),
                          label: const Text(
                            'Añadir alumno',
                            style: TextStyle(color: Colors.orange, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0F1A),
                            side: const BorderSide(color: Colors.orange, width: 2),
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
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Deportes'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Cerrar sesión'),
        ],
        onTap: (i) async {
          if (i == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/deportes'));
          } else {
            await AuthService().signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/login_page', (_) => false);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AlumnosPage extends StatefulWidget {
  const AlumnosPage({super.key});

  @override
  State<AlumnosPage> createState() => _AlumnosPageState();
}

class _AlumnosPageState extends State<AlumnosPage> {
  List<String> _alumnos = []; // Empezar vacío
  TextEditingController _nuevoAlumnoController = TextEditingController();
  bool _mostrandoCampoNuevo = false;

  @override
  void dispose() {
    _nuevoAlumnoController.dispose();
    super.dispose();
  }

  void _agregarAlumnoSiNoVacio() {
    final nuevoNombre = _nuevoAlumnoController.text.trim();
    if (nuevoNombre.isNotEmpty) {
      setState(() {
        _alumnos.insert(0, nuevoNombre); // Agrega arriba
        _nuevoAlumnoController.clear();
        _mostrandoCampoNuevo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String sportName = args['sport']!;
    final String divisionName = args['division']!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alumnos de $sportName - $divisionName'),
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
              'Alumnos en $divisionName de $sportName',
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
                  // Lista de alumnos
                  ..._alumnos.map((alumno) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          alumno,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 8),

                  // Botón "Add Student..." que se convierte en campo de texto
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _mostrandoCampoNuevo
                        ? ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F0F1A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.orange, width: 2),
                              ),
                              elevation: 5,
                            ),
                            child: TextField(
                              controller: _nuevoAlumnoController,
                              autofocus: true,
                              onSubmitted: (_) => _agregarAlumnoSiNoVacio(),
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Escribe el nombre del alumno',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                              cursorColor: Colors.orange,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _mostrandoCampoNuevo = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F0F1A),
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.orange, width: 2),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Add Student...',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



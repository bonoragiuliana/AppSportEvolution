import 'package:flutter/material.dart';

class DivisionesPage extends StatefulWidget {
  const DivisionesPage({super.key});

  @override
  State<DivisionesPage> createState() => _DivisionesPageState();
}

class _DivisionesPageState extends State<DivisionesPage> {
  List<String> _divisiones = [];
  final TextEditingController _controller = TextEditingController();
  bool _agregando = false;

  void _agregarDivision() {
    final nombre = _controller.text.trim();
    if (nombre.isNotEmpty) {
      setState(() {
        _divisiones.insert(0, nombre);
        _controller.clear();
        _agregando = false;
      });
    }
  }

  void _irAHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String sportName = ModalRoute.of(context)!.settings.arguments as String;

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
                  ..._divisiones.map((division) {
                    return Padding(
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          elevation: 5,
                        ),
                        child: Text(division, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _agregando
                        ? TextField(
                            controller: _controller,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Nombre de la división',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check, color: Colors.orange),
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
                                side: const BorderSide(color: Colors.orange, width: 2),
                              ),
                              elevation: 5,
                            ),
                            child: const Text('Add Division...', style: TextStyle(fontSize: 18)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A1A2E),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.orange, size: 32),
              onPressed: _irAHome,
              tooltip: 'Volver a Home',
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_sports_2/services/db_services.dart';
import 'package:app_sports_2/services/auth_service.dart';
import 'package:flutter/services.dart';

class RegistrosPage extends StatefulWidget {
  const RegistrosPage({Key? key}) : super(key: key);
  @override
  State createState() => _RecordPageState();
}

class _RecordPageState extends State {
  final TextEditingController _fechaController = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }

  final Map<String, TextEditingController> ctrls = {
    'Edad': TextEditingController(),
    'Altura': TextEditingController(),
    'Peso': TextEditingController(),
    '%MM': TextEditingController(),
    'IMC': TextEditingController(),
    '%MG': TextEditingController(),
    'Velocidad': TextEditingController(),
    'Resistencia': TextEditingController(),
    'Fuerza': TextEditingController(),
    'Potencia': TextEditingController(),
    'Notas': TextEditingController(),
  };

  Widget _buildField(String key, {bool multiline = false}) {
    return TextField(
      controller: ctrls[key],
      style: const TextStyle(color: Colors.orange),
      decoration: InputDecoration(
        labelText: key.toUpperCase(),
        labelStyle: const TextStyle(color: Colors.orange),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: multiline ? TextInputType.multiline : TextInputType.number,
      maxLines: multiline ? null : 1,
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, String>;
    final s = args['sport']!, d = args['division']!, p = args['player']!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.orange),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registro de $p',
            style: const TextStyle(color: Colors.orange)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fecha con formato libre o con máscara
            TextField(
              controller: _fechaController,
              style: const TextStyle(color: Colors.orange),
              decoration: InputDecoration(
                labelText: 'Fecha (DD/MM/AAAA)',
                labelStyle: const TextStyle(color: Colors.orange),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))
              ],
            ),
            const SizedBox(height: 16),
            const Text('DATOS FÍSICOS',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Edad')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Altura'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Peso')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('%MM'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('IMC')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('%MG'))
            ]),
            const SizedBox(height: 24),
            const Text('RENDIMIENTO',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Velocidad')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Resistencia'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Fuerza')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Potencia'))
            ]),
            const SizedBox(height: 24),
            const Text('SALUD',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            _buildField('Notas', multiline: true),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final valores = ctrls
                    .map((k, v) => MapEntry(k, double.tryParse(v.text) ?? 0));
                final dataRecord = {
                  ...valores,
                  'fecha': _fechaController.text.trim(),
                  'timestamp': Timestamp.now(),
                };
                await DbService().addRecord(s, d, p, dataRecord);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ficha registrada correctamente')),
                );
                Navigator.pushNamed(
                  context,
                  '/estadisticas',
                  arguments: {'sport': s, 'division': d, 'player': p},
                );
              },
              child: const Text('Guardar'),
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

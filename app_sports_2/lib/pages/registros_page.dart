// lib/pages/registros_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app_sports_2/services/db_services.dart';
import 'package:app_sports_2/services/auth_service.dart';

class RegistrosPage extends StatefulWidget {
  const RegistrosPage({Key? key}) : super(key: key);

  @override
  State<RegistrosPage> createState() => _RegistrosPageState();
}

class _RegistrosPageState extends State<RegistrosPage> {
  DateTime? _selectedDate;

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

  @override
  void dispose() {
    for (var c in ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final sport = args['sport']!;
    final division = args['division']!;
    final player = args['player']!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.orange),
        title: Text('Registro de $player',
            style: const TextStyle(color: Colors.orange)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Fecha: DatePicker
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, color: Colors.orange),
              label: Text(
                _selectedDate == null
                    ? 'Selecciona fecha'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F1A),
                side: const BorderSide(color: Colors.orange),
              ),
              onPressed: () async {
                final today = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? today,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: Colors.orange,
                        onPrimary: Colors.white,
                        surface: const Color(0xFF1A1A2E),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 24),

            // 2) Secciones y campos
            const Text('DATOS FÍSICOS', style: sectionStyle),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Edad')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Altura')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Peso')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('%MM')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('IMC')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('%MG')),
            ]),

            const SizedBox(height: 24),
            const Text('RENDIMIENTO', style: sectionStyle),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Velocidad')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Resistencia')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField('Fuerza')),
              const SizedBox(width: 8),
              Expanded(child: _buildField('Potencia')),
            ]),

            const SizedBox(height: 24),
            const Text('SALUD', style: sectionStyle),
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
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, selecciona una fecha.')),
                  );
                  return;
                }
                final data = <String, dynamic>{};
                ctrls.forEach((key, ctrl) {
                  data[key] = (key == 'Notas')
                      ? ctrl.text.trim()
                      : double.tryParse(ctrl.text.trim()) ?? 0;
                });
                data['timestamp'] = Timestamp.fromDate(_selectedDate!);
                await DbService().addRecord(sport, division, player, data);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Ficha registrada correctamente')));
                Navigator.pushNamed(
                  context,
                  '/estadisticas',
                  arguments: {
                    'sport': sport,
                    'division': division,
                    'player': player,
                  },
                );
              },
              child: const Text('Guardar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  static const sectionStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange);

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

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
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
    );
  }
}

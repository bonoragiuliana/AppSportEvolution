import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_services.dart';
import 'package:app_sports_2/services/auth_service.dart';

class EstadisticasPage extends StatefulWidget {
  final String sportId;
  final String divisionId;
  final String playerId;

  const EstadisticasPage({
    Key? key,
    required this.sportId,
    required this.divisionId,
    required this.playerId,
  }) : super(key: key);

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  String? _selectedMetric;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        // Icono de retroceso automático aparecerá si vienes con Navigator.push
        iconTheme: const IconThemeData(color: Colors.orange),
        title: const Text(
          'Estadísticas',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: DbService().streamRecords(
            widget.sportId,
            widget.divisionId,
            widget.playerId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data ?? [];
            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Sin datos',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
              );
            }
            // Extraer métricas dinámicas
            final firstMap = docs.first.data();
            final metrics = firstMap.keys
                .where((k) => k != 'timestamp')
                .toList(growable: false);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF1A1A2E),
                  value: _selectedMetric,
                  hint: const Text(
                    'Seleccione métrica',
                    style: TextStyle(color: Colors.orange),
                  ),
                  isExpanded: true,
                  items: metrics.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(
                        m,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedMetric = v),
                ),
                const SizedBox(height: 24),
                if (_selectedMetric == null)
                  const Center(
                    child: Text(
                      'Seleccione una métrica',
                      style: TextStyle(color: Colors.orange, fontSize: 16),
                    ),
                  )
                else
                  Expanded(
                    child: _buildLineChart(docs, _selectedMetric!),
                  ),
              ],
            );
          },
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

  Widget _buildLineChart(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      String metric) {
    final baseDate = (docs.first['timestamp'] as Timestamp).toDate();
    final spots = docs.map((doc) {
      final date = (doc['timestamp'] as Timestamp).toDate();
      final x = date.difference(baseDate).inDays.toDouble();
      final y = (doc[metric] as num).toDouble();
      return FlSpot(x, y);
    }).where((spot) => spot.x.isFinite && spot.y.isFinite).toList();

    final interval =
        spots.length < 2 ? 1.0 : spots.last.x / (spots.length - 1);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(spots: spots, isCurved: true),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, meta) {
                final idx = value.isFinite ? value.toInt() : 0;
                final d = baseDate.add(Duration(days: idx));
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${d.day}/${d.month}',
                    style:
                        const TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

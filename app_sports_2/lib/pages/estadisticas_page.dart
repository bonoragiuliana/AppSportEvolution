import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:app_sports_2/services/db_services.dart';
import 'package:app_sports_2/services/auth_service.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({Key? key}) : super(key: key);

  @override
  _EstadisticasPageState createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  String? _selectedMetric;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final sportId = args['sport']!;
    final divisionId = args['division']!;
    final playerId = args['player']!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.orange),
        title:
            const Text('Estadísticas', style: TextStyle(color: Colors.orange)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: DbService().streamRecords(sportId, divisionId, playerId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data ?? [];
            if (docs.isEmpty) {
              return const Center(
                  child: Text('Sin datos',
                      style: TextStyle(color: Colors.orange)));
            }

            // Obtener métricas, excluyendo 'Edad' y 'Altura'
            final metrics = docs.first
                .data()
                .entries
                .where((e) => e.key != 'timestamp' && e.value is num)
                .map((e) => e.key)
                .where((m) => m != 'Edad' && m != 'Altura')
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown personalizado que abre a la primera
                Builder(builder: (ctxBtn) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0F1A),
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    onPressed: () async {
                      final renderBox = ctxBtn.findRenderObject() as RenderBox;
                      final offset = renderBox.localToGlobal(Offset.zero);
                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy + renderBox.size.height,
                          offset.dx + renderBox.size.width,
                          offset.dy,
                        ),
                        items: metrics
                            .map((m) => PopupMenuItem(
                                  value: m,
                                  child: Text(m,
                                      style: const TextStyle(
                                          color: Colors.orange)),
                                ))
                            .toList(),
                      );
                      if (selected != null) {
                        setState(() => _selectedMetric = selected);
                      }
                    },
                    child: Text(
                      _selectedMetric ?? 'Seleccione métrica',
                      style:
                          const TextStyle(color: Colors.orange, fontSize: 16),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (_selectedMetric == null)
                  const SizedBox.shrink()
                else
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: LayoutBuilder(builder: (_, cons) {
                        final chartWidth =
                            max(cons.maxWidth, docs.length * 80.0);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: chartWidth,
                            child: LineChart(
                                _buildChartData(docs, _selectedMetric!)),
                          ),
                        );
                      }),
                    ),
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

  LineChartData _buildChartData(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String metric) {
    final dataPairs = docs.map((d) {
      final dt = (d.data()['timestamp'] as Timestamp).toDate();
      final val = (d.data()[metric] as num).toDouble();
      return MapEntry(dt, val);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final dates = dataPairs.map((e) => e.key).toList();
    final values = dataPairs.map((e) => e.value).toList();
    final xValues = List.generate(dates.length, (i) => i.toDouble());
    final spots = List.generate(
      dates.length,
      (i) => FlSpot(xValues[i], values[i]),
    );

    double minY = values.reduce(min);
    double maxY = values.reduce(max);
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final maxX = xValues.last;
    const xInt = 1.0;
    final yInt = (maxY - minY) / 4;

    return LineChartData(
      clipData: FlClipData.all(),
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          dotData: FlDotData(show: true),
          barWidth: 3,
          color: Colors.orange,
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: xInt,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= dates.length) return const SizedBox();
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  DateFormat('dd/MM').format(dates[idx]),
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInt,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, horizontalInterval: yInt),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.orange),
          bottom: BorderSide(color: Colors.orange),
          top: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

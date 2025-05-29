import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:app_sports_2/services/db_services.dart';

class DatabasePage extends StatelessWidget {
  const DatabasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pushReplacementNamed(ctx, '/deportes'),
        ),
        title: Text('DB de ${user.email}',
            style: const TextStyle(color: Colors.orange)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      backgroundColor: const Color(0xFF0F0F1A),
      body: StreamBuilder<List<String>>(
        stream: DbService().streamSports(),
        builder: (cS, sS) {
          if (!sS.hasData)
            return const Center(child: CircularProgressIndicator());
          return ListView(
            children: sS.data!
                .map((sport) => _themedTile(
                      title: sport,
                      children: [_buildDivisions(ctx, sport)],
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildDivisions(BuildContext ctx, String sport) {
    return StreamBuilder<List<String>>(
      stream: DbService().streamDivisions(sport),
      builder: (cD, sD) {
        if (!sD.hasData) return const SizedBox();
        return Column(
          children: sD.data!
              .map((div) => _themedTile(
                    title: div,
                    children: [_buildPlayers(ctx, sport, div)],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildPlayers(BuildContext ctx, String sport, String div) {
    return StreamBuilder<List<String>>(
      stream: DbService().streamPlayers(sport, div),
      builder: (cP, sP) {
        if (!sP.hasData) return const SizedBox();
        return Column(
          children: sP.data!
              .map((pl) => _themedTile(
                    title: pl,
                    children: [_buildRecords(sport, div, pl)],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildRecords(String sport, String div, String pl) {
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: DbService().streamRecords(sport, div, pl),
      builder: (cR, sR) {
        if (!sR.hasData) return const SizedBox();
        // Copiar y ordenar por timestamp descendente
        final docs = List.of(sR.data!);
        docs.sort((a, b) {
          final ta = a.data()['timestamp'] as Timestamp?;
          final tb = b.data()['timestamp'] as Timestamp?;
          if (ta != null && tb != null) {
            return tb.compareTo(ta);
          }
          return 0;
        });
        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            // Seleccionar fecha
            String fecha;
            if (data['fecha'] is String &&
                (data['fecha'] as String).isNotEmpty) {
              fecha = data['fecha'] as String;
            } else if (data['timestamp'] is Timestamp) {
              final ts = data['timestamp'] as Timestamp;
              fecha = DateFormat('dd/MM/yyyy').format(ts.toDate());
            } else {
              fecha = '—';
            }
            // Detalles
            final details = data.entries
                .where((e) => e.key != 'fecha' && e.key != 'timestamp')
                .map((e) => '${e.key}: ${e.value}')
                .join(' • ');
            return ListTile(
              tileColor: const Color(0xFF1A1A2E),
              title: Text(fecha, style: const TextStyle(color: Colors.orange)),
              subtitle:
                  Text(details, style: const TextStyle(color: Colors.white70)),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _themedTile({required String title, required List<Widget> children}) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF1A1A2E),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(title, style: const TextStyle(color: Colors.orange)),
        iconColor: Colors.orange,
        collapsedIconColor: Colors.orange,
        children: children,
      ),
    );
  }
}

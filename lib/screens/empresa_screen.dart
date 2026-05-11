import 'package:flutter/material.dart';

class EmpresaScreen extends StatelessWidget {
  const EmpresaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D3B3),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                card("38", "reportes"),
                card("25", "pendientes"),
                card("12", "resueltos"),
                card("16", "operarios"),
              ],
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget card(String num, String texto) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(num, style: const TextStyle(color: Colors.white)),
          Text(texto, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget reporteEmpresa(String direccion) {
    return ListTile(
      title: Text(direccion),
      subtitle: const Text("Alta prioridad"),
    );
  }
}
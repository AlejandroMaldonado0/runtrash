import 'package:flutter/material.dart';


class OperarioScreen extends StatelessWidget {
  const OperarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D3B3),
      body: Column(
        children: [

          Image.asset('assets/mapa.png'),

          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D61),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "Generar ruta 📍",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                item("Pendiente", Colors.red),
                item("En proceso", Colors.orange),
                item("Resuelto", Colors.green),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget item(String estado, Color color) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(estado),
    );
  }
}
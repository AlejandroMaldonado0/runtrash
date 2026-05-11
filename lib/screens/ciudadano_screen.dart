import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class CiudadanoScreen extends StatelessWidget {
  const CiudadanoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D3B3),
      body: SafeArea(
        child: Stack(
          children: [

            // 🔹 FONDO (mapa suave)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 🔹 CONTENIDO
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/logo2.png', width: 100),
                      Row(
                        children: [
                          Stack(
                            children: [
                              const Icon(Icons.notifications, size: 30, color: Colors.orange),
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text("1",
                                      style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 10),
                          const CircleAvatar()
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 BOTÓN PRINCIPAL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D61),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Reportar Basura ♻️",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔹 CHIPS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      chip("Ver Mapa", false),
                      chip("Mis Reportes", true),
                      chip("Historial", false),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 MENSAJE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Tu reporte fue atendido",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Reportes recientes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 LISTA
                  Expanded(
                    child: ListView(
                      children: [
                        reporte(
                          "Pendiente",
                          Colors.red,
                          "Calle 141a #111a , Bogotá",
                          "10/Abril",
                        ),
                        reporte(
                          "En proceso",
                          Colors.orange,
                          "Carrera 51a #8b-14 , Bogotá",
                          "09/Abril",
                        ),
                        reporte(
                          "Completado",
                          Colors.green,
                          "Carrera 161a #52-12 , Bogotá",
                          "04/Abril",
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CHIP
  Widget chip(String texto, bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? const Color(0xFF2E7D61) : Colors.grey.shade500,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // 🔹 TARJETA REPORTE
  Widget reporte(String estado, Color color, String direccion, String fecha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estado,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              Text(fecha, style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          Text(direccion),
          const SizedBox(height: 5),
          const Text(
            "acumulacion de basura parque publico",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
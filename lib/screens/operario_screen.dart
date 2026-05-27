import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OperarioScreen extends StatelessWidget {

  const OperarioScreen({super.key});

  /// 🔥 OBTENER REPORTES ASIGNADOS
  Stream<QuerySnapshot> obtenerReportes() {

    return FirebaseFirestore.instance
        .collection("reportes")
        .where(
      "operarioId",
      isEqualTo:
      FirebaseAuth.instance.currentUser!.uid,
    )
        .snapshots();
  }

  /// 🔥 CAMBIAR ESTADO
  Future<void> cambiarEstado(
      String idReporte,
      String nuevoEstado,
      ) async {

    await FirebaseFirestore.instance
        .collection("reportes")
        .doc(idReporte)
        .update({

      "estado": nuevoEstado,
    });
  }

  /// 🔥 GENERAR RUTA
  Future<void> generarRuta(
      BuildContext context,
      ) async {

    QuerySnapshot query =
    await FirebaseFirestore.instance
        .collection("reportes")
        .where(
      "operarioId",
      isEqualTo:
      FirebaseAuth.instance.currentUser!.uid,
    )
        .where(
      "estado",
      isNotEqualTo:
      "Completado",
    )
        .get();

    List reportes =
        query.docs;

    if (reportes.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "No hay reportes para generar ruta",
          ),
        ),
      );

      return;
    }

    /// 🔥 ORDENAR POR LATITUD
    reportes.sort((a, b) {

      double latA =
      a["latitud"];

      double latB =
      b["latitud"];

      return latA.compareTo(latB);
    });

    String ruta = "";

    for (var reporte in reportes) {

      ruta +=
      "${reporte["ubicacion"]}\n";
    }

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "Ruta Generada",
          ),

          content: Text(ruta),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);
              },

              child: const Text(
                "Cerrar",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFE8DFC9),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF2E8B57),

        title: const Text(
          "Panel Operario",
        ),

        actions: [

          /// 🔥 GENERAR RUTA
          IconButton(

            onPressed: () {

              generarRuta(context);
            },

            icon: const Icon(
              Icons.route,
            ),
          ),

          /// 🔥 CERRAR SESIÓN
          IconButton(

            onPressed: () async {

              await FirebaseAuth.instance
                  .signOut();

              Navigator.pushReplacementNamed(
                context,
                "/login",
              );
            },

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: obtenerReportes(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(

              child: Text(
                "No tienes reportes asignados",
              ),
            );
          }

          final reportes =
              snapshot.data!.docs;

          return ListView.builder(

            padding:
            const EdgeInsets.all(15),

            itemCount:
            reportes.length,

            itemBuilder:
                (context, index) {

              final reporte =
              reportes[index];

              String estado =
              reporte["estado"];

              Color colorEstado =
                  Colors.red;

              if (estado ==
                  "En proceso") {

                colorEstado =
                    Colors.orange;
              }

              if (estado ==
                  "Completado") {

                colorEstado =
                    Colors.green;
              }

              return Container(

                margin:
                const EdgeInsets.only(
                  bottom: 20,
                ),

                padding:
                const EdgeInsets.all(
                  20,
                ),

                decoration:
                BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    /// 🔥 ESTADO
                    Container(

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        colorEstado,

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Text(

                        estado,

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// 🔥 UBICACIÓN
                    Text(

                      reporte["ubicacion"],

                      style:
                      const TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    /// 🔥 DESCRIPCIÓN
                    Text(
                      reporte["descripcion"],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    /// 🔥 TIPO
                    Text(
                      "Tipo: ${reporte["tipo"]}",
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    /// 🔥 BOTONES CAMBIAR ESTADO
                    Row(

                      children: [

                        Expanded(

                          child:
                          ElevatedButton(

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.orange,
                            ),

                            onPressed: () {

                              cambiarEstado(
                                reporte.id,
                                "En proceso",
                              );
                            },

                            child: const Text(
                              "En proceso",
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child:
                          ElevatedButton(

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.green,
                            ),

                            onPressed: () {

                              cambiarEstado(
                                reporte.id,
                                "Completado",
                              );
                            },

                            child: const Text(
                              "Completar",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
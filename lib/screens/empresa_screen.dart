import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmpresaScreen extends StatelessWidget {

  const EmpresaScreen({super.key});

  /// 🔥 OBTENER REPORTES
  Stream<QuerySnapshot> obtenerReportes() {

    return FirebaseFirestore.instance
        .collection("reportes")
        .orderBy(
      "fecha",
      descending: true,
    )
        .snapshots();
  }

  /// 🔥 OBTENER OPERARIO AUTOMÁTICO
  Future<String?> obtenerOperario() async {

    QuerySnapshot query =
    await FirebaseFirestore.instance
        .collection("usuarios")
        .where(
      "tipo",
      isEqualTo: "operario",
    )
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {

      return query.docs.first.id;
    }

    return null;
  }

  /// 🔥 ASIGNAR OPERARIO
  Future<void> asignarOperario(
      String idReporte,
      ) async {

    String? operarioId =
    await obtenerOperario();

    if (operarioId == null) return;

    await FirebaseFirestore.instance
        .collection("reportes")
        .doc(idReporte)
        .update({

      "operarioId":
      operarioId,

      "estado":
      "En proceso",
    });
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
          "RunTrash",
        ),

        actions: [

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
                "No hay reportes",
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

                    /// 🔥 BOTÓN ENVIAR A OPERARIO
                    if (estado ==
                        "Pendiente")

                      SizedBox(

                        width:
                        double.infinity,

                        child:
                        ElevatedButton(

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.green,
                          ),

                          onPressed: () async {

                            await asignarOperario(
                              reporte.id,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                content: Text(
                                  "Reporte enviado al operario",
                                ),
                              ),
                            );
                          },

                          child: const Text(
                            "Enviar a Operario",
                          ),
                        ),
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
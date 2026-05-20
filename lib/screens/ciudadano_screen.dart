import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'nuevo_reporte_screen.dart';

class CiudadanoScreen extends StatefulWidget {
  const CiudadanoScreen({super.key});

  @override
  State<CiudadanoScreen> createState() =>
      _CiudadanoScreenState();
}

class _CiudadanoScreenState
    extends State<CiudadanoScreen> {

  Stream<QuerySnapshot> obtenerReportes() {
    return FirebaseFirestore.instance
        .collection("reportes")
        .where(
      "usuarioId",
      isEqualTo:
      FirebaseAuth.instance.currentUser!.uid,
    )
        .orderBy(
      "fecha",
      descending: true,
    )
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFE8DFC9),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// 🔹 PARTE SUPERIOR
                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Image.asset(
                      "assets/logo.png",
                      width: 100,
                    ),

                    Row(
                      children: [

                        /// 🔔 NOTIFICACIONES
                        Stack(
                          children: [

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.orange,
                                size: 32,
                              ),
                            ),

                            Positioned(
                              right: 0,
                              child: Container(
                                padding:
                                const EdgeInsets.all(4),

                                decoration:
                                const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),

                                child: const Text(
                                  "1",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// 👤 PERFIL
                        PopupMenuButton<String>(

                          icon: const CircleAvatar(
                            radius: 22,
                            backgroundColor:
                            Colors.lightGreen,
                          ),

                          onSelected:
                              (value) async {

                            /// 🔹 CERRAR SESIÓN
                            if (value == "logout") {

                              await FirebaseAuth.instance
                                  .signOut();

                              Navigator.pushReplacementNamed(
                                context,
                                "/login",
                              );
                            }

                            /// 🔹 CAMBIAR CONTRASEÑA
                            if (value == "password") {

                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                email: FirebaseAuth
                                    .instance
                                    .currentUser!
                                    .email!,
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Correo enviado para cambiar contraseña",
                                  ),
                                ),
                              );
                            }
                          },

                          itemBuilder: (context) => [

                            const PopupMenuItem(
                              value: "password",
                              child: Text(
                                "Cambiar contraseña",
                              ),
                            ),

                            const PopupMenuItem(
                              value: "logout",
                              child: Text(
                                "Cerrar sesión",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔹 BOTÓN REPORTAR
                GestureDetector(

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const NuevoReporteScreen(),
                      ),
                    );
                  },

                  child: Container(

                    width: double.infinity,

                    padding:
                    const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF2E8B57),

                      borderRadius:
                      BorderRadius.circular(25),
                    ),

                    child: const Center(
                      child: Text(
                        "Reportar Basura ♻️",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 BOTONES
                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    botonSuperior("Ver Mapa"),

                    botonSuperior("Mis Reportes"),

                    botonSuperior("Historial"),
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔹 MENSAJE
                Container(

                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: const Row(
                    children: [

                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 35,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Tu reporte fue atendido",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Reportes recientes",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ///  REPORTES DINÁMICOS
                StreamBuilder<QuerySnapshot>(

                  stream: obtenerReportes(),

                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {

                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    final reportes =
                        snapshot.data!.docs;

                    if (reportes.isEmpty) {

                      return const Text(
                        "No tienes reportes aún",
                      );
                    }

                    return Column(

                      children: reportes.map((doc) {

                        String estado =
                        doc["estado"];

                        String ubicacion =
                        doc["ubicacion"];

                        String descripcion =
                        doc["descripcion"];

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
                            bottom: 10,
                          ),

                          padding:
                          const EdgeInsets.all(50),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white
                                .withOpacity(0.9),

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
                                height: 10,
                              ),

                              Text(
                                ubicacion,

                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 50,
                              ),

                              Text(descripcion),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget botonSuperior(String texto) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        texto,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
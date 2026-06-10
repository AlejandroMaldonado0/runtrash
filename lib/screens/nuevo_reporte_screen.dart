import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 NUEVOS IMPORTS
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() =>
      _NuevoReporteScreenState();
}

class _NuevoReporteScreenState
    extends State<NuevoReporteScreen> {

  // ---------------- VARIABLES ----------------

  String tipoProblema = "";

  File? imagenSeleccionada;

  bool cargando = false;

  final ImagePicker picker = ImagePicker();

  final descripcionController =
  TextEditingController();

  final ubicacionController =
  TextEditingController();

  // 🔥 GPS
  double latitud = 0;

  double longitud = 0;

  bool cargandoUbicacion = false;
  bool usarGps = true;

  @override
  void initState() {

    super.initState();

    obtenerUbicacion();
  }

  // ---------------- TOMAR FOTO ----------------

  Future<void> tomarFoto() async {

    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (foto != null) {

      setState(() {

        imagenSeleccionada = File(foto.path);

      });
    }
  }

  // ---------------- SUBIR IMAGEN ----------------

  Future<void> subirImagen() async {

    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null) {

      setState(() {

        imagenSeleccionada = File(imagen.path);

      });
    }
  }

  // ---------------- OBTENER UBICACIÓN ----------------

  Future<void> obtenerUbicacion() async {

    try {

      setState(() {

        cargandoUbicacion = true;
      });

      bool servicioHabilitado;

      LocationPermission permiso;

      servicioHabilitado =
      await Geolocator
          .isLocationServiceEnabled();

      if (!servicioHabilitado) {

        return;
      }

      permiso =
      await Geolocator
          .checkPermission();

      if (permiso ==
          LocationPermission.denied) {

        permiso =
        await Geolocator
            .requestPermission();

        if (permiso ==
            LocationPermission.denied) {

          return;
        }
      }

      Position posicion =
      await Geolocator
          .getCurrentPosition(

        desiredAccuracy:
        LocationAccuracy.high,
      );

      latitud =
          posicion.latitude;

      longitud =
          posicion.longitude;

      List<Placemark> lugares =
      await placemarkFromCoordinates(
        latitud,
        longitud,
      );

      Placemark lugar =
          lugares.first;

      ubicacionController.text =
      "${lugar.street}, ${lugar.locality}";

    } catch (e) {

      print(e);
    }

    setState(() {

      cargandoUbicacion = false;
    });
  }

  // ---------------- BOTONES TIPO ----------------

  Widget botonTipo(String texto) {

    bool activo = tipoProblema == texto;

    return GestureDetector(

      onTap: () {

        setState(() {

          tipoProblema = texto;

        });
      },

      child: Container(

        width: 120,
        height: 45,

        decoration: BoxDecoration(

          color: activo
              ? const Color(0xFF6AA84F)
              : Colors.grey.shade400,

          borderRadius:
          BorderRadius.circular(10),
        ),

        child: Center(

          child: Text(

            texto,

            style: const TextStyle(

              color: Colors.white,

              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ENVIAR REPORTE ----------------
  Future<void> enviarReporte() async {

    if (descripcionController.text.isEmpty ||

        ubicacionController.text.isEmpty ||

        tipoProblema.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Completa todos los campos",
          ),
        ),
      );

      return;
    }

    try {

      setState(() {

        cargando = true;
      });

      double latitudFinal = latitud;
      double longitudFinal = longitud;

      if (!usarGps) {

        try {

          List<Location> ubicaciones =
          await locationFromAddress(
            ubicacionController.text,
          );

          if (ubicaciones.isNotEmpty) {

            latitudFinal =
                ubicaciones.first.latitude;

            longitudFinal =
                ubicaciones.first.longitude;
          }

        } catch (e) {

          throw Exception(
            "No se pudo encontrar esa dirección",
          );
        }
      }

      await FirebaseFirestore.instance
          .collection("reportes")
          .add({

        "ubicacion":
        ubicacionController.text,

        "descripcion":
        descripcionController.text,

        "tipo":
        tipoProblema,

        "estado":
        "Pendiente",

        "fecha":
        Timestamp.now(),

        "usuarioId":
        FirebaseAuth.instance.currentUser!.uid,

        "latitud":
        latitudFinal,

        "longitud":
        longitudFinal,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Reporte enviado correctamente",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    } finally {

      setState(() {

        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF3E9D7),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // ---------------- HEADER ----------------

                Row(

                  children: [

                    IconButton(

                      onPressed: () {

                        Navigator.pop(
                          context,
                        );
                      },

                      icon: const Icon(

                        Icons.arrow_back,

                        size: 35,

                        color: Colors.black54,
                      ),
                    ),

                    Expanded(

                      child: Column(

                        children: [

                          Image.asset(

                            'assets/logo2.png',

                            width: 120,
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(

                            "Nuevo reporte",

                            style: TextStyle(

                              fontSize: 28,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const CircleAvatar(

                      radius: 25,

                      backgroundImage:
                      AssetImage(
                        'assets/perfil.png',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ---------------- FOTO ----------------

                Container(

                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(15),

                  decoration: BoxDecoration(

                    color:
                    Colors.grey.shade300,

                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: Column(

                    children: [

                      imagenSeleccionada !=
                          null

                          ? ClipRRect(

                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),

                        child: Image.file(

                          imagenSeleccionada!,

                          height: 180,

                          width:
                          double.infinity,

                          fit: BoxFit.cover,
                        ),
                      )

                          : Image.asset(

                        'assets/camara.png',

                        width: 90,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,

                        children: [

                          ElevatedButton(

                            style:
                            ElevatedButton
                                .styleFrom(

                              backgroundColor:
                              const Color(
                                0xFF556B2F,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  15,
                                ),
                              ),
                            ),

                            onPressed:
                            tomarFoto,

                            child:
                            const Text(

                              "Tomar foto",

                              style:
                              TextStyle(
                                color:
                                Colors
                                    .white,
                              ),
                            ),
                          ),

                          ElevatedButton(

                            style:
                            ElevatedButton
                                .styleFrom(

                              backgroundColor:
                              const Color(
                                0xFFB7AA8B,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  15,
                                ),
                              ),
                            ),

                            onPressed:
                            subirImagen,

                            child:
                            const Text(

                              "Subir imagen",

                              style:
                              TextStyle(
                                color:
                                Colors
                                    .white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------- UBICACIÓN ----------------

                const Row(

                  children: [

                    Icon(

                      Icons.location_on,

                      color: Colors.red,
                    ),

                    SizedBox(width: 10),

                    Text(

                      "Ubicación precisa",

                      style: TextStyle(

                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Column(

                  children: [

                    TextField(

                      controller: ubicacionController,

                      onChanged: (value) {

                        usarGps = false;
                      },

                      decoration: InputDecoration(

                        hintText: "Ingresa la ubicación",

                        filled: true,

                        fillColor: Colors.grey.shade300,

                        prefixIcon: const Icon(

                          Icons.location_on,

                          color: Colors.red,
                        ),

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(15),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton.icon(

                        style: ElevatedButton.styleFrom(

                          backgroundColor: const Color(0xFF556B2F),
                        ),

                        onPressed: () async {

                          setState(() {

                            usarGps = true;
                          });

                          await obtenerUbicacion();

                          if (mounted) {

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(

                                content: Text(
                                  "Ubicación GPS actualizada",
                                ),
                              ),
                            );
                          }
                        },

                        icon: const Icon(

                          Icons.gps_fixed,

                          color: Colors.white,
                        ),

                        label: const Text(

                          "Usar mi ubicación GPS",

                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton.icon(

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.orange,
                        ),

                        onPressed: () {

                          setState(() {

                            usarGps = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(

                            const SnackBar(

                              content: Text(
                                "Se usará la dirección escrita",
                              ),
                            ),
                          );
                        },

                        icon: const Icon(

                          Icons.edit_location_alt,

                          color: Colors.white,
                        ),

                        label: const Text(

                          "Usar dirección escrita",

                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

// ---------------- DESCRIPCIÓN ----------------

                const Text(

                  "Describe el problema",

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(

                  controller: descripcionController,

                  maxLength: 100,

                  maxLines: 4,

                  decoration: InputDecoration(

                    hintText: "Da una breve descripción...",

                    filled: true,

                    fillColor: Colors.grey.shade300,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

// ---------------- TIPO ----------------

                const Text(

                  "Tipo de Problema",

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

                  children: [

                    botonTipo("Basura"),

                    botonTipo("Escombro"),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------------- BOTÓN ENVIAR ----------------

                SizedBox(

                  width: double.infinity,

                  height: 60,

                  child: ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(
                        0xFF6AA84F,
                      ),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),

                    onPressed:
                    cargando
                        ? null
                        : enviarReporte,

                    child:
                    cargando

                        ? const CircularProgressIndicator(
                      color:
                      Colors.white,
                    )

                        : const Row(

                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                      children: [

                        Text(

                          "Enviar Reporte",

                          style:
                          TextStyle(

                            fontSize:
                            24,

                            color:
                            Colors.black,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        SizedBox(
                          width: 15,
                        ),

                        Icon(

                          Icons.recycling,

                          color:
                          Colors.black,

                          size: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
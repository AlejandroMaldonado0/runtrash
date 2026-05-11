import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // ---------------- CONTROLADORES ----------------

  final nombreController = TextEditingController();

  final emailController = TextEditingController();

  final passController = TextEditingController();

  final confirmController = TextEditingController();

  final codigoEmpresaController = TextEditingController();

  final nitController = TextEditingController();

  // ---------------- TIPO USUARIO ----------------

  String tipo = "Ciudadano";

  // ---------------- BOTONES ----------------

  Widget botonTipo(String texto) {

    bool activo = tipo == texto;

    return Expanded(
      child: GestureDetector(

        onTap: () {

          setState(() {
            tipo = texto;
          });
        },

        child: Container(

          margin: const EdgeInsets.symmetric(horizontal: 5),

          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(

            color: activo
                ? const Color(0xFF2E7D61)
                : const Color(0xFF2E7D61).withOpacity(0.4),

            borderRadius: BorderRadius.circular(20),
          ),

          child: Center(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CAMPOS ----------------

  Widget campo(
      String hint,
      TextEditingController controller, {
        bool oculto = false,
      }) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 15),

      child: TextField(

        controller: controller,

        obscureText: oculto,

        decoration: InputDecoration(

          hintText: hint,

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(30),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------------- REGISTRAR ----------------

  Future<void> registrar() async {

    // VALIDAR CONTRASEÑAS

    if (passController.text != confirmController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden"),
        ),
      );

      return;
    }

    try {

      // 🔹 CREAR USUARIO EN FIREBASE AUTH

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(

        email: emailController.text.trim(),

        password: passController.text.trim(),
      );

      // 🔹 UID

      String uid = userCredential.user!.uid;

      // 🔹 GUARDAR EN FIRESTORE

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .set({

        "uid": uid,

        "nombre": nombreController.text.trim(),

        "email": emailController.text.trim(),

        "tipo": tipo,

        // 🔹 OPERARIO

        "codigo_empresa":
        tipo == "Operario"
            ? codigoEmpresaController.text.trim()
            : "",

        // 🔹 EMPRESA

        "nit_empresa":
        tipo == "Empresa"
            ? nitController.text.trim()
            : "",
      });

      // 🔹 MENSAJE

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario registrado correctamente"),
        ),
      );

      // 🔹 VOLVER LOGIN

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String mensaje = "Ocurrió un error";

      if (e.code == 'email-already-in-use') {
        mensaje = "El correo ya está registrado";
      }

      else if (e.code == 'weak-password') {
        mensaje = "La contraseña es muy débil";
      }

      else if (e.code == 'invalid-email') {
        mensaje = "Correo inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFCBB89D),

      body: Stack(

        children: [

          // 🔹 FONDO

          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              opacity: const AlwaysStoppedAnimation(0.35),
            ),
          ),

          // 🔹 CONTENIDO

          SafeArea(

            child: SingleChildScrollView(

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Column(

                  children: [

                    const SizedBox(height: 10),

                    // 🔹 LOGO

                    Image.asset(
                      'assets/logo2.png',
                      width: 220,
                    ),

                    const SizedBox(height: 20),

                    // 🔹 SELECTOR

                    Row(
                      children: [

                        botonTipo("Ciudadano"),

                        botonTipo("Operario"),

                        botonTipo("Empresa"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🔹 CAMPOS

                    campo(
                      "Nombre usuario",
                      nombreController,
                    ),

                    campo(
                      "Email",
                      emailController,
                    ),

                    campo(
                      "Contraseña",
                      passController,
                      oculto: true,
                    ),

                    campo(
                      "Repita la contraseña",
                      confirmController,
                      oculto: true,
                    ),

                    // 🔹 SOLO OPERARIO

                    if (tipo == "Operario")

                      campo(
                        "Código empresa",
                        codigoEmpresaController,
                      ),

                    // 🔹 SOLO EMPRESA

                    if (tipo == "Empresa")

                      campo(
                        "NIT empresa",
                        nitController,
                      ),

                    const SizedBox(height: 20),

                    // 🔹 BOTÓN

                    SizedBox(

                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton(

                        onPressed: registrar,

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.orange,

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),

                        child: const Text(
                          "Registrarme",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 VOLVER LOGIN

                    GestureDetector(

                      onTap: () {

                        Navigator.pop(context);
                      },

                      child: const Text(

                        "Ya tengo cuenta",

                        style: TextStyle(

                          color: Colors.white,

                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
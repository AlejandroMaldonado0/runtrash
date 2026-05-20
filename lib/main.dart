import 'package:flutter/material.dart';
import 'screens/ciudadano_screen.dart';
import 'screens/operario_screen.dart';
import 'screens/empresa_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const RuntrashApp());
}
class RuntrashApp extends StatelessWidget {
  const RuntrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      routes: {

        "/login": (context) =>
        const SplashScreen(),

        "/ciudadano": (context) =>
        const CiudadanoScreen(),

        "/empresa": (context) =>
        const EmpresaScreen(),

        "/operario": (context) =>
        const OperarioScreen(),
      },
    );
  }
}
// -------------------- SPLASH --------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D61),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset('assets/logo.png', width: 300),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Comenzar"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- LOGIN --------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String tipo = "Ciudadano";

  // 1. DECLARACIÓN DE CONTROLADORES
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  // 2. LIMPIEZA DE CONTROLADORES
  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nitController.dispose();
    codigoController.dispose();
    super.dispose();
  }

  Widget botonTipo(String texto) {
    bool activo = tipo == texto;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tipo = texto),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activo ? const Color(0xFF2E7D61) : const Color(0xFF2E7D61).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(texto, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // Widget de campo de texto actualizado para usar controladores
  Widget campo(String hint, TextEditingController controller, {bool oculto = false}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBB89D),
      body: Stack(
        children: [
          // FONDO
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              opacity: const AlwaysStoppedAnimation(0.35),
            ),
          ),

          // CONTENIDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView( // Evita error de espacio con el teclado
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset('assets/logo2.png', width: 200),
                    const SizedBox(height: 30),

                    // SELECTOR DE TIPO
                    Row(
                      children: [
                        botonTipo("Ciudadano"),
                        botonTipo("Operario"),
                        botonTipo("Empresa"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // CAMPOS DE TEXTO
                    campo("email", emailController),
                    campo("contraseña", passController, oculto: true),

                    if (tipo == "Empresa") campo("NIT empresa", nitController),
                    if (tipo == "Operario") campo("código empresa", codigoController),

                    const SizedBox(height: 20),

                    // BOTÓN LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            // 🔹 LOGIN FIREBASE
                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passController.text.trim(),
                            );

                            // 🔹 OBTENER UID Y DATOS
                            String uid = userCredential.user!.uid;
                            DocumentSnapshot userData = await FirebaseFirestore.instance
                                .collection("usuarios")
                                .doc(uid)
                                .get();

                            String tipoUsuario = userData['tipo'];

                            // 🔹 REDIRECCIÓN SEGÚN TIPO
                            if (tipoUsuario == "Ciudadano") {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CiudadanoScreen()));
                            } else if (tipoUsuario == "Operario") {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OperarioScreen()));
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmpresaScreen()));
                            }

                          } on FirebaseAuthException catch (e) {
                            // 🔹 MANEJO DE ERRORES DETALLADO
                            String mensaje = "Error en el login";

                            if (e.code == 'user-not-found') {
                              mensaje = "Usuario no registrado";
                            } else if (e.code == 'wrong-password') {
                              mensaje = "Contraseña incorrecta";
                            } else if (e.code == 'invalid-email') {
                              mensaje = "Correo con formato inválido";
                            } else if (e.code == 'invalid-credential') {
                              mensaje = "Correo o contraseña incorrectos";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ocurrió un error inesperado")),
                            );
                          }
                        },
                        child: const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LÍNEA DIVISORA "OR"
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.white)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // BOTONES SOCIALES
                    socialBtn("Continue with Google"),
                    const SizedBox(height: 10),
                    socialBtn("Continue with Facebook"),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text(
                        "No tiene cuenta? registrarse",
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
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

  // Widget auxiliar para botones sociales
  Widget socialBtn(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
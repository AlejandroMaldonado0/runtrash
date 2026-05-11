import 'package:flutter/material.dart';
import 'screens/ciudadano_screen.dart';
import 'screens/operario_screen.dart';
import 'screens/empresa_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/register_screen.dart';

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
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget campo(String hint, {bool oculto = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
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
              child: Column(
                children: [

                  const SizedBox(height: 10),

                  // LOGO
                  Image.asset('assets/logo2.png', width: 200),

                  const SizedBox(height: 30),

                  // SELECTOR
                  Row(
                    children: [
                      botonTipo("Ciudadano"),
                      botonTipo("Operario"),
                      botonTipo("Empresa"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // CAMPOS
                  campo("email"),
                  campo("contraseña", oculto: true),

                  if (tipo == "Empresa") campo("NIT empresa"),
                  if (tipo == "Operario") campo("código empresa"),

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
                      onPressed: () {
                        if (tipo == "Ciudadano") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CiudadanoScreen()),
                          );
                        } else if (tipo == "Operario") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OperarioScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EmpresaScreen()),
                          );
                        }
                      },
                      child: const Text("Log In"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OR
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Or",
                            style: TextStyle(color: Colors.green)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // GOOGLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(child: Text("Continue with Google")),
                  ),

                  // FACEBOOK
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(child: Text("Continue with Facebook")),
                  ),

                  const Spacer(),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },

                    child: const Text(

                      "No tiene cuenta? registrarse",

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
        ],
      ),
    );
  }
}
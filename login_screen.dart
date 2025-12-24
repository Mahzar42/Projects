import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kadin/screens/auth/register_screen.dart';
import 'package:kadin/screens/home/Nevication_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si guul leh ayaad u gashay!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationWidget()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Waxaa dhacay qalad, fadlan hubi xogtaada.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Email-ka lama helin.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Furaha sirta ah waa khalad.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool isValidGmail(String email) {
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email);
  }

  void sendPasswordResetEmail(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Link-ga ayaa lagu direy email-kaaga si aad u badsho furaha sirta ah.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Qalad: ${e.toString()}')));
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    bool isPhone = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : obscure,
      keyboardType: type,
      inputFormatters:
          isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF141E30), Color(0xFF243B55)],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            Gap(60),
                            Image.asset('images/logoappbar.png', height: 100),
                            const Gap(16),
                            const Text(
                              'Soo dhawoow 👋',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(6),
                            const Text(
                              'Soo gal si aad u sii wadato',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const Gap(32),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: emailController,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Colors.white,
                                      ),
                                      labelText: 'Email',
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      filled: true,
                                      fillColor: Colors.black26,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon:
                                          emailController.text.isEmpty
                                              ? null
                                              : Icon(
                                                isValidGmail(
                                                      emailController.text
                                                          .trim(),
                                                    )
                                                    ? Icons.check_circle
                                                    : Icons.error,
                                                color:
                                                    isValidGmail(
                                                          emailController.text
                                                              .trim(),
                                                        )
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                      errorText:
                                          emailController.text.isEmpty
                                              ? null
                                              : (isValidGmail(
                                                    emailController.text.trim(),
                                                  )
                                                  ? null
                                                  : 'Fadlan geli Gmail sax ah'),
                                    ),
                                  ),
                                  const Gap(20),
                                  _field(
                                    controller: passwordController,
                                    label: 'Furaha Sirta',
                                    icon: Icons.lock,
                                    isPassword: true,
                                  ),
                                  const Gap(10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            final resetEmailController =
                                                TextEditingController();
                                            return AlertDialog(
                                              title: const Text(
                                                'Ma iloowday Furaha Sirta?',
                                              ),
                                              content: TextField(
                                                controller:
                                                    resetEmailController,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Email',
                                                    ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    final email =
                                                        resetEmailController
                                                            .text
                                                            .trim();
                                                    Navigator.pop(context);
                                                    sendPasswordResetEmail(
                                                      context,
                                                      email,
                                                    );
                                                  },
                                                  child: const Text('Dir'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text(
                                        'Ma iloowday Furaha Sirta?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                  const Gap(20),
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00C6FF,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: loginUser,
                                          child: const Text(
                                            'Gal',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            const Gap(24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Ma haysto account? ',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Diiwaangeli',
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

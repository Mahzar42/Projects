import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kadin/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================
// SCREEN: RegisterScreen
// Sharaxaad: Screen-kan waxa uu qaabilsan yahay
// is-diiwaan gelinta (Register) isticmaalaha
// UI-ga waa la mid LoginScreen
// ======================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final gobalController = TextEditingController();
  final degmoController = TextEditingController();

  bool isLoading = false;
  bool isChecked = false;
  bool isPasswordHidden = true;

  bool isValidGmail(String email) {
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email);
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final gobal = gobalController.text.trim();
    final degmo = degmoController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        gobal.isEmpty ||
        degmo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan buuxi dhammaan Xogta!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      const defaultImage = 'images/profile.jpg';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'gobal': gobal,
        'degmo': degmo,
        'role': 'user',
        'image_url': defaultImage,
        'created_at': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Qalad: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? isPasswordHidden : false,
      keyboardType: type,
      inputFormatters: inputFormatters,
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
            obscure
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
    return Scaffold(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Gap(60),
                          Image.asset('images/logoappbar.png', height: 100),
                          const Gap(16),
                          const Text(
                            'Diiwaangeli ✍️',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(8),
                          const Text(
                            'Samee akoon cusub si aad u bilowdo',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const Gap(30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              children: [
                                _field(
                                  controller: nameController,
                                  label: 'Magaca',
                                  icon: Icons.person,
                                ),
                                const Gap(16),
                                _field(
                                  controller: phoneController,
                                  label: 'Taleefan',
                                  icon: Icons.phone,
                                  type: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const Gap(16),
                                _field(
                                  controller: gobalController,
                                  label: 'Gobol / Magaalo',
                                  icon: Icons.location_city,
                                ),
                                const Gap(16),
                                _field(
                                  controller: degmoController,
                                  label: 'Degmo / Xaafad',
                                  icon: Icons.place,
                                ),
                                const Gap(16),
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
                                                    emailController.text.trim(),
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
                                const Gap(16),
                                _field(
                                  controller: passwordController,
                                  label: 'Furaha Sirta',
                                  icon: Icons.lock,
                                  obscure: true,
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          isChecked = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.lightBlueAccent,
                                    ),
                                    Expanded(
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          const Text(
                                            'Waxaan aqbalay ',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF1E293B,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              22,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.6,
                                                                ),
                                                            blurRadius: 20,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  8,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            decoration: const BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                    0xFF42A5F5,
                                                                  ),
                                                                  Color(
                                                                    0xFF0D47A1,
                                                                  ),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                    top:
                                                                        Radius.circular(
                                                                          22,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              children: const [
                                                                Icon(
                                                                  Icons.policy,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  'Sharciga & Shuruudaha',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: SingleChildScrollView(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    18,
                                                                  ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: const [
                                                                  Text(
                                                                    '📝 Sharciga Isdiiwaan Galinta:',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .amber,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  Text(
                                                                    '1. Taleefoon sax ah oo adiga kuu gaar ah ayaa lagama maarmaan ah.\n'
                                                                    '2. Magacaaga waa in uu noqdaa mid sax ah oo la mid ah kan ku qoran numberkaaga.\n'
                                                                    '3. Magaalada/Gobolka iyo xaafadda aad joogto waa in si sax ah loo qoro.\n'
                                                                    '4. Waa in aad si gaar ah u xafiddaa Gmail-kaaga iyo furaha sirta ah.\n'
                                                                    '5. Gmail-ka waa in uu noqdaa mid sax ah si aad u hesho fariimo iyo warbixin dheeraad ah.\n'
                                                                    '6. Waa mamnuuc in aad isticmaasho xog qof kale leeyahay adiga oo aan oggolaansho haysan.\n'
                                                                    '7. Hal akoon oo kaliya ayaa loo oggol yahay hal isticmaalaha.\n'
                                                                    '8. Haddii aad bixiso xog khaldan, adeegga waa la joojin karaa.\n'
                                                                    '9. Mas’uuliyadda ilaalinta akoonkaaga adigaa iska leh.\n'
                                                                    '10. Haddii aad jebiso shuruudahan, akoonkaaga waa la xayiri .',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white70,
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  14,
                                                                ),
                                                            child: Column(
                                                              children: [
                                                                const Divider(
                                                                  color:
                                                                      Colors
                                                                          .white24,
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .lightBlueAccent,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                    ),
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          40,
                                                                      vertical:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  child: const Text(
                                                                    'Waan Fahmay',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              'shuruudaha & siyaasadda',
                                              style: TextStyle(
                                                color: Colors.lightBlueAccent,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (!isChecked) {
                                            Flushbar(
                                              message:
                                                  'Fadlan marka hore aqbal shuruudaha',
                                              backgroundColor: Colors.redAccent,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ).show(context);
                                            return;
                                          }
                                          registerUser();
                                        },
                                        child: const Text(
                                          'Diiwaangeli',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Horey ayaan u lahaa akoon? ',
                                style: TextStyle(color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Gal',
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
    );
  }
}

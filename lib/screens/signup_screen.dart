import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_flutter/resources/auth_methods.dart';
import 'package:instagram_clone_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone_flutter/responsive/responsive_layout.dart';
import 'package:instagram_clone_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_clone_flutter/screens/login_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() => _image = img);
    }
  }

  void _signUpUser() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      showSnackBar(context, 'Please select a profile image');
      return;
    }

    setState(() => _isLoading = true);
    final res = await AuthMethods().signUpUser(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      file: _image!,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res == 'success') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/ic_instagram.svg',
                      color: primaryColor, height: 64),
                  const SizedBox(height: 48),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: _image != null
                            ? MemoryImage(_image!) as ImageProvider
                            : const NetworkImage(
                                'https://i.stack.imgur.com/l60Hf.png'),
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a username'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter an email';
                      }
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      return regex.hasMatch(v.trim())
                          ? null
                          : 'Enter a valid email';
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v != null && v.length >= 6
                        ? null
                        : 'Password must be at least 6 characters',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your bio',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter your bio' : null,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 32),
                  InkWell(
                    onTap: _signUpUser,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        color: blueColor,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: primaryColor,
                            ))
                          : const Center(child: Text('Sign up')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: const Text(' Login.',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

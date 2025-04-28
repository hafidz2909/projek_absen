import 'package:absen_sqflite/db_helper/database_helper.dart';
import 'package:absen_sqflite/models/model_user.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void register() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        name: nameController.text,
        email: emailController.text,
        password: passController.text,
      );
      try {
        await dbHelper.insertUser(newUser);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Register berhasil!")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Email sudah terdaftar!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Nama',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.length < 6 ? 'Minimal 6 karakter' : null,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Register"),
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

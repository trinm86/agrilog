// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_app/util/toast.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class EmailPassPage extends StatefulWidget {
  const EmailPassPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmailPassPageState createState() => _EmailPassPageState();
}

class _EmailPassPageState extends State<EmailPassPage> {
  bool _isPasswordVisible = false;
  late bool _isDisable = false;
  // Tạo GlobalKey cho Form
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> _email = GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> _pass = GlobalKey<FormFieldState<String>>();
  
  // Đăng ký người dùng
  Future<void> signUp(BuildContext context, String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      showToast('Đăng ký thành công');
      setState(() {
        _isDisable = !_isDisable;
      });
    } catch (e) {
      showToast('Lỗi đăng ký: $e');
      setState(() {
        _isDisable = !_isDisable;
      });
    }
  }

  // Đăng nhập người dùng
  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      showToast('Đăng nhập thành công');
      setState(() {
        _isDisable = !_isDisable;
      });
    } catch (e) {
      showToast('Lỗi đăng nhập: $e');
      setState(() {
        _isDisable = !_isDisable;
      });
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Get the currently signed-in user
      User? user = auth.currentUser;

      if (user != null) {
        // Delete the user's account
        await user.delete();

        // Notify the user
        showToast('Tài khoản đã được xóa');

        // Optionally sign out the user
        await auth.signOut();
      } else {
        showToast('Không tìm thấy tài khoản');
      }
      setState(() {
        _isDisable = !_isDisable;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showToast('Lỗi xóa tài khoản: Đăng nhập lại để xác thực');

        // Prompt the user to reauthenticate
        // Example: Use auth.currentUser?.reauthenticateWithCredential() here
      } else {
        showToast('Lỗi xóa tài khoản: $e');
      }
      setState(() {
        _isDisable = !_isDisable;
      });
    } catch (e) {
      showToast('Lỗi xóa tài khoản: $e');
      setState(() {
        _isDisable = !_isDisable;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  key: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: _pass,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8,),
                ElevatedButton(
                  onPressed: _isDisable ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isDisable = !_isDisable;
                      });
                      signUp(context, _email.currentState?.value ?? '', _pass.currentState?.value ?? '');
                    }                  
                  },
                  child: !_isDisable ? const Text("Đăng ký") : const CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isDisable ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isDisable = !_isDisable;
                      });
                      signIn(context, _email.currentState?.value ?? '', _pass.currentState?.value ?? '');
                    } 
                  },
                  child: !_isDisable ? const Text("Đăng nhập") : const CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isDisable ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isDisable = !_isDisable;
                      });
                      deleteAccount(context);
                    } 
                  },
                  child: !_isDisable ? const Text("Xóa Account") : const CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            )
          ),
        )
      )
    );
  }
}
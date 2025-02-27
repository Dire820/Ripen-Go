import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Import the LoginScreen
import 'auth_service.dart'; // Import the AuthService

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Added loading state

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController(); // Added birthday controller

  final AuthService _authService = AuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Color(0xFF347928)), onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst)),
      ),
      body: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF347928))),
                SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: "First Name"),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: "Last Name"),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your last name' : null,
                ),
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: "Birthday",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _birthdayController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your birthday' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                ),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: InputDecoration(labelText: "Mobile Number"),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your mobile number' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) => setState(() => _isChecked = value!),
                      activeColor: Color(0xFF347928),
                    ),
                    Text("I agree to the Terms & Conditions"),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCCD2A),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Color(0xFF347928)) // Show loader while signing up
                      : Center(child: Text("Sign Up", style: TextStyle(color: Color(0xFF347928), fontSize: 18, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF99B994), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or with"),
                    ),
                    Expanded(child: Divider(color: Color(0xFF99B994), thickness: 1)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF347928))),
                      onPressed: () {},
                      icon: Icon(Icons.facebook, color: Color(0xFF347928)),
                      label: Text("Facebook", style: TextStyle(color: Color(0xFF347928), fontSize: 12)),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF347928))),
                      onPressed: () {},
                      icon: Icon(Icons.g_translate, color: Color(0xFF347928)),
                      label: Text("Google", style: TextStyle(color: Color(0xFF347928), fontSize: 12)),
                    ),
                  ],
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                    child: Text("Already have an account? Log in", style: TextStyle(color: Color(0xFF347928))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isChecked) {
      _showSnackbar('You must agree to the Terms & Conditions', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? result = await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthday: _birthdayController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
      );

      if (result != null && result.startsWith("User registered")) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        _showSnackbar(result ?? 'An error occurred. Please try again.', Colors.red);
      }
    } catch (e) {
      _showSnackbar('An error occurred. Please try again.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
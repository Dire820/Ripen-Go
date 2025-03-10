import 'package:flutter/material.dart';
import 'package:ripengo/admin/admin_dashboard.dart';
import 'package:ripengo/user/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'mysql_auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Added loading state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? result = await MySQLAuthService().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null && result['error'] == null) {
        print("resulta ng mama mo ");
        print(result);
        MySQLAuthService.userData = result;
        int role = result['role'];
        if (role == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(userRole: 0, userData: {})),
          );
        } else if (role == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AdminDashboard(
                    userRole: role, // Pass the integer role directly
                    userData: {
                      'id':
                          result['user_id'], // Make sure to use the correct key
                      'email': result['email'],
                      'firstName': result['firstName'],
                      'lastName': result['lastName'],
                      'role': result['role'],
                      'status': result['status'],
                    },
                  ),
            ),
          );
        }
      } else {
        _showSnackbar(result?['error'] ?? 'Invalid credentials.', Colors.red);
      }

      // Save the "Remember me" state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _isChecked);
    } catch (e) {
      print("🔥 MySQL Auth Error: $e"); // Debugging

      String message = 'Invalid Log in Credentials. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF347928)),
          onPressed:
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset("assets/logo2.png", height: 60)),
                SizedBox(height: 10),
                Text(
                  "Hi, Welcome to RipeN-Go",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF347928),
                  ),
                ),
                SizedBox(height: 20),
                Text("Email address or Phone number"),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Your email or phone number",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                      activeColor: Color(0xFF347928),
                    ),
                    Text("Remember me"),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: Color(0xFF347928)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCCD2A),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              _signInWithEmailAndPassword();
                            }
                          },
                  child:
                      _isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF347928),
                            ),
                          )
                          : Center(
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                color: Color(0xFF347928),
                                fontSize: 18,
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFF99B994), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or with"),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFF99B994), thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF347928)),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.facebook, color: Color(0xFF347928)),
                      label: Text(
                        "Facebook",
                        style: TextStyle(
                          color: Color(0xFF347928),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF347928)),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.g_translate, color: Color(0xFF347928)),
                      label: Text(
                        "Google",
                        style: TextStyle(
                          color: Color(0xFF347928),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Color(0xFF347928)),
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

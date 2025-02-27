import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, UserCredential;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Added loading state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save the "Remember me" state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _isChecked);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("🔥 Firebase Auth Error Code: ${e.code}"); // Debugging

      String message;
      switch (e.code) {
        case 'user-not-found': // Sometimes Firebase returns 'INVALID_LOGIN_CREDENTIALS' instead
        case 'INVALID_LOGIN_CREDENTIALS':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Invalid Log in Credentials. Please try again.'; // Show the error code
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
                Center(
                  child: Image.asset("assets/logo2.png", height: 60),
                ),
                SizedBox(height: 10),
                Text(
                  "Hi, Welcome to RipeN-Go",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF347928)),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                      },
                      child: Text("Forgot password?", style: TextStyle(color: Color(0xFF347928))),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCCD2A),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _signInWithEmailAndPassword();
                          }
                        },
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF347928)))
                      : Center(
                          child: Text(
                            "Log in",
                            style: TextStyle(color: Color(0xFF347928), fontSize: 18),
                          ),
                        ),
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
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF347928)),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.facebook, color: Color(0xFF347928)),
                      label: Text("Facebook", style: TextStyle(color: Color(0xFF347928), fontSize: 12)),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF347928)),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.g_translate, color: Color(0xFF347928)),
                      label: Text("Google", style: TextStyle(color: Color(0xFF347928), fontSize: 12)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                    },
                    child: Text("Don't have an account? Sign up", style: TextStyle(color: Color(0xFF347928))),
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

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBE6),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forgot password?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF347928)),
            ),
            SizedBox(height: 10),
            Text("Don't worry! It happens. Please enter the email associated with your account."),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Enter your email address or number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCCD2A),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: Center(
                child: Text("Send code", style: TextStyle(color: Color(0xFF347928), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text("Remember password? Log in", style: TextStyle(color: Color(0xFF347928))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
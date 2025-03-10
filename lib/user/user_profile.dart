import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ripengo/login_page.dart';
import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter
import 'package:shared_preferences/shared_preferences.dart';
import '../header_section.dart'; // Import HeaderSection

class UserProfilePage extends StatefulWidget {
  final int userRole;
  final Map<String, dynamic> userData;

  const UserProfilePage({
    super.key,
    required this.userRole,
    required this.userData,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Add controllers for editing
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController emailController;
  late TextEditingController birthdayController;
  late TextEditingController mobileController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    emailController = TextEditingController();
    birthdayController = TextEditingController();
    mobileController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Initialize with basic user data
    userData = {
      'user_id': widget.userData['id'],
      'firstname': widget.userData['firstname'],
      'lastname': widget.userData['lastname'],
      'email': widget.userData['email'],
      'status': widget.userData['status'],
      'role': widget.userData['role'],
      'birthday': '',
      'mobile_number': '',
    };

    // Set initial values and fetch complete data
    _setEditControllers();
    _fetchUserData();
  }

  @override
  void dispose() {
    // Dispose controllers
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _setEditControllers() {
    firstnameController.text = userData?['firstname'] ?? '';
    lastnameController.text = userData?['lastname'] ?? '';
    emailController.text = userData?['email'] ?? '';
    birthdayController.text = userData?['birthday'] ?? '';
    mobileController.text = userData?['mobile_number'] ?? '';
  }

  Future<void> _fetchUserData() async {
    try {
      print('Fetching data for user ID: ${widget.userData['id']}');

      final response = await http.get(
        Uri.parse(
          'http://localhost/ripen_go/backend/get_users.php?user_id=${widget.userData['id']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched user data: $data'); // Debug print

        if (!data.containsKey('error')) {
          setState(() {
            userData = {
              'user_id': widget.userData['id'],
              'firstname': data['firstname'] ?? widget.userData['firstname'],
              'lastname': data['lastname'] ?? widget.userData['lastname'],
              'email': data['email'] ?? widget.userData['email'],
              'status':
                  data['status'] ?? widget.userData['status'], // This will be 1 or 0
              'role': data['role'] ?? widget.userData['role'],
              'birthday': data['birthday'] ?? '',
              'mobile_number': data['mobile_number'] ?? '',
            };
          });
          _setEditControllers();
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Changes'),
        content: Text(
          'Are you sure you want to save the changes to your profile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final Map<String, String> body = {
        'user_id': userData!['user_id'].toString(),
        'firstname': firstnameController.text,
        'lastname': lastnameController.text,
        'email': emailController.text,
        'birthday': birthdayController.text,
        'mobile_number': mobileController.text,
      };

      if (passwordController.text.isNotEmpty) {
        body['password'] = passwordController.text;
      }

      final response = await http.post(
        Uri.parse('http://localhost/ripen_go/backend/update_profile.php'),
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          // Update the userData without fetching from server
          setState(() {
            userData = {
              ...userData!,
              'firstname': firstnameController.text,
              'lastname': lastnameController.text,
              'email': emailController.text,
              'birthday': birthdayController.text,
              'mobile_number': mobileController.text,
            };
            isEditing = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    double topMargin = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: topMargin),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF347928)),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF347928),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (widget.userRole != 0) {
      return Scaffold(
        body: Center(child: Text('Access Denied: User privileges required')),
      );
    }

    // User content here
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0), // Set the height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF347928),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    HeaderSection(title: "User Profile"), // Use HeaderSection with title
                    Positioned(
                      right: 0,
                      top: 2,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(isEditing ? Icons.save : Icons.edit, color: const Color(0xFFFCCD2A)),
                            onPressed: () async {
                              if (isEditing) {
                                _updateProfile();
                              } else {
                                // Show confirmation dialog
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Edit Profile'),
                                    content: Text('Are you sure you want to edit your profile?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Edit'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  setState(() {
                                    isEditing = true;
                                    _setEditControllers();
                                  });
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: const Color(0xFFFCCD2A)),
                            onPressed: () async {
                              // Show confirmation dialog
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Logout'),
                                  content: Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Logout'),
                                    ),
                                  ],
                                ),
                              );

                              // Handle logout if confirmed
                              if (confirm == true) {
                                // Clear any stored credentials/session
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.clear();

                                // Navigate to login page
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isEditing) ...[
                          _buildProfileItem(
                            icon: Icons.person,
                            label: 'Name',
                            value: '${userData!['firstname']} ${userData!['lastname']}',
                            topMargin: 180,
                          ),
                          _buildProfileItem(
                            icon: Icons.email,
                            label: 'Email',
                            value: userData!['email'].toString(),
                          ),
                          _buildProfileItem(
                            icon: Icons.cake,
                            label: 'Birthday',
                            value: userData!['birthday'] ?? 'Not set',
                          ),
                          _buildProfileItem(
                            icon: Icons.phone,
                            label: 'Mobile Number',
                            value: userData!['mobile_number'] ?? 'Not set',
                          ),
                          _buildProfileItem(
                            icon: Icons.security,
                            label: 'Role',
                            value: userData!['role'] == 1 ? 'Admin' : 'User',
                          ),
                          _buildProfileItem(
                            icon: Icons.check_circle,
                            label: 'Status',
                            value: (userData!['status'] == 1 || userData!['status'] == '1') ? 'Active' : 'Inactive',
                          ),
                        ] else ...[
                          // Edit mode widgets
                          _buildEditField(
                            controller: firstnameController,
                            label: 'First Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                                return 'Only letters and spaces allowed';
                              }
                              return null;
                            },
                          ),
                          _buildEditField(
                            controller: lastnameController,
                            label: 'Last Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is required';
                              }
                              if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                                return 'Only letters and spaces allowed';
                              }
                              return null;
                            },
                          ),
                          _buildEditField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@') || !value.toLowerCase().endsWith('.com')) {
                                return 'Enter a valid email with @example.com';
                              }
                              return null;
                            },
                          ),
                          _buildEditField(
                            controller: mobileController,
                            label: 'Mobile Number',
                            icon: Icons.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
                                return 'Must be exactly 11 digits';
                              }
                              return null;
                            },
                          ),
                          // Keep the existing birthday field as is
                          _buildEditField(
                            controller: birthdayController,
                            label: 'Birthday',
                            icon: Icons.cake,
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                birthdayController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                          // Keep the existing password fields with their validations
                          _buildEditField(
                            controller: passwordController,
                            label: 'New Password (optional)',
                            icon: Icons.lock,
                            isPassword: true,
                            isRequired: false,
                          ),
                          _buildEditField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock,
                            isPassword: true,
                            isRequired: false,
                            validator: (value) {
                              if (passwordController.text.isNotEmpty && value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    bool isRequired = true,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF347928)),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF347928)),
          ),
        ),
        validator:
            validator ??
            (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }
}
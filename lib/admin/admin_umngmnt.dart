import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter
import '../header_section.dart'; // Import HeaderSection

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _showEditDialog(Map<String, dynamic> user) {
    TextEditingController firstnameController = TextEditingController(
      text: user['firstname'],
    );
    TextEditingController lastnameController = TextEditingController(
      text: user['lastname'],
    );
    TextEditingController emailController = TextEditingController(
      text: user['email'],
    );
    TextEditingController birthdayController = TextEditingController(
      text: user['birthday'],
    );
    TextEditingController mobileController = TextEditingController(
      text: user['mobile_number'],
    );

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstnameController,
                  decoration: InputDecoration(labelText: "First Name"),
                  maxLength: 15,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only letters are allowed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: lastnameController,
                  decoration: InputDecoration(labelText: "Last Name"),
                  maxLength: 15,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only letters are allowed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    } else if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: birthdayController,
                  decoration: InputDecoration(
                    labelText: "Birthday",
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF347928),
                    ), // Calendar icon with color
                  ),
                  readOnly: true, // Prevent manual text input
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            primaryColor: Color(
                              0xFF347928,
                            ), // Header background color
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFF347928), // Selected date color
                              onPrimary:
                                  Colors.white, // Text color on selected date
                              onSurface: Colors.black, // Default text color
                            ),
                            buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      // Format the selected date as YYYY-MM-DD
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      birthdayController.text = formattedDate;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a birthday';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mobileController,
                  decoration: InputDecoration(labelText: "Mobile Number"),
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a mobile number';
                    } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Mobile number must be 11 digits';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _editUser({
                    'user_id': user['user_id'],
                    'firstname': firstnameController.text,
                    'lastname': lastnameController.text,
                    'email': emailController.text,
                    'birthday': birthdayController.text,
                    'mobile_number': mobileController.text,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User edited successfully')),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/ripen_go/backend/fetch_all.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched data: $data');

        if (data is Map && data.containsKey('status')) {
          if (data['status'] == 'success') {
            final usersList = data['users'] as List;
            setState(() {
              users = usersList.map((user) => {
                'user_id': user['id']?.toString() ?? '',
                'firstname': user['firstName'] ?? '',
                'lastname': user['lastName'] ?? '',
                'email': user['email'] ?? '',
                'birthday': user['birthday'] ?? '',
                'mobile_number': user['mobile_number'] ?? '',
                'role': user['role']?.toString() ?? '2',  // Default to user role if null
                'status': user['status']?.toString() ?? '1',  // Default to active if null
              }).toList();
            });
            // Debug print to check status values
            print('Mapped users with status: ${users.map((u) => u['status']).toList()}');
          } else {
            print('Error from server: ${data['message']}');
            setState(() => users = []);
          }
        }
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => users = []);
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/ripen_go/backend/edit_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': user['user_id'],
          'firstname': user['firstname'],
          'lastname': user['lastname'],
          'email': user['email'],
          'birthday': user['birthday'],
          'mobile_number': user['mobile_number'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Edit Response: $data'); // Debugging statement

        if (data['status'] == 'success') {
          // Fixed response check
          print('User edited successfully');
          _fetchUsers(); // Refresh the user list
        } else {
          print('Failed to edit user: ${data['message']}');
        }
      } else {
        print('Failed to edit user: ${response.body}');
      }
    } catch (e) {
      print('Error editing user: $e');
    }
  }

  Future<void> _deleteUser(int? userId) async {
    if (userId == null || userId == 0) {
      print('Error: userId is null or invalid');
      return;
    }

    print("Deleting user with ID: $userId");

    try {
      final response = await http.post(
        Uri.parse('http://localhost/ripen_go/backend/delete_user.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': userId.toString()},
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('User deleted successfully');
          _fetchUsers();
        } else {
          print('Failed to delete user: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.account_circle, color: Color(0xFF347928)),
              const SizedBox(width: 8),
              const Text(
                'User Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF347928),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem(
                  icon: Icons.person,
                  label: 'Name',
                  value: '${user['firstname']} ${user['lastname']}',
                ),
                _buildProfileItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: user['email'],
                ),
                _buildProfileItem(
                  icon: Icons.cake,
                  label: 'Birthday',
                  value: user['birthday'],
                ),
                _buildProfileItem(
                  icon: Icons.phone,
                  label: 'Mobile Number',
                  value: user['mobile_number'],
                ),
                _buildProfileItem(
                  icon: Icons.security,
                  label: 'Role',
                  value: user['role'] == '1' ? 'Admin' : 'User',
                ),
                _buildProfileItem(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value:
                      user['status'] == '1'
                          ? 'Active'
                          : 'You were inactive for the past 3 months, status set to inactive',
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  label: 'Close',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditDialog(user); // Show the edit dialog
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteUser(int.tryParse(user['user_id']) ?? 0);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF347928),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF347928)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF347928),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                HeaderSection(title: "User Management"), // Use HeaderSection with title
                Padding(
                  padding: const EdgeInsets.all(10.0), // Adds 10px padding around the ListView
                  child: users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${user['firstname']} ${user['lastname']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Status: ${user['status'] == '1' ? 'Active' : 'Inactive'}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Role: ${user['role'] == '1' ? 'Admin' : 'User'}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8), // Space before the arrow
                                        const Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _showUserDetails(user),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../header_section.dart'; // Import HeaderSection

class Tip {
  final String title;
  final List<String> category;
  final String content;
  final DateTime createdAt;
  final DateTime lastEdited;
  final XFile? image;

  Tip({
    required this.title,
    required this.category,
    required this.content,
    required this.createdAt,
    required this.lastEdited,
    this.image,
  });
}

class AdminTipsPage extends StatefulWidget {
  @override
  _AdminTipsPageState createState() => _AdminTipsPageState();
}

class _AdminTipsPageState extends State<AdminTipsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  List<String> _category = [];
  String _content = '';
  XFile? _image;
  List<Tip> _tips = [];

  @override
  void initState() {
    super.initState();
    _fetchTips();
  }

  Future<void> _fetchTips() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/ripen_go/backend/tips.php'),
        body: {'action': 'get'},
      );

      if (response.statusCode == 200) {
        List<dynamic> tipsJson = json.decode(response.body);
        setState(() {
          _tips =
              tipsJson
                  .map(
                    (json) => Tip(
                      title: json['title'],
                      category: json['category'].split(','),
                      content: json['content'],
                      createdAt: DateTime.parse(json['created_at']),
                      lastEdited: DateTime.parse(json['last_edited']),
                      image:
                          json['photo'] != null ? XFile(json['photo']) : null,
                    ),
                  )
                  .toList();
        });
      } else {
        throw Exception('Failed to load tips');
      }
    } catch (error) {
      print('Fetch Tips Error: $error');
    }
  }

  Future<void> _saveTip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost/ripen_go/backend/tips.php'),
        );

        request.fields['action'] = 'add';
        request.fields['title'] = _title;
        request.fields['category'] = _category.join(',');
        request.fields['content'] = _content;

        if (_image != null) {
          request.files.add(
            await http.MultipartFile.fromPath('photo', _image!.path),
          );
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var result = json.decode(responseBody);

        if (response.statusCode == 200 && result['success']) {
          _fetchTips();
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tip saved successfully!')));
        } else {
          throw Exception(result['message'] ?? 'Unknown error occurred');
        }
      } catch (error) {
        print('Save Tip Error: $error');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _showAddTipModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Tip'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                    validator:
                        (value) => value!.isEmpty ? 'Enter a title' : null,
                    onSaved: (value) => _title = value!,
                  ),
                  SizedBox(height: 10),
                  Text('Category:'),
                  ..._buildCategoryCheckboxes(),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Content'),
                    validator:
                        (value) => value!.isEmpty ? 'Enter content' : null,
                    onSaved: (value) => _content = value!,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image (Optional)'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _saveTip, child: Text('Save Tip')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCategoryCheckboxes() {
    final categories = [
      'Banana',
      'Mango',
      'Papaya',
      'Ripe',
      'Unripe',
      'Rotten',
      'Overripe',
      'Nurture',
      'Tree',
      'Fertilizer',
      'Insecticide',
      'Propagation',
      'Soil',
      'Watering',
      'Pest Control',
      'Pruning',
      'Pollination',
      'Climate',
      'Harvesting',
      'Storage',
      'Planting',
    ];

    return categories.map((category) {
      return CheckboxListTile(
        title: Text(category),
        value: _category.contains(category),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _category.add(category);
            } else {
              _category.remove(category);
            }
          });
        },
      );
    }).toList();
  }

  void _showTipDetails(Tip tip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tip.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${tip.category.join(', ')}'),
                Text('Content: ${tip.content}'),
                if (tip.image != null) Image.file(File(tip.image!.path)),
                Text('Created At: ${tip.createdAt}'),
                Text('Last Edited: ${tip.lastEdited}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
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
                HeaderSection(title: "Manage Tips"), // Use HeaderSection with title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _tips.length,
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return Card(
                        child: ListTile(
                          title: Text(tip.title),
                          subtitle: Text('Category: ${tip.category.join(', ')}'),
                          onTap: () => _showTipDetails(tip),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTipModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

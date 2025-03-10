import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ripengo/user/fullscreenimage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderSection(),
                HomeBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Untitled-1.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Image.asset("assets/logo2.png", height: 80),
              Positioned(
                left: 0,
                top: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Image.asset("assets/logo2.png", height: 80, color: Colors.black.withOpacity(0.5)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Image.asset("assets/logo2.png", height: 80,),
              ),
            ],
          ),
          SizedBox(width: 20),
          Text(
            "RipeN-Go",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(151, 237, 0, 1),
              shadows: [
                Shadow(
                  offset: Offset(0, 3),
                  blurRadius: 5.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBody extends StatefulWidget {

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final String basePath = "/storage/emulated/0/Pictures/RipeN-Go/";
  final List<String> fruitFolders = ["Banana", "Mango", "Papaya"];
  Map<String, Map<String, List<File>>> imagesByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImages(); // Ensure images are reloaded
  }

  void _loadImages() {
    Map<String, Map<String, List<File>>> tempImages = {};

    for (String fruit in fruitFolders) {
      Directory fruitDir = Directory("$basePath$fruit");
      if (!fruitDir.existsSync()) {
        print("Directory does not exist: ${fruitDir.path}");
        tempImages[fruit] = {}; // Avoid listing files in a non-existent directory
        continue;
      }

      List<FileSystemEntity> batchFolders;
      try {
        batchFolders = fruitDir.listSync().whereType<Directory>().toList();
      } catch (e) {
        print("Error listing directories in ${fruitDir.path}: $e");
        tempImages[fruit] = {};
        continue;
      }

      Map<String, List<File>> batchMap = {};

      for (var batch in batchFolders) {
        String batchName = batch.path.split('/').last;
        List<File> images;
        try {
          images = (batch as Directory)
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith(".jpg") || file.path.endsWith(".png"))
              .toList();
        } catch (e) {
          print("Error listing files in ${batch.path}: $e");
          images = [];
        }
        batchMap[batchName] = images;
      }

      tempImages[fruit] = batchMap;
    }

    setState(() {
      imagesByCategory = tempImages;
    });
  }

  void _renameBatch(String fruit, String oldBatchName, String newBatchName) async {
    final oldBatchDir = Directory("$basePath$fruit/$oldBatchName");
    final newBatchDir = Directory("$basePath$fruit/$newBatchName");

    if (await oldBatchDir.exists() && !await newBatchDir.exists()) {
      await oldBatchDir.rename(newBatchDir.path);
      _loadImages();
    } else {
      print("Error renaming batch: Directory already exists or does not exist.");
    }
  }

  void _showRenameDialog(String fruit, String oldBatchName) {
    final TextEditingController _controller = TextEditingController(text: oldBatchName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rename Batch"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter new batch name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _renameBatch(fruit, oldBatchName, _controller.text);
              },
              child: Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  void _showGalleryPopup(String fruit, String batchName, List<File> images) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(batchName),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  _showRenameDialog(fruit, batchName);
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          images: images,
                          initialIndex: index,
                          fruit: fruit,
                          batch: batchName,
                          image: images[index], // Add the required 'image' parameter
                        ),
                      ),
                    );
                  },
                  child: Image.file(images[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: imagesByCategory.isEmpty
            ? _buildEmptyGallery()
            : _buildImageGrid(),
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF347928), size: 100),
          SizedBox(height: 20),
          Text("No Images", style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fruitFolders.map((fruit) {
        Map<String, List<File>> batchImages = imagesByCategory[fruit] ?? {};

        if (batchImages.isEmpty) return SizedBox.shrink(); // Hide empty categories

        // Ensure "Batch 1" always appears on the left and every new batch appears to the right
        List<MapEntry<String, List<File>>> sortedBatchImages = batchImages.entries.toList();
        sortedBatchImages.sort((a, b) {
          if (a.key == "Batch 1") return -1;
          if (b.key == "Batch 1") return 1;
          return a.key.compareTo(b.key);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/${fruit.toLowerCase()}.png', width: 24, height: 24),
                SizedBox(width: 8),
                Text(
                  fruit, // Fruit category name
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 170, // Adjust height to fit batch containers and prevent overflow
              child: ListView(
                scrollDirection: Axis.horizontal, // Horizontal scrolling for batches
                children: sortedBatchImages.map((entry) {
                  String batchName = entry.key;
                  List<File> images = entry.value;

                  // Sort images by last modified date in descending order
                  images.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        _showGalleryPopup(fruit, batchName, images);
                      },
                      onLongPress: () {
                        _showRenameDialog(fruit, batchName);
                      },
                      child: Container(
                        width: 150, // Batch container size
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFF347928)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF347928),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                batchName,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              children: images.take(4).map((image) {
                                return Container(
                                  width: 70, // Thumbnail size
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Color(0xFF347928)),
                                  ),
                                  child: Image.file(image, fit: BoxFit.cover),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}
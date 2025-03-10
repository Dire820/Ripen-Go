import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';


class CameraScreen extends StatefulWidget {
  final String fruit;
  final String batch; // Now supports batch selection

  const CameraScreen({Key? key, required this.fruit, required this.batch}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashVisible = false; // Flash animation state

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0], // Back camera
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _captureAndSaveImage() async {
    if (!_cameraController.value.isTakingPicture) {
      try {
        final XFile image = await _cameraController.takePicture();
        await _saveImage(image.path);

        // Show flash effect
        setState(() {
          _isFlashVisible = true;
        });
        await Future.delayed(Duration(milliseconds: 100)); // Flash duration
        setState(() {
          _isFlashVisible = false;
        });

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Photo saved in ${widget.fruit} - ${widget.batch} folder!"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("Error capturing image: $e");
      }
    }
  }

  Future<void> _saveImage(String imagePath) async {
    // Save images in the batch folder inside the fruit folder
    final Directory batchDir = Directory("/storage/emulated/0/Pictures/RipeN-Go/${widget.fruit}/${widget.batch}/");
    if (!await batchDir.exists()) {
      await batchDir.create(recursive: true);
    }

    final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final String savedPath = "${batchDir.path}$fileName";

    final File savedImage = File(imagePath);
    await savedImage.copy(savedPath);

    print("Image saved at: $savedPath");
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            Center(child: CircularProgressIndicator()),

          // Flash effect overlay
          if (_isFlashVisible)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
              ),
            ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _captureAndSaveImage,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera, color: Colors.black),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

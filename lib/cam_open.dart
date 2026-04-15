// cam_open.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'homescreen_page.dart';
import 'loading_screen.dart';   // <-- import the new loading screen

class CamOpen extends StatefulWidget {
  const CamOpen({super.key});

  @override
  State<CamOpen> createState() => _CamOpenState();
}

class _CamOpenState extends State<CamOpen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Keep existing navigation or change as needed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreenPage()),
              );
            },
          ),
        ],
      ),
      body: _isCameraReady && _cameraController != null
          ? CameraPreview(_cameraController!)
          : const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_cameraController == null || !_cameraController!.value.isInitialized) return;
          try {
            final photo = await _cameraController!.takePicture();
            // After taking the photo, navigate to the loading screen
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoadingScreen()),
            );
            // Optionally, you can pass the photo path to the next screen:
            // MaterialPageRoute(builder: (_) => LoadingScreen(photoPath: photo.path))
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error taking photo: $e')),
            );
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
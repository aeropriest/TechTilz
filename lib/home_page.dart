import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  List<dynamic>? recognitions;

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/fruits_model.tflite",
      labels: "assets/fruits_labels.txt",
    );
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await cameraController!.initialize();
    cameraController!.startImageStream((image) {
      if (!isDetecting) {
        isDetecting = true;
        runModelOnFrame(image);
      }
    });
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );
    setState(() {
      isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Object Detection")),
      body: Column(
        children: [
          // Display camera preview and recognized objects here.
        ],
      ),
    );
  }
}

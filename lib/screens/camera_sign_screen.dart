import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../services/sign_sense_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/sign_display_card.dart';
import '../widgets/sign_sequence_view.dart';

class CameraSignScreen extends StatefulWidget {
  const CameraSignScreen({super.key});

  static const routeName = '/camera-sign';

  @override
  State<CameraSignScreen> createState() => _CameraSignScreenState();
}

class _CameraSignScreenState extends State<CameraSignScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _lastCaptured;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      var status = await Permission.camera.request();
      if (status.isGranted) {
        final cameras = await availableCameras();
        final camera = cameras.first;
        _controller = CameraController(
          camera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        _initializeControllerFuture = _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      } else {
        // Handle permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndDetect(SignSenseProvider provider) async {
    if (_controller == null) return;
    try {
      await _initializeControllerFuture;
      final file = await _controller!.takePicture();
      setState(() {
        _lastCaptured = file;
      });
      await provider.detectFromImage(File(file.path));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignSenseProvider>();
    final prediction = provider.lastPrediction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Sign Detection'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: NeumorphicCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _controller == null
                        ? const Center(
                            child: Text('Initializing camera...'),
                          )
                        : FutureBuilder(
                            future: _initializeControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return CameraPreview(_controller!);
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () => _captureAndDetect(provider),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(provider.isLoading ? 'Detecting...' : 'Capture'),
                ),
              ),
              const SizedBox(height: 16),
              SignDisplayCard(
                title: 'Detected sign',
                subtitle: prediction == null
                    ? 'Point the camera to a sign gesture and capture to detect'
                    : '${prediction.character}  •  ${(prediction.confidence * 100).toStringAsFixed(1)}%',
                signContent: SignSequenceView(
                  text: prediction?.character ?? '',
                ),
              ),
              if (_lastCaptured != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last frame sent to backend',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.redAccent,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


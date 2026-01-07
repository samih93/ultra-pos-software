import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Implementation for platforms that support mobile_scanner
class MobileScannerWidget extends StatefulWidget {
  final Function(String)? onBarcodeDetected;

  const MobileScannerWidget({super.key, this.onBarcodeDetected});

  @override
  State<MobileScannerWidget> createState() => _MobileScannerWidgetState();
}

class _MobileScannerWidgetState extends State<MobileScannerWidget> {
  MobileScannerController? _controller;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CoreCircularIndicator());
    }

    return MobileScanner(
      controller: _controller,
      onDetect: (barcodeCapture) {
        if (_isDetecting || widget.onBarcodeDetected == null) return;

        final barcode = barcodeCapture.barcodes.firstOrNull?.displayValue;
        if (barcode != null && barcode.isNotEmpty) {
          _isDetecting = true;
          widget.onBarcodeDetected!(barcode);

          // Reset detection flag after delay
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              _isDetecting = false;
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

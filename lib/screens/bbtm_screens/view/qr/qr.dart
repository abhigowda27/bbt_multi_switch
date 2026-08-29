import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/wifi.dart';

class QRPage extends StatefulWidget {
  final String data;
  final String name;
  const QRPage({required this.data, required this.name, super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  GlobalKey globalKey = GlobalKey();

  Future<void> convertQrCodeToImage(
      BuildContext context, String data, String name) async {
    try {
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Render QR code image
      ui.Image qrImage = await boundary.toImage(pixelRatio: 3);

      const double margin = 20.0;
      const double logoSize = 120.0;
      const double textSize = 40.0;

      final double qrImageWidth = qrImage.width.toDouble();
      final double qrImageHeight = qrImage.height.toDouble();
      final double imageWidth = qrImageWidth + 2 * margin;
      final double imageHeight =
          qrImageHeight + 3 * margin + logoSize + textSize;

      // Prepare canvas
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, imageWidth, imageHeight));

      // Draw white background
      canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight),
          Paint()..color = Colors.white);

      // Draw QR code
      canvas.drawImageRect(
        qrImage,
        Rect.fromLTWH(0, 0, qrImageWidth, qrImageHeight),
        Rect.fromLTWH(margin, margin + logoSize + textSize + margin,
            qrImageWidth, qrImageHeight),
        Paint(),
      );

      // Draw logo
      final logoImage = AssetImage('assets/images/BBT_Logo_2.png');
      final logo = await _loadImage(logoImage);

      final logoRect = Rect.fromLTWH(
        (imageWidth - logoSize) / 2,
        margin,
        logoSize,
        logoSize,
      );

      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        logoRect,
        Paint(),
      );

      // Draw name text below logo
      final textPainter = TextPainter(
        text: TextSpan(
          text: name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: imageWidth);

      final textOffset = Offset(
        (imageWidth - textPainter.width) / 2,
        logoRect.bottom + 5,
      );

      textPainter.paint(canvas, textOffset);

      // Create final image
      ui.Image finalImage = await recorder
          .endRecording()
          .toImage(imageWidth.toInt(), imageHeight.toInt());

      ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final directory = await getTemporaryDirectory();
      File imgFile = File("${directory.path}/qrCode.png");
      await imgFile.writeAsBytes(pngBytes);

      // Get the RenderBox for iPad popover (sharePositionOrigin)
      final box = navigatorKey.currentContext!.findRenderObject() as RenderBox?;
      final shareOrigin = (box != null)
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.fromLTWH(0, 0, 1, 1); // fallback if box not ready

      // Share using modern SharePlus API
      await SharePlus.instance.share(ShareParams(
        text:
            "Enjoy the ease of controlling your switches effortless operation, happy living!",
        files: [XFile(imgFile.path)],
        sharePositionOrigin: shareOrigin,
      ));
    } catch (e) {
      debugPrint("Error sharing QR code: $e");
    }
  }

  Future<ui.Image> _loadImage(ImageProvider provider) async {
    final Completer<ui.Image> completer = Completer();
    final ImageStream stream = provider.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
    });
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR CODE ")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QrImageView(
                      data: widget.data,
                      backgroundColor: Theme.of(context).appColors.background,
                      version: QrVersions.auto,
                      gapless: true,
                      dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Theme.of(context).appColors.textPrimary),
                      size: 200.0,
                    ),
                    // Positioned(
                    //   bottom: 10,
                    //   child: Container(
                    //     color: Colors.white.withValues(alpha:0.8),
                    //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    //     child: Text(
                    //       widget.name,
                    //       style: const TextStyle(
                    //         color: Colors.black,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  convertQrCodeToImage(context, widget.data, widget.name);
                },
                child: Text(
                  "Share",
                  style:
                      TextStyle(color: Theme.of(context).appColors.background),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'WIFI is connected to Wifi Name',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: NetworkService().wifiNameNotifier,
                builder: (context, wifiName, _) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '"${wifiName ?? "Unknown"}"',
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context).appColors.primary,
                              ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

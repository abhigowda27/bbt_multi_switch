import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarouselWidget extends StatefulWidget {
  const ImageCarouselWidget({
    super.key,
    required this.connectionStatus,
  });
  final String connectionStatus;

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget>
    with SingleTickerProviderStateMixin {
  List<String> imagePaths = [
    'assets/images/home_1.jpg',
    'assets/images/home_2.jpg',
    'assets/images/home_3.png',
    'assets/images/home_4.png',
  ];
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacityAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double height = screenHeight * 0.3;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              options: CarouselOptions(
                height: height,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
              ),
              items: imagePaths.map((path) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Positioned(
            right: 10,
            top: 20,
            child: Image.asset(
              "assets/images/BBT_Logo_2.png",
              width: screenHeight * 0.08,
              height: screenHeight * 0.08,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            // bottom: ,
            top: 0,
            bottom: 0,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Experience the Future of Smart Living',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'Discover the future of Comfort, Control & Care with BelBird Technologies',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Row(
              children: [
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Icon(
                    widget.connectionStatus.toLowerCase() == "unknown"
                        ? Icons.wifi_off
                        : Icons.wifi_rounded,
                    color: widget.connectionStatus.toLowerCase() == "unknown"
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    size: screenHeight * 0.035,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '"${widget.connectionStatus}"',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

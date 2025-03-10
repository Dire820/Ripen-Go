import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final List<File> images;
  final int initialIndex;
  final String fruit;
  final String batch;

  const FullScreenImagePage({
    required this.images,
    required this.initialIndex,
    required this.fruit,
    required this.batch, required File image,
  });

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(initialPage: initialIndex);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/${fruit.toLowerCase()}.png', width: 24, height: 24),
            SizedBox(width: 8),
            Text("$fruit / $batch"),
          ],
        ),
        backgroundColor: Color(0xFF347928),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.file(images[index], fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}
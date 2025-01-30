import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/objects/objects.dart';

class ImageGrid extends StatefulWidget {
  final List<MediaItem> photos;
  final bool Function(int) deleteMedia;
  final bool Function(int, SwapType) swapMedia;

  const ImageGrid({
    super.key,
    required this.photos,
    required this.deleteMedia,
    required this.swapMedia,
  });

  @override
  State<ImageGrid> createState() => ImageGridState();
}

class ImageGridState extends State<ImageGrid> {
  late ValueNotifier<int> _currentImageIndexNotifier;
  late StreamController<int> _imageStreamController;

  @override
  void initState() {
    super.initState();
    _imageStreamController = StreamController<int>();
    _currentImageIndexNotifier = ValueNotifier<int>(0);
    _imageStreamController.stream.listen((int value) {
      _currentImageIndexNotifier.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true, // Makes the GridView take only as much height as its children
        physics: NeverScrollableScrollPhysics(), // Disables scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
        ),
        itemCount: widget.photos.length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.photos.isEmpty) {
            return Container();
          }
          MediaItem? item;
          if (index < widget.photos.length) {
            item = widget.photos[index];
          }

          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: GestureDetector(
              onTap: () {
                _imageStreamController.add(index);
                showDialog(
                  barrierColor: const Color.fromARGB(255, 41, 40, 40),
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: GestureDetector(
                          onHorizontalDragEnd: (dragEndDetails) {
                            if ((dragEndDetails.primaryVelocity ?? 0) < 0) {
                              if (_currentImageIndexNotifier.value < widget.photos.length - 1) {
                                _imageStreamController.add(_currentImageIndexNotifier.value + 1);
                              }
                            } else if ((dragEndDetails.primaryVelocity ?? 0) > 0) {
                              if (_currentImageIndexNotifier.value > 0) {
                                _imageStreamController.add(_currentImageIndexNotifier.value - 1);
                              }
                            }
                          },
                          child: ValueListenableBuilder<int>(
                            valueListenable: _currentImageIndexNotifier,
                            builder: (context, value, child) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.photos[value].pathByPlatform,
                                  cacheKey: widget.photos[value].pathByPlatform,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator.adaptive(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: item!.pathByPlatform,
                    progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator.adaptive(value: downloadProgress.progress),
                    ),
                    errorWidget: (context, url, error) {
                      return Icon(Icons.error);
                    },
                    cacheKey: item.pathByPlatform,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        if (widget.deleteMedia(index)) {
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.delete, color: const Color.fromARGB(255, 220, 67, 56)),
                    ),
                  ),
                  if (index == 0) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.downwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.leftToRight)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index == 1) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.downwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.rightToLeft)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index == widget.photos.length - 1) ...[
                    Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.upwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.rightToLeft)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index == widget.photos.length - 2) ...[
                    Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.upwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.leftToRight)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index % 2 == 0 && index != 0 && index != 1 && index != widget.photos.length - 1 && index != widget.photos.length - 2) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.leftToRight)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index % 2 == 1 && index != 0 && index != 1 && index != widget.photos.length - 1 && index != widget.photos.length - 2) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.rightToLeft)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                  if (index != 0 && index != 1 && index != widget.photos.length - 1 && index != widget.photos.length - 2) ...[
                    Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.upwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () {
                          if (widget.swapMedia(index, SwapType.downwards)) {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

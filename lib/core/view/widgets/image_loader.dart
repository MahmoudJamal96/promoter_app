import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

import '../../constants/assets.dart';

class ImageLoader extends StatefulWidget {
  ImageLoader({
    Key? key,
    required this.path,
    this.width,
    this.height,
    this.repeated = false,
    this.mirror = true,
    this.fit = BoxFit.fill,
    this.padding,
    this.borderRadius,
    this.color,
    this.onAnimationFinish,
  }) : super(key: key) {
    image = ImageModel(path);
  }

  final String path;
  final BoxFit fit;
  final double? width;
  final bool repeated, mirror;
  final Color? color;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Function()? onAnimationFinish;
  late final ImageModel image;

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

String colorToHexString(Color color) => '#${color.value.toRadixString(16).substring(2)}';

class _ImageLoaderState extends State<ImageLoader> with TickerProviderStateMixin {
  late final AnimationController _controller;
  ValueNotifier<String> svgCode = ValueNotifier('');
  late ImageType imageType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    imageType = widget.image.checkImageType();
    // loadSvg();
  }

  /*loadSvg() async {
    if (widget.image.checkImageType() == ImageType.svg) {
      svgCode.value = await rootBundle.loadString(widget.image.imagePath);

      final oldColor = colorToHexString(MyTheme.oldSVGTheme.background);
      final newColor = colorToHexString(CustomTheme.primary.background);
      svgCode.value = svgCode.value.replaceAll(oldColor.toUpperCase(), newColor);

      final oldShadowColor = colorToHexString(MyTheme.oldSVGTheme.shadow);
      final newShadowColor = colorToHexString(CustomTheme.primary.shadow);
      svgCode.value = svgCode.value.replaceAll(oldShadowColor.toUpperCase(), newShadowColor);

      final oldBorderColor = colorToHexString(MyTheme.oldSVGTheme.border);
      final newBorderColor = colorToHexString(CustomTheme.primary.border);
      svgCode.value = svgCode.value.replaceAll(oldBorderColor.toUpperCase(), newBorderColor);

      final oldSecColor = colorToHexString(MyTheme.oldSVGTheme.textColor);
      final newSecColor = colorToHexString(CustomTheme.primary.background);
      svgCode.value = svgCode.value.replaceAll(oldSecColor.toUpperCase(), newSecColor);

    }
  }*/

  Widget loadImage() {
    final memCacheHeight = widget.height == null ? null : (widget.height! * 2).toInt();
    final memCacheWidth = widget.width == null ? null : (widget.width! * 2).toInt();
    CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

    switch (widget.image.checkImageType()) {
      case ImageType.json:
        return Lottie.asset(
          widget.image.imagePath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          frameRate: FrameRate.max,
          controller: (!widget.repeated) ? _controller : null,
          onLoaded: (composition) {
            if (!widget.repeated) {
              _controller
                ..duration = composition.duration
                ..forward();
              _controller.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  if (widget.onAnimationFinish != null) {
                    if (widget.onAnimationFinish != null) {
                      widget.onAnimationFinish!();
                    }
                  }
                }
              });
            }
          },
          animate: widget.repeated,
          reverse: widget.repeated,
          repeat: widget.repeated,
        );
      case ImageType.svg:
        return ValueListenableBuilder(
          valueListenable: svgCode,
          builder: (context, value, child) {
            if (svgCode.value.isNotEmpty) {
              return SvgPicture.string(
                svgCode.value,
                width: widget.width,
                height: widget.height,
                colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
                fit: widget.fit,
              );
            }
            return SvgPicture.asset(
              widget.image.imagePath,
              width: widget.width,
              height: widget.height,
              colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
              fit: widget.fit,
            );
          },
        );
      case ImageType.png:
        return Image.asset(
          widget.image.imagePath,
          width: widget.width,
          height: widget.height,
          color: widget.color,
          fit: widget.fit,
        );
      case ImageType.url:
        return CachedNetworkImage(
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          memCacheHeight: memCacheHeight,
          memCacheWidth: memCacheWidth,
          imageUrl: widget.image.imagePath,

          // CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: SizedBox(
                width: widget.width ?? 40,
                height: widget.height ?? 40,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      // color: CustomTheme.primary.background,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            );
          },
          errorWidget: (context, url, error) => PlaceHolder(
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
          ),
        );
      default:
        return Image.asset(
          widget.image.imagePath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    Image image;

    switch (widget.image.checkImageType()) {
      case ImageType.png:
        image = Image.asset(widget.image.imagePath);
        precacheImage(image.image, context);
        break;
      case ImageType.svg:
        final SvgAssetLoader loader = SvgAssetLoader(widget.image.imagePath);
        await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
        break;
      default:
        break;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final memCacheHeight = widget.height == null ? null : (widget.height! * 2).toInt();
    final memCacheWidth = widget.width == null ? null : (widget.width! * 2).toInt();
    CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

    if (widget.image.imagePath.isEmpty) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: PlaceHolder(
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
        ),
      );
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return const Center(child: Text('Image'));
    }

    return ClipRRect(
        key: ValueKey(widget.path),
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Transform.flip(
          flipX: false,
          child: imageType == ImageType.json
              ? Lottie.asset(
                  widget.image.imagePath,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                  frameRate: FrameRate.max,
                  controller: (!widget.repeated) ? _controller : null,
                  onLoaded: (composition) {
                    if (!widget.repeated) {
                      _controller
                        ..duration = composition.duration
                        ..forward();
                      _controller.addStatusListener((status) {
                        if (status == AnimationStatus.completed) {
                          if (widget.onAnimationFinish != null) {
                            if (widget.onAnimationFinish != null) {
                              widget.onAnimationFinish!();
                            }
                          }
                        }
                      });
                    }
                  },
                  animate: widget.repeated,
                  reverse: widget.repeated,
                  repeat: widget.repeated,
                )
              : imageType == ImageType.svg
                  ? ValueListenableBuilder(
                      valueListenable: svgCode,
                      builder: (context, value, child) {
                        if (svgCode.value.isNotEmpty) {
                          return SvgPicture.string(
                            svgCode.value,
                            width: widget.width,
                            height: widget.height,
                            colorFilter: widget.color != null
                                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                                : null,
                            fit: widget.fit,
                          );
                        }
                        return SvgPicture.asset(
                          widget.image.imagePath,
                          width: widget.width,
                          height: widget.height,
                          colorFilter:
                              widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
                          fit: widget.fit,
                        );
                      },
                    )
                  :
                  // return SvgPicture.asset(
                  //   widget.image.imagePath,
                  //   width: widget.width,
                  //   height: widget.height,
                  //   colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
                  //   fit: widget.fit,
                  // );

                  imageType == ImageType.png
                      ? Image.asset(
                          widget.image.imagePath,
                          width: widget.width,
                          height: widget.height,
                          color: widget.color,
                          fit: widget.fit,
                        )
                      : imageType == ImageType.url
                          ? CachedNetworkImage(
                              fit: widget.fit,
                              width: widget.width,
                              height: widget.height,
                              memCacheHeight: memCacheHeight,
                              memCacheWidth: memCacheWidth,
                              imageUrl: widget.image.imagePath,

                              // CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
                              progressIndicatorBuilder: (context, url, downloadProgress) {
                                return Center(
                                  child: SizedBox(
                                    width: widget.width ?? 40,
                                    height: widget.height ?? 40,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          // color: CustomTheme.primary.background,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) => PlaceHolder(
                                fit: widget.fit,
                                width: widget.width,
                                height: widget.height,
                              ),
                            )
                          : Image.asset(
                              widget.image.imagePath,
                              width: widget.width,
                              height: widget.height,
                              fit: widget.fit,
                            ),
        ));
  }
}

class PlaceHolder extends StatelessWidget {
  const PlaceHolder({
    super.key,
    this.asset,
    this.fit,
    this.width,
    this.height,
  });

  final String? asset;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.scanCurves,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
    );
  }
}

class ImageModel {
  String imagePath;

  ImageModel(this.imagePath);

  ImageType checkImageType() {
    if (imagePath.startsWith('http')) {
      return ImageType.url;
    } else if (imagePath.endsWith('.svg')) {
      return ImageType.svg;
    } else if (imagePath.endsWith('.json')) {
      return ImageType.json;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, url, json }

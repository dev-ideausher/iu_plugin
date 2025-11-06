// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Advanced image view component supporting multiple image sources
/// Handles network images, local assets, SVG files, and file system images
/// Automatically detects image type from path or uses explicit parameters
class CommonImageView extends StatelessWidget {
  /// Single image path (auto-detects type) - takes priority if provided
  final String? imagePath;
  
  /// Network image URL (alternative to imagePath)
  final String? url;
  
  /// SVG asset path (alternative to imagePath)
  final String? svgPath;
  
  /// File from file system (alternative to imagePath)
  final File? file;
  
  /// Image height
  final double? height;
  
  /// Image width
  final double? width;
  
  /// Box fit mode
  final BoxFit? fit;
  
  /// Placeholder image path
  final String placeHolder;
  
  /// SVG color (for SVG images)
  final Color? color;
  
  /// Border radius (alternative to radius)
  final double? borderRadius;
  
  /// Custom border radius
  final BorderRadius? radius;
  
  /// Enable caching for network images
  final bool enableCache;
  
  /// Alignment of the image
  final Alignment? alignment;
  
  /// Tap callback
  final VoidCallback? onTap;
  
  /// Margin around the image
  final EdgeInsetsGeometry? margin;
  
  /// Border around the image
  final BoxBorder? border;
  
  /// Error widget builder
  final Widget Function(BuildContext, String, dynamic)? errorBuilder;
  
  /// Placeholder widget builder
  final Widget Function(BuildContext, String)? placeholderBuilder;

  /// Advanced image view component
  /// Supports network images, local assets, SVG files, and file system images
  /// Can use single imagePath (auto-detects type) or explicit parameters
  CommonImageView({
    Key? key,
    this.imagePath,
    this.url,
    this.svgPath,
    this.color,
    this.file,
    this.height,
    this.width,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.borderRadius,
    this.margin,
    this.border,
    this.placeHolder = 'assets/images/image_not_found.png',
    this.enableCache = true,
    this.errorBuilder,
    this.placeholderBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(),
          )
        : _buildWidget();

    return widget;
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: _buildCircleImage(),
            )
          : _buildCircleImage(),
    );
  }

  /// Build image with border radius
  Widget _buildCircleImage() {
    final effectiveRadius = radius ?? 
        (borderRadius != null ? BorderRadius.circular(borderRadius!) : null);
    
    if (effectiveRadius != null) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  /// Build image with border
  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius ?? 
              (borderRadius != null ? BorderRadius.circular(borderRadius!) : null),
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    // Priority: Explicit parameters > imagePath (auto-detect) > Placeholder
    
    // If imagePath is provided, use it with auto-detection
    if (imagePath != null && imagePath!.isNotEmpty) {
      return _buildImageFromPath(imagePath!);
    }

    // Explicit SVG path
    if (svgPath != null && svgPath!.isNotEmpty) {
      return _buildSvgImage(svgPath!);
    }

    // Explicit file
    if (file != null && file!.existsSync()) {
      return _buildFileImage(file!);
    }

    // Explicit network URL
    if (url != null && url!.isNotEmpty && _isValidUrl(url!)) {
      return _buildNetworkImage(url!);
    }

    // Placeholder
    return _buildPlaceholder();
  }

  /// Build image from path with auto-detection
  Widget _buildImageFromPath(String path) {
    switch (path.imageType) {
      case ImageType.svg:
        return _buildSvgImage(path);
      case ImageType.file:
        return _buildFileImage(File(path));
      case ImageType.network:
        return _buildNetworkImage(path);
      case ImageType.png:
      case ImageType.unknown:
      default:
        return _buildAssetImage(path);
    }
  }

  Widget _buildSvgImage(String path) {
    try {
      return Container(
        height: height,
        width: width,
        child: SvgPicture.asset(
          path,
          height: height,
          width: width,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (context) => _buildPlaceholder(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading SVG: $e');
      }
      return _buildPlaceholder();
    }
  }

  Widget _buildFileImage(File file) {
    try {
      return Image.file(
        file,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, file.path, error);
          }
          return _buildPlaceholder();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading file image: $e');
      }
      return _buildPlaceholder();
    }
  }

  Widget _buildNetworkImage(String url) {
    if (!enableCache) {
      return Image.network(
        url,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholderBuilder != null
              ? placeholderBuilder!(context, url)
              : _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, url, error);
          }
          return _buildPlaceholder();
        },
      );
    }

    return CachedNetworkImage(
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      imageUrl: url,
      color: color,
      placeholder: placeholderBuilder ?? (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        if (errorBuilder != null) {
          return errorBuilder!(context, url, error);
        }
        return _buildPlaceholder();
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildAssetImage(String path) {
    try {
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, path, error);
          }
          return _buildPlaceholder();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading asset image: $e');
      }
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    try {
      return SizedBox(
        height: height,
        width: width,
        child: Image.asset(
          placeHolder,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple colored container if placeholder also fails
            return _buildFallbackPlaceholder();
          },
        ),
      );
    } catch (e) {
      // Ultimate fallback
      return _buildFallbackPlaceholder();
    }
  }

  Widget _buildFallbackPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: (height != null && height! < 50) ? height : 50,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: height ?? 30,
      width: width ?? 30,
      child: Center(
        child: SizedBox(
          height: (height != null && height! < 30) ? height : 30,
          width: (width != null && width! < 30) ? width : 30,
          child: LinearProgressIndicator(
            color: Colors.grey.shade200,
            backgroundColor: Colors.grey.shade100,
          ),
        ),
      ),
    );
  }

  /// Validate if string is a valid URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// Extension to automatically detect image type from path
extension ImageTypeExtension on String {
  /// Automatically detect image type from path string
  ImageType get imageType {
    if (isEmpty) return ImageType.unknown;
    
    // Network URL
    if (startsWith('http://') || startsWith('https://')) {
      return ImageType.network;
    }
    
    // SVG file
    if (endsWith('.svg')) {
      return ImageType.svg;
    }
    
    // File system path
    if (startsWith('/data') || 
        startsWith('/storage') || 
        startsWith('/tmp') ||
        (contains('/') && !startsWith('assets/'))) {
      return ImageType.file;
    }
    
    // Default to asset (PNG, JPG, etc.)
    return ImageType.png;
  }
}

/// Image type enumeration
enum ImageType {
  /// SVG vector image
  svg,
  
  /// PNG, JPG, or other raster asset image
  png,
  
  /// Network image (HTTP/HTTPS URL)
  network,
  
  /// File system image
  file,
  
  /// Unknown type
  unknown,
}


import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Advanced image view component supporting multiple image sources
/// Handles network images, local assets, SVG files, and file system images
class CommonImageView extends StatelessWidget {
  /// Network image URL
  final String? url;
  
  /// Local asset image path
  final String? imagePath;
  
  /// SVG asset path
  final String? svgPath;
  
  /// File from file system
  final File? file;
  
  /// Image height
  final double? height;
  
  /// Image width
  final double? width;
  
  /// Box fit mode
  final BoxFit fit;
  
  /// Placeholder image path
  final String placeHolder;
  
  /// SVG color (for SVG images)
  final Color? svgColor;
  
  /// Border radius
  final double? borderRadius;
  
  /// Enable caching for network images
  final bool enableCache;
  
  /// Error widget builder
  final Widget Function(BuildContext, String, dynamic)? errorBuilder;
  
  /// Placeholder widget builder
  final Widget Function(BuildContext, String)? placeholderBuilder;

  /// Advanced image view component
  /// Supports network images, local assets, SVG files, and file system images
  const CommonImageView({
    Key? key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.svgColor,
    this.file,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/image_not_found.png',
    this.borderRadius,
    this.enableCache = true,
    this.errorBuilder,
    this.placeholderBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius != null
          ? BorderRadius.circular(borderRadius!)
          : BorderRadius.zero,
      child: _buildImageView(),
    );
  }

  Widget _buildImageView() {
    // Priority: SVG > File > Network URL > Local Asset > Placeholder

    // SVG Image
    if (svgPath != null && svgPath!.isNotEmpty) {
      return _buildSvgImage();
    }

    // File Image
    if (file != null && file!.existsSync()) {
      return _buildFileImage();
    }

    // Network Image
    if (url != null && url!.isNotEmpty && _isValidUrl(url!)) {
      return _buildNetworkImage();
    }

    // Local Asset Image
    if (imagePath != null && imagePath!.isNotEmpty) {
      return _buildAssetImage();
    }

    // Placeholder
    return _buildPlaceholder();
  }

  Widget _buildSvgImage() {
    try {
      return SizedBox(
        height: height,
        width: width,
        child: SvgPicture.asset(
          svgPath!,
          height: height,
          width: width,
          fit: fit,
          colorFilter: svgColor != null
              ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
              : null,
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

  Widget _buildFileImage() {
    try {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, file!.path, error);
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

  Widget _buildNetworkImage() {
    if (!enableCache) {
      return Image.network(
        url!,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, url!, error);
          }
          return _buildPlaceholder();
        },
      );
    }

    return CachedNetworkImage(
      height: height,
      width: width,
      fit: fit,
      imageUrl: url!,
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

  Widget _buildAssetImage() {
    try {
      return Image.asset(
        imagePath!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, imagePath!, error);
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
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple colored container if placeholder also fails
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
          },
        ),
      );
    } catch (e) {
      // Ultimate fallback
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
  }

  Widget _buildLoadingPlaceholder() {
    return SizedBox(
      height: height ?? 30,
      width: width ?? 30,
      child: Center(
        child: SizedBox(
          height: (height != null && height! < 30) ? height : 30,
          width: (width != null && width! < 30) ? width : 30,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
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

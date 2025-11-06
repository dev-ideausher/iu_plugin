/// Image constants for the application
/// Centralized location for all image asset paths
/// Organized by type (SVG, PNG, JPG, etc.)
class ImageConstant {
  ImageConstant._(); // Private constructor to prevent instantiation

  // ==================== SVG Icons ====================
  
  /// Application logo (SVG)
  static const String svgLogo = 'assets/images/logo.svg';
  
  /// Placeholder image (SVG)
  static const String svgPlaceholder = 'assets/images/placeholder.svg';
  
  /// Error image (SVG)
  static const String svgError = 'assets/images/error.svg';
  
  /// Empty state illustration (SVG)
  static const String svgEmpty = 'assets/images/empty.svg';

  // ==================== PNG Images ====================
  
  /// News banner image
  static const String pngNewsBanner = 'assets/images/news_banner.png';
  
  /// Default profile picture
  static const String pngProfilePlaceholder = 'assets/images/profile_placeholder.png';
  
  /// Image not found placeholder
  static const String pngImageNotFound = 'assets/images/image_not_found.png';
  
  /// App splash screen image
  static const String pngSplash = 'assets/images/splash.png';
  
  /// Onboarding images
  static const String pngOnboarding1 = 'assets/images/onboarding_1.png';
  static const String pngOnboarding2 = 'assets/images/onboarding_2.png';
  static const String pngOnboarding3 = 'assets/images/onboarding_3.png';

  // ==================== JPG Images ====================
  
  /// Background image
  static const String jpgBackground = 'assets/images/background.jpg';
  
  /// Default cover image
  static const String jpgCover = 'assets/images/cover.jpg';

  // ==================== Helper Methods ====================
  
  /// Get all SVG assets
  static List<String> get svgAssets => [
    svgLogo,
    svgPlaceholder,
    svgError,
    svgEmpty,
  ];

  /// Get all PNG assets
  static List<String> get pngAssets => [
    pngNewsBanner,
    pngProfilePlaceholder,
    pngImageNotFound,
    pngSplash,
    pngOnboarding1,
    pngOnboarding2,
    pngOnboarding3,
  ];

  /// Get all JPG assets
  static List<String> get jpgAssets => [
    jpgBackground,
    jpgCover,
  ];

  /// Get all image assets
  static List<String> get allAssets => [
    ...svgAssets,
    ...pngAssets,
    ...jpgAssets,
  ];

  /// Check if path is an SVG
  static bool isSvg(String path) => path.endsWith('.svg');

  /// Check if path is a PNG
  static bool isPng(String path) => path.endsWith('.png');

  /// Check if path is a JPG/JPEG
  static bool isJpg(String path) => 
      path.endsWith('.jpg') || path.endsWith('.jpeg');

  /// Get image type from path
  static ImageAssetType getImageType(String path) {
    if (isSvg(path)) return ImageAssetType.svg;
    if (isPng(path)) return ImageAssetType.png;
    if (isJpg(path)) return ImageAssetType.jpg;
    return ImageAssetType.unknown;
  }
}

/// Image asset type enumeration
enum ImageAssetType {
  svg,
  png,
  jpg,
  unknown,
}

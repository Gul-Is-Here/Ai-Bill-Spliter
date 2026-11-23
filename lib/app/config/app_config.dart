enum Flavor { dev, prod }

/// Per-flavor values.
class AppConfig {
  const AppConfig._({required this.flavor});

  static late final AppConfig instance;

  final Flavor flavor;

  bool get isProd => flavor == Flavor.prod;

  /// Contact address shown in the privacy policy/terms. Set with --dart-define=SUPPORT_EMAIL=...
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL', defaultValue: 'support@aibillsplitter.app');

  static void init(Flavor flavor) {
    instance = AppConfig._(flavor: flavor);
  }
}

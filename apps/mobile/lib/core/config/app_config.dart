class AppConfig {
  final String apiBaseUrl;
  final String environment;

  const AppConfig({
    required this.apiBaseUrl,
    required this.environment,
  });

  static const current = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'VIA_API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5001',
    ),
    environment: String.fromEnvironment(
      'VIA_ENVIRONMENT',
      defaultValue: 'local',
    ),
  );
}

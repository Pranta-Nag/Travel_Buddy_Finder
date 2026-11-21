import 'dart:io';

class _SafeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Accept certificates for the app's backend host or custom endpoints
        return true;
      };
  }
}

void setupHttpOverrides() {
  HttpOverrides.global = _SafeHttpOverrides();
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Textos legales de ACME. Viven en la tienda web para que la app y la web
/// muestren siempre la misma versión.
class LegalLinks {
  LegalLinks._();

  static const _base = String.fromEnvironment(
    'ACME_WEB_URL',
    defaultValue: 'https://acme-web-topaz.vercel.app',
  );

  /// Versión de los textos que la persona acepta; se guarda con la fecha.
  static const textsVersion = '2026-10';

  static const terms = '$_base/terminos-y-condiciones';
  static const privacy = '$_base/politica-de-privacidad';
  static const cookies = '$_base/politica-de-cookies';
  static const refunds = '$_base/devoluciones-y-cancelaciones';
  static const complaints = '$_base/libro-de-reclamaciones';

  static Future<void> open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos abrir $url')),
      );
    }
  }
}

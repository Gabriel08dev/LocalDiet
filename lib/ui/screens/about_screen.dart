import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Versão do app, informada no build com `--dart-define=APP_VERSION=...`.
const appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: 'desenvolvimento',
);

/// Fontes dos dados, fórmulas usadas, privacidade e aviso de saúde.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(top: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(body, style: context.text.bodyMedium),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(S.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          Text(S.appName, style: context.text.headlineMedium),
          Text(
            S.versionLine(appVersion),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Gap.lg),
          const InfoBanner(
            S.healthNotice,
            icon: Icons.health_and_safety_outlined,
          ),
          section(S.aboutFoodsTitle, S.aboutFoodsBody),
          section(S.aboutMeasuresTitle, S.aboutMeasuresBody),
          section(S.aboutFormulasTitle, S.aboutFormulasBody),
          section(S.aboutOilTitle, S.aboutOilBody),
          section(S.aboutPrivacyTitle, S.aboutPrivacyBody),
        ],
      ),
    );
  }
}

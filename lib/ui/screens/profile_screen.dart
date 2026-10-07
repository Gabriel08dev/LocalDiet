import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../domain/calorie_target.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final target = ref.watch(calorieTargetProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.profile)),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: context.colors.primaryContainer,
                      foregroundColor: context.colors.onPrimaryContainer,
                      child: Text(
                        profile.name.characters.first.toUpperCase(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name, style: context.text.headlineSmall),
                          Text(
                            S.profileSummary(profile, today),
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xl),
                if (target == null)
                  const InfoBanner(S.targetNeedsWeight)
                else
                  _TargetCard(profile: profile, target: target),
                const SizedBox(height: Gap.lg),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: IconBadge(
                          Icons.person_outline,
                          tone: context.appColors.lavender,
                        ),
                        title: const Text(S.personalData),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      ListTile(
                        leading: IconBadge(
                          Icons.restaurant_outlined,
                          tone: context.appColors.peach,
                        ),
                        title: const Text(S.myFoods),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/my-foods'),
                      ),
                      ListTile(
                        leading: IconBadge(
                          Icons.import_export,
                          tone: context.appColors.mint,
                        ),
                        title: const Text(S.dataTitle),
                        subtitle: const Text(S.dataSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/data'),
                      ),
                      ListTile(
                        leading: IconBadge(
                          Icons.info_outline,
                          tone: context.appColors.sky,
                        ),
                        title: const Text(S.aboutTitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/about'),
                      ),
                    ],
                  ),
                ),
                const SectionHeader(S.theme),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(S.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(S.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(S.themeDark),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) =>
                      setThemeMode(ref, selection.first),
                ),
              ],
            ),
    );
  }
}

/// A meta calórica do perfil, de onde ela vem e a opção de meta manual.
class _TargetCard extends ConsumerWidget {
  const _TargetCard({required this.profile, required this.target});

  final ProfileRow profile;
  final CalorieTarget target;

  Future<void> _setManual(WidgetRef ref, double? manual) => ref
      .read(profileRepositoryProvider)
      .save(
        name: profile.name,
        birthDate: profile.birthDate,
        sex: profile.sex,
        heightCm: profile.heightCm,
        goal: profile.goal,
        activity: profile.activity,
        manualKcalTarget: manual,
      );

  Future<void> _editManual(BuildContext context, WidgetRef ref) async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) => _ManualTargetDialog(initial: target.value),
    );
    if (value != null) await _setManual(ref, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              target.isManual ? S.manualTarget : S.calculatedTarget,
              style: context.text.labelLarge,
            ),
            const SizedBox(height: Gap.xs),
            Text(S.kcalPerDay(target.value), style: context.text.headlineSmall),
            const SizedBox(height: Gap.sm),
            Text(S.targetBreakdown(target, profile.goal), style: muted),
            if (target.isBelowBmr) ...[
              const SizedBox(height: Gap.md),
              const InfoBanner(S.belowBmrNotice, icon: Icons.warning_amber),
            ],
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              children: [
                TextButton(
                  onPressed: () => _editManual(context, ref),
                  child: Text(
                    target.isManual ? S.changeManualTarget : S.useManualTarget,
                  ),
                ),
                if (target.isManual)
                  TextButton(
                    onPressed: () => _setManual(ref, null),
                    child: const Text(S.useCalculatedTarget),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualTargetDialog extends StatefulWidget {
  const _ManualTargetDialog({required this.initial});

  final double initial;

  @override
  State<_ManualTargetDialog> createState() => _ManualTargetDialogState();
}

class _ManualTargetDialogState extends State<_ManualTargetDialog> {
  final _form = GlobalKey<FormState>();
  late final _value = TextEditingController(
    text: widget.initial.round().toString(),
  );

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.manualTarget),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(S.manualTargetHelp),
            const SizedBox(height: Gap.lg),
            DecimalField(
              controller: _value,
              label: S.kcalPerDayLabel,
              suffix: S.kcalUnit,
              required: true,
              min: 500,
              max: 10000,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop(parseDecimal(_value.text));
          },
          child: const Text(S.save),
        ),
      ],
    );
  }
}

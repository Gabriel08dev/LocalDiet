import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../domain/local_date.dart';
import '../../domain/profile_enums.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Formulário do perfil.
///
/// Sem [existing], é o onboarding: pede também o peso e as medidas opcionais
/// e grava a primeira medição junto com o perfil. Com [existing], edita só os
/// dados pessoais; peso e medidas mudam pela Evolução.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, this.existing});

  final ProfileRow? existing;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _height = TextEditingController(
    text: widget.existing == null
        ? ''
        : formatForInput(widget.existing!.heightCm),
  );
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _neck = TextEditingController();
  final _hip = TextEditingController();
  late LocalDate? _birthDate = widget.existing?.birthDate;
  late Sex? _sex = widget.existing?.sex;
  late Goal _goal = widget.existing?.goal ?? Goal.maintain;
  late ActivityLevel _activity =
      widget.existing?.activity ?? ActivityLevel.light;
  bool _birthDateMissing = false;
  bool _sexMissing = false;
  bool _saving = false;

  bool get _isOnboarding => widget.existing == null;

  @override
  void dispose() {
    for (final controller in [_name, _height, _weight, _waist, _neck, _hip]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_birthDate ?? LocalDate(today.year - 30, 1, 1))
          .toLocalNoon(),
      firstDate: DateTime(1900),
      lastDate: today.toLocalNoon(),
      helpText: S.birthDate,
      initialDatePickerMode: _birthDate == null
          ? DatePickerMode.year
          : DatePickerMode.day,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = LocalDate.fromDateTime(picked);
      _birthDateMissing = false;
    });
  }

  Future<void> _save() async {
    final valid = _form.currentState!.validate();
    setState(() {
      _birthDateMissing = _birthDate == null;
      _sexMissing = _sex == null;
    });
    if (!valid || _birthDate == null || _sex == null) return;

    setState(() => _saving = true);
    try {
      await _persist();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, S.saveFailed);
    }
  }

  Future<void> _persist() async {
    final profiles = ref.read(profileRepositoryProvider);
    final height = parseDecimal(_height.text)!;
    if (_isOnboarding) {
      await profiles.completeOnboarding(
        name: _name.text,
        birthDate: _birthDate!,
        sex: _sex!,
        heightCm: height,
        goal: _goal,
        activity: _activity,
        today: ref.read(todayProvider),
        weightKg: parseDecimal(_weight.text)!,
        waistCm: parseDecimal(_waist.text),
        neckCm: parseDecimal(_neck.text),
        hipCm: parseDecimal(_hip.text),
      );
    } else {
      await profiles.save(
        name: _name.text,
        birthDate: _birthDate!,
        sex: _sex!,
        heightCm: height,
        goal: _goal,
        activity: _activity,
        manualKcalTarget: widget.existing!.manualKcalTarget,
      );
      if (mounted) {
        showMessage(context, S.profileSaved);
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDate = _birthDate;
    final isMinor =
        birthDate != null && birthDate.ageOn(ref.watch(todayProvider)) < 18;

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          if (_isOnboarding) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: BrandMark(size: 56),
            ),
            const SizedBox(height: Gap.lg),
            Text(S.onboardingTitle, style: context.text.headlineMedium),
            const SizedBox(height: Gap.sm),
            Text(
              S.onboardingIntro,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Gap.xl),
          ],
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: S.name),
            validator: (text) =>
                (text ?? '').trim().isEmpty ? S.requiredField : null,
          ),
          const SizedBox(height: Gap.md),
          InkWell(
            onTap: _pickBirthDate,
            borderRadius: BorderRadius.circular(Corner.md),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: S.birthDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                errorText: _birthDateMissing ? S.requiredField : null,
              ),
              isEmpty: birthDate == null,
              child: birthDate == null ? null : Text(formatDate(birthDate)),
            ),
          ),
          if (isMinor) ...[
            const SizedBox(height: Gap.sm),
            const InfoBanner(S.minorNotice),
          ],
          const SizedBox(height: Gap.lg),
          Text(S.sexForCalculation, style: context.text.labelLarge),
          const SizedBox(height: Gap.sm),
          SegmentedButton<Sex>(
            segments: [
              for (final sex in Sex.values)
                ButtonSegment(value: sex, label: Text(sexLabel(sex))),
            ],
            emptySelectionAllowed: true,
            selected: {?_sex},
            onSelectionChanged: (selection) => setState(() {
              _sex = selection.firstOrNull ?? _sex;
              _sexMissing = false;
            }),
          ),
          if (_sexMissing) ...[
            const SizedBox(height: Gap.xs),
            Text(
              S.chooseOption,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
          const SizedBox(height: Gap.xs),
          Text(
            S.sexHelp,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Gap.lg),
          DecimalField(
            controller: _height,
            label: S.height,
            suffix: 'cm',
            required: true,
            min: 100,
            max: 250,
          ),
          if (_isOnboarding) ...[
            const SizedBox(height: Gap.md),
            DecimalField(
              controller: _weight,
              label: S.weight,
              suffix: 'kg',
              required: true,
              min: 20,
              max: 400,
            ),
          ],
          const SizedBox(height: Gap.lg),
          DropdownButtonFormField<Goal>(
            initialValue: _goal,
            isExpanded: true,
            decoration: const InputDecoration(labelText: S.goal),
            items: [
              for (final goal in Goal.values)
                DropdownMenuItem(value: goal, child: Text(goalLabel(goal))),
            ],
            onChanged: (goal) => setState(() => _goal = goal ?? _goal),
          ),
          const SizedBox(height: Gap.md),
          DropdownButtonFormField<ActivityLevel>(
            initialValue: _activity,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: S.activity,
              helperText: activityHelp(_activity),
              helperMaxLines: 3,
            ),
            items: [
              for (final level in ActivityLevel.values)
                DropdownMenuItem(
                  value: level,
                  child: Text(activityLabel(level)),
                ),
            ],
            onChanged: (level) =>
                setState(() => _activity = level ?? _activity),
          ),
          if (_isOnboarding) ...[
            const SizedBox(height: Gap.xl),
            Text(S.optionalMeasures, style: context.text.titleMedium),
            const SizedBox(height: Gap.xs),
            Text(
              S.optionalMeasuresHelp,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Gap.md),
            DecimalField(
              controller: _waist,
              label: S.waist,
              suffix: 'cm',
              allowZero: false,
              max: 300,
            ),
            const SizedBox(height: Gap.md),
            DecimalField(
              controller: _neck,
              label: S.neck,
              suffix: 'cm',
              allowZero: false,
              max: 100,
            ),
            const SizedBox(height: Gap.md),
            DecimalField(
              controller: _hip,
              label: S.hip,
              suffix: 'cm',
              allowZero: false,
              max: 300,
              textInputAction: TextInputAction.done,
            ),
          ],
          const SizedBox(height: Gap.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_isOnboarding ? S.start : S.save),
          ),
          if (_isOnboarding) ...[
            const SizedBox(height: Gap.md),
            Text(
              S.privacyNote,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: ProfileForm()));
  }
}

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text(S.personalData)),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ProfileForm(existing: profile),
    );
  }
}

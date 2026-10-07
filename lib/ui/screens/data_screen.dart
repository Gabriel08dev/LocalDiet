import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/backup_repository.dart';
import '../../providers.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Exportação e importação dos dados do usuário.
///
/// O app não tem nuvem: este arquivo é a única cópia de segurança. A
/// importação mostra o que o arquivo contém e pede confirmação antes de
/// substituir os dados do aparelho.
class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run(() async {
    final content = await ref.read(backupRepositoryProvider).export();
    final today = ref.read(todayProvider);
    final saved = await FilePicker.saveFile(
      fileName: 'localdiet-backup-${today.toIso()}.json',
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: 'application/json',
    );
    if (saved != null && mounted) showMessage(context, S.exportDone);
  });

  Future<void> _import() => _run(() async {
    final file = await FilePicker.pickFile();
    if (file == null) return;
    final backup = ref.read(backupRepositoryProvider);
    final String content;
    final BackupSummary summary;
    try {
      content = utf8.decode(await file.readAsBytes());
      summary = backup.inspect(content);
    } on BackupFormatException catch (error) {
      if (mounted) await _showError(error.message);
      return;
    } on FormatException {
      if (mounted) await _showError(S.importNotText);
      return;
    }
    if (!mounted) return;
    final confirmed = await confirmAction(
      context,
      title: S.importConfirmTitle,
      message: S.importSummary(summary),
      confirmLabel: S.importReplace,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await backup.restore(content);
      if (mounted) showMessage(context, S.importDone);
    } catch (_) {
      if (mounted) await _showError(S.importFailed);
    }
  });

  Future<void> _showError(String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(S.importErrorTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.ok),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.dataTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          Text(S.dataIntro, style: context.text.bodyLarge),
          const SizedBox(height: Gap.xl),
          Text(S.exportTitle, style: context.text.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(S.exportHelp, style: context.text.bodyMedium),
          const SizedBox(height: Gap.md),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text(S.exportAction),
          ),
          const SizedBox(height: Gap.xl),
          Text(S.importTitle, style: context.text.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(S.importHelp, style: context.text.bodyMedium),
          const SizedBox(height: Gap.md),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.download_outlined),
            label: const Text(S.importAction),
          ),
        ],
      ),
    );
  }
}

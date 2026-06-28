import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_diary/core/localization/app_localizations.dart';
import 'core/router/app_lifecycle_gate.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/application/settings_providers.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLogging();
  runApp(const ProviderScope(child: AppLifecycleGate(child: DiaryApp())));
}
Future<void> _configureLogging() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final buffer = StringBuffer()
      ..write('${record.level.name}: ${record.time}: ${record.message}');
    if (record.loggerName.isNotEmpty) {
      buffer.write(' | logger: ${record.loggerName}');
    }
    if (record.error != null) {
      buffer.write(' | error: ${record.error}');
    }
    if (record.stackTrace != null) {
      buffer.write(' | stack: ${record.stackTrace}');
    }
    final line = buffer.toString();
    debugPrint(line);
    unawaited(_appendAppDebugLog(line));
  });
  FlutterError.onError = (details) {
    Logger('FlutterError').severe(
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };
}
Future<void> _appendAppDebugLog(String line) async {
  if (kReleaseMode) return;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app_debug.log');
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  } on Object {
  }
}
class DiaryApp extends ConsumerWidget {
  const DiaryApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

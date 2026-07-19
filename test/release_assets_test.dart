import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:ahwt_win/generate_bat.dart' as generator;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(
        OperatingSystem.linux,
        () => DynamicLibrary.open('/lib/x86_64-linux-gnu/libsqlite3.so.0'),
      );
    }

    generator.assetRootDir = Directory.current.path;
  });

  test('Release databases resolve from primary dbs directory', () {
    for (final entry in generator.templatesPathsDBS.entries) {
      final path = generator.resolveDatabasePath(entry.key);

      expect(File(path).existsSync(), isTrue, reason: 'Missing DB for ${entry.key}');
      expect(
        path,
        contains('${Platform.pathSeparator}dbs${Platform.pathSeparator}'),
        reason: 'Expected primary dbs directory for ${entry.key}, got $path',
      );
      expect(
        path,
        isNot(contains('legacy_source_dump')),
        reason: 'Should not resolve legacy DB for ${entry.key}',
      );
    }
  });

  test('Release databases expose readable Main table content', () {
    for (final entry in generator.templatesPathsDBS.entries) {
      final path = generator.resolveDatabasePath(entry.key);
      final rows = generator.runSelect(
        path,
        'SELECT COUNT(*) AS total FROM Main;',
      );

      expect(rows, isNotEmpty, reason: 'No rows returned for ${entry.key}');
      expect(rows.first['total'] as int, greaterThan(0), reason: 'Empty Main table for ${entry.key}');
    }
  });

  test('Audit policy templates resolve from release Templates directory', () {
    for (final entry in generator.templatesPathsAuditpol.entries) {
      final path = generator.resolveAuditPolicyPath(entry.key);

      expect(File(path).existsSync(), isTrue, reason: 'Missing auditpol for ${entry.key}');
      expect(
        path,
        contains('${Platform.pathSeparator}Templates${Platform.pathSeparator}'),
        reason: 'Expected release Templates directory for ${entry.key}, got $path',
      );
      expect(
        path,
        isNot(contains('legacy_source_dump')),
        reason: 'Should not resolve legacy audit template for ${entry.key}',
      );
    }
  });

  test('Primary hardening queries return data from release databases', () async {
    const hardenings = <Map<String, String>>[
      <String, String>{'Hardenin': 'Windows XP'},
      <String, String>{'Hardenin': 'Windows Vista'},
      <String, String>{'Hardenin': 'Windows 7'},
      <String, String>{'Hardenin': 'Windows 8'},
      <String, String>{'Hardenin': 'Windows 8.1'},
      <String, String>{'Hardenin': 'Windows 10'},
      <String, String>{'Hardenin': 'Windows 11'},
      <String, String>{
        'Hardenin': 'Microsoft Office',
        'SelectedValueVersionOffice': '2016',
      },
    ];

    for (final params in hardenings) {
      final results = await generator.returnHardeninParams(<String, dynamic>{
        ...params,
      });

      expect(results, isNotEmpty, reason: 'No hardening records for ${params['Hardenin']}');
    }
  });
}

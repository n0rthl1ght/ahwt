import 'dart:ffi';
import 'dart:io';

import 'package:ahwt_win/generate_bat.dart' as generator;
import 'package:sqlite3/open.dart';

String _joinPath(List<String> parts) => parts.join(Platform.pathSeparator);

void _configureSqliteRuntime() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('/lib/x86_64-linux-gnu/libsqlite3.so.0'),
    );
  }
}

List<String> _selectAllIndices(List items) {
  return items.map((item) => item[0].toString()).toList(growable: false);
}

Future<List> _loadBaseItems({
  required String hardening,
  String? officeVersion,
}) async {
  final params = <String, dynamic>{
    'Hardenin': hardening,
  };
  if (officeVersion != null) {
    params['SelectedValueVersionOffice'] = officeVersion;
  }
  return generator.returnHardeninParams(params);
}

Future<List> _loadSingleAddonItems({
  required String hardening,
  required String addon,
  String versionIE = '-',
}) async {
  return generator.returnSingleAddonParams({
    'Hardenin': hardening,
    'SingleAddon': addon,
    'VersionIE': versionIE,
  });
}

Future<List> _loadFirewallAddonItems({
  required String hardening,
}) async {
  return generator.returnFirewallSingleAddonParams({
    'Hardenin': hardening,
    'SingleAddon': 'Firewall',
  });
}

List<List<String>> _sampleFirewallRules() {
  return const <List<String>>[
    <String>[
      'Allow HTTPS Out',
      'netsh advfirewall firewall add rule name="Allow HTTPS Out" dir=out action=allow protocol=TCP remoteport=443 profile=any',
    ],
    <String>[
      'Block SMB Out',
      'netsh advfirewall firewall add rule name="Block SMB Out" dir=out action=block protocol=TCP remoteport=445 profile=any',
    ],
  ];
}

Future<void> _generateAutoScenario({
  required String fileName,
  required String hardening,
  required String level,
  List<String> addons = const <String>[],
  String versionIE = '-',
  String shieldUp = 'No',
}) async {
  await generator.generateBatFileOSAuto({
    'Hardenin': hardening,
    'fnameBat': fileName,
    'Mode': 'Auto',
    'Addons': addons,
    'VersionIE': versionIE,
    'levelAutoMode': level,
    'isShieldUpMode': shieldUp,
  });
}

Future<void> _generateOfficeScenario({
  required String fileName,
  required String officeVersion,
  required String osname,
  bool makeRestorePoint = true,
}) async {
  await generator.generateBatFileOffice({
    'fnameBat': fileName,
    'SelectedValueVersionOSOffice': osname,
    'SelectedValueVersionOffice': officeVersion,
    'neededRestoreBackupMOffice': makeRestorePoint,
  });
}

Future<void> _generateManualScenario({
  required String fileName,
  required String hardening,
}) async {
  final baseItems = await _loadBaseItems(hardening: hardening);
  final firewallItems = await _loadFirewallAddonItems(hardening: hardening);

  await generator.generateBatFileOSManual({
    'Hardenin': hardening,
    'fnameBat': fileName,
    'neededRestoreBackupMOffice': true,
    'mainListManualPage': <Object>[
      baseItems,
      _selectAllIndices(baseItems),
    ],
    'ManualOptions_Firewall': <Object>[
      firewallItems,
      _selectAllIndices(firewallItems),
    ],
    'ManualOptions_FirewallRulesList': _sampleFirewallRules(),
  });
}

Future<void> _generateManualOfficeScenario({
  required String fileName,
  required String officeVersion,
  required String osname,
}) async {
  final officeItems = await _loadBaseItems(
    hardening: 'Microsoft Office',
    officeVersion: officeVersion,
  );

  await generator.generateBatFileOSManual({
    'Hardenin': 'Microsoft Office',
    'fnameBat': fileName,
    'SelectedValueVersionOSOffice': osname,
    'SelectedValueVersionOffice': officeVersion,
    'neededRestoreBackupMOffice': true,
    'mainListManualPage': <Object>[
      officeItems,
      _selectAllIndices(officeItems),
    ],
  });
}

Future<void> _generateSingleAddonScenario({
  required String fileName,
  required String hardening,
  required String addon,
  String versionIE = '-',
  List<List<String>> firewallRules = const <List<String>>[],
}) async {
  final items = addon == 'Firewall'
      ? await _loadFirewallAddonItems(hardening: hardening)
      : await _loadSingleAddonItems(
          hardening: hardening,
          addon: addon,
          versionIE: versionIE,
        );

  await generator.generateBatFileSingleAddon(
    {
      'Hardenin': hardening,
      'fnameBat': fileName,
      'Mode': 'Addon',
      'SingleAddon': addon,
      'FirewallRules': firewallRules,
    },
    items,
    _selectAllIndices(items),
  );
}

Future<void> main() async {
  try {
    _configureSqliteRuntime();

    final samplesDir = Directory(
      _joinPath([Directory.current.path, 'tool', 'generated_samples']),
    );
    await samplesDir.create(recursive: true);

    generator.assetRootDir = Directory.current.path;
    generator.outputDir = samplesDir.path;

    await _generateAutoScenario(
      fileName: 'auto_win10_full_defender_firewall',
      hardening: 'Windows 10',
      level: 'Full',
      addons: const <String>['Defender', 'Firewall'],
      shieldUp: 'Yes',
    );

    await _generateAutoScenario(
      fileName: 'auto_win10_full_defender_firewall_noshield',
      hardening: 'Windows 10',
      level: 'Full',
      addons: const <String>['Defender', 'Firewall'],
      shieldUp: 'No',
    );

    await _generateAutoScenario(
      fileName: 'auto_win11_min_edge',
      hardening: 'Windows 11',
      level: 'Minimum',
      addons: const <String>['Edge'],
    );

    await _generateOfficeScenario(
      fileName: 'office2016_win10',
      officeVersion: '2016',
      osname: 'ten',
    );

    await _generateManualScenario(
      fileName: 'manual_win10_all_with_firewall',
      hardening: 'Windows 10',
    );

    await _generateManualOfficeScenario(
      fileName: 'manual_office2016_win10',
      officeVersion: '2016',
      osname: 'ten',
    );

    await _generateSingleAddonScenario(
      fileName: 'addon_firewall_win10',
      hardening: 'Windows 10',
      addon: 'Firewall',
      firewallRules: _sampleFirewallRules(),
    );

    await _generateSingleAddonScenario(
      fileName: 'addon_ie11_win10',
      hardening: 'Windows 10',
      addon: 'IE',
      versionIE: 'ie11',
    );

    await _generateSingleAddonScenario(
      fileName: 'addon_bitlocker_win10',
      hardening: 'Windows 10',
      addon: 'Bitlocker',
    );

    stdout.writeln('Generated sample BAT files in: ${samplesDir.path}');
    for (final entity
        in samplesDir.listSync().whereType<File>().toList()
          ..sort((a, b) => a.path.compareTo(b.path))) {
      stdout.writeln('- ${entity.path}');
    }
  } catch (error) {
    stderr.writeln('Failed to generate sample BAT files: $error');
    stderr.writeln(
      'Hint: this script needs SQLite runtime support for the current OS. '
      'On Windows it can use the bundled sqlite3 DLL; on Linux it uses /lib/x86_64-linux-gnu/libsqlite3.so.0.',
    );
    exitCode = 1;
  }
}

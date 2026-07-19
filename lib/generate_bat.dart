import 'dart:async';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

import 'utils.dart';

/* ---------------- Global Variables - not best practice :( ------------- */

String assetRootDir = Directory.current.path;
String outputDir = Directory.current.path;
typedef BatParams = Map<String, dynamic>;

const Map<String, String> replaceOSTitles = {
    "Windows XP": "xp",
    "Windows Vista": "vista",
    "Windows 7": "seven",
    "Windows 8": "eightzero",
    "Windows 8.1": "eightone",
    "Windows 10": "ten",
    "Windows 11": "eleven",
    "Microsoft Office": "office",
};

const Map<String, String> addonsMap = {
  'IE': "IE",
  'Defender': "Defender",
  'Firewall': "Firewall",
  'Bitlocker': "BitLocker",
  'Edge': "Edge",
  'NextGenerationSecurity': "Next Generation",
};

const Map<String, String> templatesPathsAuditpol = {
  "seven": "Seven",
  "eightzero": "EightZero",
  "eightone": "EightOne",
  "ten": "Ten",
  "eleven": "Eleven",
};

const Map<String, String> templatesPathsDBS = {
  "xp": "xp_params.db",
  "vista": "vista_params.db",
  "seven": "seven_params.db",
  "eightzero": "eightzero_params.db",
  "eightone": "eightone_params.db",
  "ten": "ten_params.db",
  "eleven": "eleven_params.db",
  "office": "office.db",
};

const String startBatchHKU = ''' 
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('reg query HKU ^| findstr /r /c:"HKEY_USERS\\\\S-1-5-21-[0-9]*-[0-9]*-[0-9]*-[0-9]*"') do (
    set "user=%%a"
    set "user=!user:HKEY_USERS=HKU!"
    echo Found User: !user!\r\n\r\n''';

const String endBatchHKU = ''' 
if errorlevel 1 (
        echo An error occurred while adding the parameter for !user!
        exit /b 1
    )
    echo Parameter added for !user!
)

echo All users in HKU have been successfully processed.

endlocal\r\n''';

String _joinPath(List<String> parts) {
  return parts.join(Platform.pathSeparator);
}

void initializeRuntimePaths() {
  final String executableDir = File(Platform.resolvedExecutable).parent.path;
  final String bundledDataDir =
      _joinPath([executableDir, 'data']);

  final bool hasBundledReleaseAssets =
      Directory(_joinPath([bundledDataDir, 'dbs'])).existsSync() ||
      Directory(_joinPath([bundledDataDir, 'Templates'])).existsSync();

  if (hasBundledReleaseAssets) {
    assetRootDir = executableDir;
  } else {
    assetRootDir = Directory.current.path;
  }
}

String? resolveOptionalRuntimeFile(String fileName) {
  final List<String> candidates = <String>[
    _joinPath([assetRootDir, fileName]),
    _joinPath([assetRootDir, 'data', fileName]),
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }

  return null;
}

String _resolveExistingFile(List<String> candidates, String label) {
  for (final candidate in candidates) {
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }
  throw FileSystemException('Required $label was not found', candidates.first);
}

String resolveDatabasePath(String osname) {
  final String? databaseFileName = templatesPathsDBS[osname];
  if (databaseFileName == null) {
    throw ArgumentError('Unknown database name for OS: $osname');
  }

  return _resolveExistingFile([
    _joinPath([assetRootDir, 'dbs', databaseFileName]),
    _joinPath([assetRootDir, 'data', 'dbs', databaseFileName]),
  ], 'database for $osname');
}

String resolveAuditPolicyPath(String osname) {
  final String? templateDir = templatesPathsAuditpol[osname];
  if (templateDir == null) {
    throw ArgumentError('Unknown audit policy template for OS: $osname');
  }

  return _resolveExistingFile([
    _joinPath([assetRootDir, 'Templates', templateDir, 'auditpol_$osname']),
    _joinPath([assetRootDir, 'data', 'Templates', templateDir, 'auditpol_$osname']),
  ], 'audit policy template for $osname');
}

String resolveOutputBatPath(String fileName) {
  return _joinPath([outputDir, fileName]);
}

String normalizeBatFileName(String fileName) {
  if (fileName.endsWith('.bat')) {
    return fileName;
  }
  return '$fileName.bat';
}

bool outputBatFileExists(String fileName) {
  final normalizedFileName = normalizeBatFileName(fileName);
  return File(resolveOutputBatPath(normalizedFileName)).existsSync();
}

String normalizeDbTextValue(Object? value) {
  return value?.toString() ?? '';
}

List<dynamic> buildUiRecord(int index, Row record) {
  return <dynamic>[
    index,
    normalizeDbTextValue(record['reg_key']),
    normalizeDbTextValue(record['reg_value']),
    normalizeDbTextValue(record['value_type']),
    normalizeDbTextValue(record['parameter']),
    normalizeDbTextValue(record['description']),
    normalizeDbTextValue(record['description_ru']),
    normalizeDbTextValue(record['level']),
    normalizeDbTextValue(record['profile']),
  ];
}

bool shouldDeleteOfficeEntry(
  String regKey,
  String regValue,
  List<String> deleteMarkers,
) {
  for (final marker in deleteMarkers) {
    if (regKey.contains(marker) || regValue.contains(marker)) {
      return true;
    }
  }
  return false;
}

String buildRegistryCommand({
  required String command,
  required String regKey,
  required String regValue,
  required String valueType,
  required String parameter,
}) {
  if (command == 'delete') {
    if (regValue.isEmpty) {
      return 'reg delete "$regKey" /f';
    }
    return 'reg delete "$regKey" /v "$regValue" /f';
  }

  if (regValue.isEmpty || valueType.isEmpty) {
    throw ArgumentError(
      'Registry add command requires non-empty value name and value type for key: $regKey',
    );
  }

  return 'reg add "$regKey" /v "$regValue" /t $valueType /d "$parameter" /f';
}

String buildRegistryEcho({
  required String indent,
  required String action,
  required String regKey,
  required String regValue,
  required String valueType,
  required String parameter,
}) {
  if (action == 'Deleting') {
    if (regValue.isEmpty) {
      return '${indent}echo Deleting "$regKey" /f';
    }
    return '${indent}echo Deleting "$regKey" /v "$regValue" /f';
  }

  return '${indent}echo Applying "$regKey" /v "$regValue" /t $valueType /d "$parameter" /f';
}

bool shouldSkipAutoBaseRecord({
  required String regKey,
  required String regValue,
  required List<String> addons,
}) {
  if (!addons.contains('Firewall')) {
    return false;
  }

  return regKey == 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess' &&
      regValue == 'Start';
}

bool shouldSkipManualBaseRecord({
  required String regKey,
  required String regValue,
  required BatParams batParameters,
}) {
  if (batParameters['ManualOptions_Firewall'] == null) {
    return false;
  }

  return regKey == 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess' &&
      regValue == 'Start';
}

String readStringParam(
  BatParams batParameters,
  String key, {
  String fallback = '-',
}) {
  final value = batParameters[key];
  if (value is String) {
    return value;
  }
  return fallback;
}

List<String> readStringListParam(
  BatParams batParameters,
  String key, {
  List<String> fallback = const <String>[],
}) {
  final value = batParameters[key];
  if (value is List) {
    return List<String>.from(value);
  }
  return List<String>.from(fallback);
}

bool readBoolParam(
  BatParams batParameters,
  String key, {
  bool fallback = false,
}) {
  final value = batParameters[key];
  if (value is bool) {
    return value;
  }
  return fallback;
}

List<Row> runSelect(String databasePath, String sqlRequest) {
  final db = sqlite3.open(databasePath);
  try {
    return db.select(sqlRequest).toList(growable: false);
  } finally {
    db.dispose();
  }
}

/* ----------------Funcs Returning parameters from db.sqlite3------------- */

Future<List> returnFirewallSingleAddonParams(BatParams batParameters) async {

  List paramsToReturn = [];
  String singleAddon = readStringParam(batParameters, 'SingleAddon');
  String hardeninType = readStringParam(batParameters, 'Hardenin');
  String osname = replaceOSTitles[hardeninType] ?? '-';
  try {
    if (singleAddon == 'Firewall') {

      String sqlRequest;
      if (osname == 'xp' || osname == 'vista') {
        sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile FROM Main WHERE profile IN ('Firewall');";
      }
      else
      {
        sqlRequest = """
                        SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile 
                        FROM Main 
                        WHERE profile IN ('Firewall') 
                        AND reg_key NOT IN (
                            'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile',
                            'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile\\Logging',
                            'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile',
                            'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile\\Logging'
                        );
                    """;
      }
      String databasePath = resolveDatabasePath(osname);
      var results = runSelect(databasePath, sqlRequest);

      if (results.isNotEmpty) {

        int index = 0;
        for (var record in results) {
          paramsToReturn.add(buildUiRecord(index, record));
          index += 1;
        }
      }
    }
  }

  catch (err) {
    stderr.writeln('returnFirewallSingleAddonParams error: $err');
  }

  // return Future.value(paramsToReturn);
  return Future.delayed(const Duration(milliseconds: 600), () => paramsToReturn);
}

Future<List> returnSingleAddonParams(BatParams batParameters) async {
  List paramsToReturn = [];
  String singleAddon = readStringParam(batParameters, 'SingleAddon');
  String hardeninType = readStringParam(batParameters, 'Hardenin');
  String versionIE = readStringParam(batParameters, 'VersionIE');
  String osname = replaceOSTitles[hardeninType] ?? '-';

  try {

    if (singleAddon == 'Defender' || singleAddon == 'Bitlocker' || singleAddon == 'Edge' || singleAddon == 'NextGenerationSecurity') {

      String databasePath = resolveDatabasePath(osname);
      var profile = addonsMap[singleAddon];
      String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile FROM Main WHERE profile IN ('$profile');";
      var results = runSelect(databasePath, sqlRequest);

      if (results.isNotEmpty) {
        int index = 0;
        for (var record in results) {
          paramsToReturn.add(buildUiRecord(index, record));
          index += 1;
        }
      }
    }

    if (singleAddon == 'IE') {
      if (versionIE != '-') {
        String databasePath = resolveDatabasePath(osname);
        String versionIEStr = versionIE.split(",").join("','");
        String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile FROM Main WHERE profile IN ('$versionIEStr');";
        var results = runSelect(databasePath, sqlRequest);
        if (results.isNotEmpty) {
          int index = 0;
          for (var record in results) {
            paramsToReturn.add(buildUiRecord(index, record));
            index += 1;
          }
        }

      }
    }
  }

  catch (err) {
    stderr.writeln('returnSingleAddonParams error: $err');
  }

  // return Future.value(paramsToReturn);
  return Future.delayed(const Duration(milliseconds: 700), () => paramsToReturn);
}

Future<List> returnHardeninParams(BatParams batParameters) async {

  List paramsToReturn = [];
  String hardeninType = readStringParam(batParameters, 'Hardenin');

  String osname = replaceOSTitles[hardeninType] ?? '-';
  late List<Row> results;
  try {
      if (osname != 'office') {
        String databasePath = resolveDatabasePath(osname);
        String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11');";
        results = runSelect(databasePath, sqlRequest);
        // var db = await databaseFactory.openDatabase(databasePath);
        // results = await db.rawQuery(sqlRequest);

      }
      else {
        Map<String, List<String>> profiles = {
          '2003': ['"Office2003"', '"OfficeHKLM"'],
          '2007': ['"Office2007"', '"OfficeHKLM"'],
          '2010': ['"Office2010"', '"OfficeHKLM"'],
          '2013': ['"Office2013"', '"OfficeHKLM"'],
          '2016': ['"Office2016"', '"OfficeHKLM"'],
          '365': ['"Office2016"', '"Office365"', '"OfficeHKLM"'],
        };
        String selectedValueVersion = readStringParam(
          batParameters,
          'SelectedValueVersionOffice',
          fallback: '2003',
        );
        List<String> profile = profiles[selectedValueVersion] ?? profiles['2003']!;
        String profileStr = profile.join(',');
        String databasePath = resolveDatabasePath('office');
        String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description, description_ru, level, profile FROM Main WHERE profile IN ($profileStr);";
        results = runSelect(databasePath, sqlRequest);
        // var db = await databaseFactory.openDatabase(databasePath);
        // results = await db.rawQuery(sqlRequest);
      }
      if (results.isNotEmpty) {
        int index = 0;
        for (var record in results) {
          paramsToReturn.add(buildUiRecord(index, record));
          index += 1;
        }
      }
  }

  catch (err) {
    stderr.writeln('returnHardeninParams error: $err');
  }

  // return Future.value(paramsToReturn);
  return Future.delayed(const Duration(milliseconds: 700), () => paramsToReturn);
}

/* ---------------- Funcs Generating Bat-files ------------- */

Future<String> generateBatFileOSAuto(BatParams batParameters) async {
  // "Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"
  String hardeninType = readStringParam(batParameters, 'Hardenin');
  String fnameBat = readStringParam(batParameters, 'fnameBat'); //abs path without .bat
  String mode = readStringParam(batParameters, 'Mode'); // Auto, Manual, Addon
  // 2003, 2007, 2010, 2013, 2016, 365
  // 'IE', 'Defender', 'Firewall', 'Bitlocker', 'Edge', 'NextGenerationSecurity'
  List<String> addons = readStringListParam(batParameters, 'Addons');
  String versionIE = readStringParam(batParameters, 'VersionIE');
  String levelAuto = readStringParam(batParameters, 'levelAutoMode');
  String isShieldUpMode = readStringParam(
    batParameters,
    'isShieldUpMode',
    fallback: 'No',
  );
  String osname = replaceOSTitles[hardeninType] ?? '-';

  fnameBat = normalizeBatFileName(fnameBat);

  if (mode == 'Auto') {
    // def write_common_content(bat_file, db_file, filename, osname)
    List<String> batStrings = [
      "@echo off\r\n",
    ];

    // def write_restore_point(bat_file, db_file, filename)
    batStrings.add("\r\necho Adding commands...");
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"");
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "vista") {
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "xp") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("sc config srservice start= auto");
      batStrings.add("net start srservice");
      batStrings.add("echo Creating restore point...");
    }
    batStrings.add(
        'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT $fnameBat script", 100, 7');


    batStrings.add("echo Applying secedit configuration...");
    batStrings.add(
        'secedit /configure /db "secedit_db_$osname.sdb" /areas securitypolicy group_mgmt user_rights filestore /cfg hisecdc_$osname.inf');
    batStrings.add("bcdedit /set {current} nx OptOut");
    if (osname == "seven" || osname == "eightzero" || osname == "eightone") {
      batStrings.add("echo Installing EMET...");
      batStrings.add('msiexec /i "EMET Setup.msi" /qn /norestart');
    }
    // def write_audit_policies(bat_file, db_file_str)
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add('echo Applying audit policies...');
      batStrings.add('auditpol /clear /y');
    }

    if (templatesPathsAuditpol[osname] != null) {
      String fileStrings = await readTextFile(resolveAuditPolicyPath(osname));
      List<String> listFileStrings = fileStrings.split('\n');
      List<String> tmpAudPolStrings = [];
      for (String audPolString in listFileStrings) {
        audPolString = audPolString.replaceAll('\n', '');
        audPolString = audPolString.replaceAll('\r', '');
        tmpAudPolStrings.add(audPolString);
      }
      batStrings = batStrings + tmpAudPolStrings;
    }

    batStrings.add('\r\n');
    if (osname != "xp" && osname != "vista") {
      batStrings.add('gpupdate /force');
      batStrings.add('auditpol /get /category:*');
      batStrings.add('pause');
    }
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      //def write_optional_services(bat_file)
      batStrings.add('echo Disabling optional services...');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -norestart"');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -norestart"');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -norestart"');
    }

    ///def write_netconns
    batStrings.add(
        "echo Blocking Win32 binaries from making network connections when they shouldn't...");
    if (osname == 'xp') {
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\notepad.exe" name="Block Notepad.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\regsvr32.exe" name="Block regsvr32.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\calc.exe" name="Block calc.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\mshta.exe" name="Block mshta.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\wscript.exe" name="Block wscript.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\cscript.exe" name="Block cscript.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\hh.exe" name="Block hh.exe netconns" mode=disable profile=ALL');
    }
    if (osname == 'vista') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }
    if (osname == 'seven' || osname == 'eightzero' || osname == 'eightone') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\\system32\\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }
    if (osname == 'ten' || osname == 'eleven') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\\system32\\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block runscripthelper.exe netconns" program="%systemroot%\\system32\\runscripthelper.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }

    batStrings.add('\r\necho Adding register values...');

      if (mode == 'Auto') {
      const Map<String, String> autoProfile = {
        'Minimum': 'min',
        'Medium': 'med',
        'Full': 'full',
      };

      const Map<String, String> profiles = {
        'full': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')",
        'med': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')",
        'min': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'Med', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"
      };

      String levelSql = autoProfile[levelAuto] ?? 'min';
      String finishSql = profiles[levelSql] ?? profiles['min']!;
      String databasePath = resolveDatabasePath(osname);
      String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile $finishSql;";

      // var db = await databaseFactory.openDatabase(databasePath);
      // print(sqlRequest);
      // var results = await db.rawQuery(sqlRequest);
      var results = runSelect(databasePath, sqlRequest);


      List hkuRecords = [];
      for (var record in results) {
        // reg_key, reg_value, value_type, parameter, description, level, profile
        final recordKey = normalizeDbTextValue(record['reg_key']);
        final recordValue = normalizeDbTextValue(record['reg_value']);
        if (shouldSkipAutoBaseRecord(
          regKey: recordKey,
          regValue: recordValue,
          addons: addons,
        )) {
          continue;
        }
        if (recordKey.contains('HKEY_CURRENT_USER')) {
          hkuRecords.add(record);
        }
        else {
          String recordValue0 = recordKey;
          String recordValue1 = recordValue;
          String recordValue2 = normalizeDbTextValue(record['value_type']);
          String recordValue3 = normalizeDbTextValue(record['parameter']);
          String recordValue4 = normalizeDbTextValue(record['description']);
          // String record_value_5 = record['level'].toString();
          // String record_value_6 = record['profile'].toString();
          String action = 'Applying';
          String command = 'add';
          if (recordValue4.contains('POSIX')) {
            action = 'Deleting';
            command = 'delete';
          }

          batStrings.add(
              'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
          batStrings.add(
              'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
        }
      }

      if (hkuRecords.isNotEmpty) {
        batStrings.add(startBatchHKU);
        for (var recordHku in hkuRecords) {
          String recordValue0 = normalizeDbTextValue(recordHku['reg_key']);
          String recordValue1 = normalizeDbTextValue(recordHku['reg_value']);
          String recordValue2 = normalizeDbTextValue(recordHku['value_type']);
          String recordValue3 = normalizeDbTextValue(recordHku['parameter']);
          String recordValue4 = normalizeDbTextValue(recordHku['description']);

          String action = 'Applying';
          String command = 'add';
          if (recordValue4.contains('POSIX')) {
            action = 'Deleting';
            command = 'delete';
          }

          batStrings.add(
              'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
          batStrings.add(
              'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');

        }
        batStrings.add(endBatchHKU);
      }

    }

      /// ADDITION ADDONS
      // 'IE', 'Defender', 'Firewall', 'Bitlocker', 'Edge', 'NextGenerationSecurity'
      if (addons.isNotEmpty) {

        for (var singleAddon in addons) {

          if (singleAddon == 'IE') {
            if (versionIE != '-') {
              String databasePath = resolveDatabasePath(osname);
              String versionIEStr = versionIE.split(",").join("','");
              String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('$versionIEStr');";
              // print(sqlRequest);
              // var db = await databaseFactory.openDatabase(databasePath);
              // var results = await db.rawQuery(sqlRequest);

              var results = runSelect(databasePath, sqlRequest);

              if (results.isNotEmpty) {
              batStrings.add('\r\necho Adding Internet Explorer values... ');

              for (var record in results) {

                  String recordValue0 = normalizeDbTextValue(record['reg_key']);
                  String recordValue1 = normalizeDbTextValue(record['reg_value']);
                  String recordValue2 = normalizeDbTextValue(record['value_type']);
                  String recordValue3 = normalizeDbTextValue(record['parameter']);
                  String action = 'Applying';
                  String command = 'add';

                  batStrings.add(
                      'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
                  batStrings.add(
                      'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
                }
              }
            }
          }

          if (singleAddon == 'Firewall') {


            String sqlRequest;
            if (osname == 'xp' || osname == 'vista') {
              sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Firewall');";
            }
            else
            {
              sqlRequest = """
                        SELECT reg_key, reg_value, value_type, parameter, description 
                        FROM Main 
                        WHERE profile IN ('Firewall') 
                        AND reg_key NOT IN (
                            'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile',
                            'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile\\Logging',
                            'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile',
                            'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile\\Logging'
                        );
                    """;
            }
            String databasePath = resolveDatabasePath(osname);
            // var db = await databaseFactory.openDatabase(databasePath);
            // var results = await db.rawQuery(sqlRequest);
            var results = runSelect(databasePath, sqlRequest);
            if (results.isNotEmpty) {
              batStrings.add('\r\necho Adding Firewall values... ');
              for (var record in results) {

                String recordValue0 = record['reg_key'].toString();
                String recordValue1 = record['reg_value'].toString();
                String recordValue2 = record['value_type'].toString();
                String recordValue3 = record['parameter'].toString();
                String action = 'Applying';
                String command = 'add';
                if (recordValue1.contains('DoNotAllowExceptions') && isShieldUpMode == 'No') {
                    continue;
                }
                else {
                  batStrings.add(
                      'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
                  batStrings.add(
                      'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
                }
              }
            }
          }

          if (singleAddon == 'Defender' || singleAddon == 'Bitlocker' || singleAddon == 'Edge' || singleAddon == 'NextGenerationSecurity') {
            String databasePath = resolveDatabasePath(osname);
            var profile = addonsMap[singleAddon];
            String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('$profile');";
            // var db = await databaseFactory.openDatabase(databasePath);
            // var results = await db.rawQuery(sqlRequest);
            var results = runSelect(databasePath, sqlRequest);
            if (results.isNotEmpty) {
              batStrings.add('\r\necho Adding $profile values...');
              for (var record in results) {
                String recordValue0 = record['reg_key'].toString();
                String recordValue1 = record['reg_value'].toString();
                String recordValue2 = record['value_type'].toString();
                String recordValue3 = record['parameter'].toString();
                String action = 'Applying';
                String command = 'add';

                batStrings.add(
                    'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
                batStrings.add(
                    'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
              }
            }
          }

        }
      }

    batStrings.add('\r\necho Mission Accomplished! :)');
    batStrings.add('pause');
    String batStringsString = batStrings.join('\r\n');
    batStringsString = batStringsString.replaceAll('HKEY_CURRENT_USER', '!user!');
    // batStringsString = batStringsString.replaceAll('\n\n', '\n');
    await writeTextFile(resolveOutputBatPath(fnameBat), batStringsString);
  }
      return 'OK';
}

Future<String> generateBatFileOSManual(BatParams batParameters) async {
  String hardeninType = readStringParam(batParameters, 'Hardenin');
  String fnameBat = readStringParam(batParameters, 'fnameBat'); //abs path without .bat
  late String osname;
  if (hardeninType=='Microsoft Office') {
    osname = readStringParam(batParameters, 'SelectedValueVersionOSOffice');
  }
  else {
    osname = replaceOSTitles[hardeninType] ?? '-';
  }

  bool makeRestoreOffice = readBoolParam(
    batParameters,
    'neededRestoreBackupMOffice',
    fallback: true,
  );
  List mainListManualPage = batParameters['mainListManualPage'] ?? [[],[]];
  List itemsToListMain = mainListManualPage[0];
  List isChoosingFeatureListMain = mainListManualPage[1];

  fnameBat = normalizeBatFileName(fnameBat);

  List<String> batStrings = [
    "@echo off\r\n",
  ];

  if (makeRestoreOffice) {
    batStrings.add("\r\necho Adding commands...");
    // def write_restore_point(bat_file, db_file, filename)
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"");
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "vista") {
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "xp") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("sc config srservice start= auto");
      batStrings.add("net start srservice");
      batStrings.add("echo Creating restore point...");
    }

    batStrings.add(
        'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT $fnameBat script", 100, 7');
  }

if (hardeninType!='Microsoft Office') {

    batStrings.add("echo Applying secedit configuration...");
    batStrings.add(
        'secedit /configure /db "secedit_db_$osname.sdb" /areas securitypolicy group_mgmt user_rights filestore /cfg hisecdc_$osname.inf');
    batStrings.add("bcdedit /set {current} nx OptOut");
    if (osname == "seven" || osname == "eightzero" || osname == "eightone") {
      batStrings.add("echo Installing EMET...");
      batStrings.add('msiexec /i "EMET Setup.msi" /qn /norestart');
    }
    // def write_audit_policies(bat_file, db_file_str)
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add('echo Applying audit policies...');
      batStrings.add('auditpol /clear /y');
    }

    if (templatesPathsAuditpol[osname] != null) {
      String fileStrings = await readTextFile(resolveAuditPolicyPath(osname));
      List<String> listFileStrings = fileStrings.split('\n');
      List<String> tmpAudPolStrings = [];
      for (String audPolString in listFileStrings) {
        audPolString = audPolString.replaceAll('\n', '');
        audPolString = audPolString.replaceAll('\r', '');
        tmpAudPolStrings.add(audPolString);
      }
      batStrings = batStrings + tmpAudPolStrings;
    }

    batStrings.add('\r\n');
    if (osname != "xp" && osname != "vista") {
      batStrings.add('gpupdate /force');
      batStrings.add('auditpol /get /category:*');
      batStrings.add('pause');
    }
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      //def write_optional_services(bat_file)
      batStrings.add('echo Disabling optional services...');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -norestart"');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -norestart"');
      batStrings.add(
          'powershell "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -norestart"');
    }

    ///def write_netconns
    batStrings.add(
        "echo Blocking Win32 binaries from making network connections when they shouldn't...");
    if (osname == 'xp') {
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\notepad.exe" name="Block Notepad.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\regsvr32.exe" name="Block regsvr32.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\calc.exe" name="Block calc.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\mshta.exe" name="Block mshta.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\wscript.exe" name="Block wscript.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\cscript.exe" name="Block cscript.exe netconns" mode=disable profile=ALL');
      batStrings.add(
          'netsh firewall add allowedprogram program="%systemroot%\\system32\\hh.exe" name="Block hh.exe netconns" mode=disable profile=ALL');
    }
    if (osname == 'vista') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }
    if (osname == 'seven' || osname == 'eightzero' || osname == 'eightone') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\\system32\\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }
    if (osname == 'ten' || osname == 'eleven') {
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\\system32\\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\\system32\\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\\system32\\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\\system32\\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\\system32\\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\\system32\\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any');
      batStrings.add(
          'netsh advfirewall firewall add rule name="Block runscripthelper.exe netconns" program="%systemroot%\\system32\\runscripthelper.exe" protocol=tcp dir=out enable=yes action=block profile=any');
    }

  }

  if (isChoosingFeatureListMain.isNotEmpty) {
    batStrings.add('\r\necho Adding register values...');
    List hkuRecords = [];

    for (List itemList in itemsToListMain) {
      String idxItem = itemList[0].toString();
      if (isChoosingFeatureListMain.contains(idxItem)) {
        String recordValue0 = itemList[1];
        String recordValue1 = itemList[2];
        String recordValue2 = itemList[3];
        String recordValue3 = itemList[4];
        String recordValue4 = itemList[5];
        if (shouldSkipManualBaseRecord(
          regKey: recordValue0,
          regValue: recordValue1,
          batParameters: batParameters,
        )) {
          continue;
        }
        String action = 'Applying';
        String command = 'add';
        List record = [recordValue0, recordValue1, recordValue2, recordValue3, recordValue4];

        if (hardeninType == 'Microsoft Office') {
          if (shouldDeleteOfficeEntry(recordValue0, recordValue1, const [
            'OutlookSecureTempFolder',
            'FileExtensionsRemoveLevel1',
            'FileExtensionsRemoveLevel2',
            'TrustedAddins',
            'allowdde',
          ])) {
            action = 'Deleting';
            command = 'delete';
          }
        } else if (recordValue4.contains('POSIX')) {
          action = 'Deleting';
          command = 'delete';
        }

        if (recordValue0.contains('HKEY_CURRENT_USER')) {
          hkuRecords.add(record);
        }
        else {
          if (hardeninType == 'Microsoft Office') {
            batStrings.add(
              buildRegistryEcho(
                indent: '',
                action: action,
                regKey: recordValue0,
                regValue: recordValue1,
                valueType: recordValue2,
                parameter: recordValue3,
              ),
            );
            batStrings.add(
              buildRegistryCommand(
                command: command,
                regKey: recordValue0,
                regValue: recordValue1,
                valueType: recordValue2,
                parameter: recordValue3,
              ),
            );
          } else {
            batStrings.add(
                'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
            batStrings.add(
                'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
          }
        }
      }

    }
      if (hkuRecords.isNotEmpty) {

        batStrings.add(startBatchHKU);

        for (var recordHku in hkuRecords) {
          String recordValue0 = recordHku[0];
          String recordValue1 = recordHku[1];
          String recordValue2 = recordHku[2];
          String recordValue3 = recordHku[3];
          String recordValue4 = recordHku[4];

          String action = 'Applying';
          String command = 'add';
          if (hardeninType == 'Microsoft Office') {
            if (shouldDeleteOfficeEntry(recordValue0, recordValue1, const [
              'OutlookSecureTempFolder',
              'FileExtensionsRemoveLevel1',
              'FileExtensionsRemoveLevel2',
              'TrustedAddins',
              'allowdde',
            ])) {
              action = 'Deleting';
              command = 'delete';
            }
          } else if (recordValue4.contains('POSIX')) {
            action = 'Deleting';
            command = 'delete';
          }

          if (hardeninType == 'Microsoft Office') {
            batStrings.add(
              buildRegistryEcho(
                indent: '\t',
                action: action,
                regKey: recordValue0,
                regValue: recordValue1,
                valueType: recordValue2,
                parameter: recordValue3,
              ),
            );
            batStrings.add(
              '\t${buildRegistryCommand(
                command: command,
                regKey: recordValue0,
                regValue: recordValue1,
                valueType: recordValue2,
                parameter: recordValue3,
              )}',
            );
          } else {
            batStrings.add(
                'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
            batStrings.add(
                'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
          }

        }
        batStrings.add(endBatchHKU);
      }

  }

  List addonsList = ['Firewall', 'IE', 'Defender', 'Bitlocker', 'Edge', 'NextGenerationSecurity'];
  String keyValFWRules = 'ManualOptions_FirewallRulesList';
  for (String addonTitle in addonsList) {
    String keyValue = 'ManualOptions_$addonTitle';

    if (batParameters[keyValue] != null) {
      List itemsListsAddon = batParameters[keyValue] ?? [[],[]];
      List allItemsSql = itemsListsAddon[0];
      List choosingParameters = itemsListsAddon[1];


      if (allItemsSql.isNotEmpty) {
        batStrings.add("\r\necho Adding $addonTitle values...");
        for (List itemList in allItemsSql) {
          String idxItem = itemList[0].toString();
          if (choosingParameters.contains(idxItem)) {
            String recordValue0 = itemList[1].toString();
            String recordValue1 = itemList[2].toString();
            String recordValue2 = itemList[3].toString();
            String recordValue3 = itemList[4].toString();
            String action = 'Applying';
            String command = 'add';

            batStrings.add(
                'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
            batStrings.add(
                'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
          }
        }
      }


      if (addonTitle == 'Firewall') {
        if (batParameters[keyValFWRules] != null) {
          List firewallRulesList = batParameters[keyValFWRules];
          if (firewallRulesList.isNotEmpty) {
            for (List itemList in firewallRulesList) {
              batStrings.add(
                  '\r\necho Applying rule ${itemList[0]}');
              batStrings.add(
                  '${itemList[1]}');
            }
          }
        }
      }
    }
  }


  batStrings.add('\necho Mission Accomplished! :)');
  batStrings.add('pause');
  String batStringsString = batStrings.join('\r\n');
  batStringsString = batStringsString.replaceAll('HKEY_CURRENT_USER', '!user!');
  batStringsString = batStringsString.replaceAll("echo Blocking Win32 binaries from making network connections when they shouldn't...", 'echo Blocking Win32 binaries from making network connections');
  await writeTextFile(resolveOutputBatPath(fnameBat), batStringsString);

  return 'ok';
}

Future<String> generateBatFileOffice(BatParams batParameters) async {

  String fnameBat = readStringParam(batParameters, 'fnameBat'); //abs path without .bat
  String osname = readStringParam(batParameters, 'SelectedValueVersionOSOffice');
  String selectedValueVersion = readStringParam(batParameters, 'SelectedValueVersionOffice');
  bool makeRestoreOffice = readBoolParam(
    batParameters,
    'neededRestoreBackupMOffice',
    fallback: true,
  );
  List<String> batStrings = [
      "@echo off\r\n",
    ];


  if (makeRestoreOffice) {
    batStrings.add("\r\necho Adding commands...");
    // def write_restore_point(bat_file, db_file, filename)
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"");
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "vista") {
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "xp") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("sc config srservice start= auto");
      batStrings.add("net start srservice");
      batStrings.add("echo Creating restore point...");
    }
    fnameBat = normalizeBatFileName(fnameBat);
    batStrings.add(
        'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT $fnameBat script", 100, 7\r\n');
  }

  const Map<String, List<String>> profiles = {
        '2003': ['"Office2003"', '"OfficeHKLM"'],
        '2007': ['"Office2007"', '"OfficeHKLM"'],
        '2010': ['"Office2010"', '"OfficeHKLM"'],
        '2013': ['"Office2013"', '"OfficeHKLM"'],
        '2016': ['"Office2016"', '"OfficeHKLM"'],
        '365': ['"Office2016"', '"Office365"', '"OfficeHKLM"'],
    };

  List<String> profile = profiles[selectedValueVersion] ?? profiles['2016']!;
  String profileStr = profile.join(',');
  String databasePath = resolveDatabasePath('office');
  String sqlRequest = "SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ($profileStr);";

  var results = runSelect(databasePath, sqlRequest);
  List hkuRecords = [];

  List<String> itemsDels = ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'TrustedAddins', 'allowdde'];
  String indent = '';
  batStrings.add("\r\necho Adding register values...");
  for (var record in results) {
    // reg_key, reg_value, value_type, parameter, description, level, profile

    String recordValue0 = record['reg_key'].toString();
    String recordValue1 = record['reg_value'].toString();
    String recordValue2 = record['value_type'].toString();
    String recordValue3 = record['parameter'].toString();
    // String recordValue4 = record['description'].toString();

    if (recordValue0.toString().contains('HKEY_LOCAL_MACHINE')) {
      indent = '';
      String action = 'Applying';
      String command = 'add';
      if (shouldDeleteOfficeEntry(recordValue0, recordValue1, itemsDels)) {
        action = 'Deleting';
        command = 'delete';
      }
      batStrings.add(
        buildRegistryEcho(
          indent: indent,
          action: action,
          regKey: recordValue0,
          regValue: recordValue1,
          valueType: recordValue2,
          parameter: recordValue3,
        ),
      );
      batStrings.add(
        '$indent${buildRegistryCommand(
          command: command,
          regKey: recordValue0,
          regValue: recordValue1,
          valueType: recordValue2,
          parameter: recordValue3,
        )}',
      );
    }

      if (recordValue0.toString().contains('HKEY_CURRENT_USER')) {
        hkuRecords.add(record);
      }
    }

  if (hkuRecords.isNotEmpty) {
    indent = '\t';
    batStrings.add(startBatchHKU);
    for (var recordHku in hkuRecords) {
      String recordValue0 = recordHku['reg_key'].toString();
      String recordValue1 = recordHku['reg_value'].toString();
      String recordValue2 = recordHku['value_type'].toString();
      String recordValue3 = recordHku['parameter'].toString();
      // String recordValue4 = recordHku['description'].toString();

      String action = 'Applying';
      String command = 'add';
      if (shouldDeleteOfficeEntry(recordValue0, recordValue1, itemsDels)) {
        action = 'Deleting';
        command = 'delete';
      }
      batStrings.add(
        buildRegistryEcho(
          indent: indent,
          action: action,
          regKey: recordValue0,
          regValue: recordValue1,
          valueType: recordValue2,
          parameter: recordValue3,
        ),
      );
      batStrings.add(
        '$indent${buildRegistryCommand(
          command: command,
          regKey: recordValue0,
          regValue: recordValue1,
          valueType: recordValue2,
          parameter: recordValue3,
        )}',
      );
    }
    batStrings.add(endBatchHKU);
  }

  batStrings.add('\r\necho Mission Accomplished! :)');
  batStrings.add('pause');
  String batStringsString = batStrings.join('\r\n');
  batStringsString = batStringsString.replaceAll('HKEY_CURRENT_USER', '!user!');
  batStringsString = batStringsString.replaceAll("echo Blocking Win32 binaries from making network connections when they shouldn't...", 'echo Blocking Win32 binaries from making network connections');
  await writeTextFile(resolveOutputBatPath(fnameBat), batStringsString);

  return 'OK';

}

Future<String> generateBatFileSingleAddon(BatParams batParameters, List allItemsSql, List choosingParameters) async {

  // "Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"
  String hardeninType = readStringParam(batParameters, 'Hardenin');
  String fnameBat = readStringParam(batParameters, 'fnameBat'); //abs path without .bat
  String mode = readStringParam(batParameters, 'Mode'); // Auto, Manual, Addon
  // 2003, 2007, 2010, 2013, 2016, 365
  String titleSingleAddon = readStringParam(
    batParameters,
    'SingleAddon',
    fallback: '???',
  );
  String osname = replaceOSTitles[hardeninType] ?? '-';
  List firewallRulesList = batParameters['FirewallRules'] ?? []; // [[rule, command]]

  if (mode == 'Addon') {
    // def write_common_content(bat_file, db_file, filename, osname)
    List<String> batStrings = [
      "@echo off\r\n",
    ];

    fnameBat = normalizeBatFileName(fnameBat);

    batStrings.add("\r\necho Adding commands...");
    // def write_restore_point(bat_file, db_file, filename)
    if (osname == "seven" || osname == "eightzero" || osname == "eightone" ||
        osname == "ten" || osname == "eleven") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"");
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "vista") {
      batStrings.add("echo Creating restore point...");
    }
    if (osname == "xp") {
      batStrings.add("echo Enabling Restore Point service...");
      batStrings.add("sc config srservice start=auto");
      batStrings.add("net start srservice");
      batStrings.add("echo Creating restore point...");
    }

    batStrings.add(
        'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT $fnameBat script", 100, 7');

    if (allItemsSql.isNotEmpty) {
    batStrings.add("\n\recho Adding $titleSingleAddon values...");
    for (List itemList in allItemsSql) {
      String idxItem = itemList[0].toString();
      if (choosingParameters.contains(idxItem)) {
        String recordValue0 = itemList[1].toString();
        String recordValue1 = itemList[2].toString();
        String recordValue2 = itemList[3].toString();
        String recordValue3 = itemList[4].toString();
        String action = 'Applying';
        String command = 'add';

        batStrings.add(
            'echo $action "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
        batStrings.add(
            'reg $command "$recordValue0" /v "$recordValue1" /t $recordValue2 /d "$recordValue3" /f');
      }
    }
    }

    if (firewallRulesList.isNotEmpty)
      {
        for (List itemList in firewallRulesList) {

          batStrings.add(
              '\n\recho Applying rule ${itemList[0]}');
          batStrings.add(
              '${itemList[1]}\n');
        }
      }

    batStrings.add('\r\necho Mission Accomplished! :)');
    batStrings.add('pause');
    String batStringsString = batStrings.join('\r\n');
    batStringsString = batStringsString.replaceAll('HKEY_CURRENT_USER', '!user!');
    batStringsString = batStringsString.replaceAll("echo Blocking Win32 binaries from making network connections when they shouldn't...", 'echo Blocking Win32 binaries from making network connections');
    await writeTextFile(resolveOutputBatPath(fnameBat), batStringsString);

  }
      return 'OK';

}


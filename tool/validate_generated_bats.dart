import 'dart:io';

String _joinPath(List<String> parts) => parts.join(Platform.pathSeparator);

List<String> _validateFile(String fileName, String text) {
  final findings = <String>[];

  final invalidAddEmptyValue = RegExp(r'reg add ".*" /v ""');
  final invalidDeleteWithTypeOrData = RegExp(r'reg delete ".*" .*/t .*|reg delete ".*" .*/d ".*"');
  final invalidEmptyType = RegExp(r'reg add ".*" /v ".*" /t\s+/d');
  final suspiciousNullValue = RegExp(r'/d "null"');

  if (invalidAddEmptyValue.hasMatch(text)) {
    findings.add('contains reg add with empty value name');
  }
  if (invalidDeleteWithTypeOrData.hasMatch(text)) {
    findings.add('contains reg delete with add-style /t or /d arguments');
  }
  if (invalidEmptyType.hasMatch(text)) {
    findings.add('contains reg add with empty value type');
  }
  if (suspiciousNullValue.hasMatch(text)) {
    findings.add('contains literal /d "null"');
  }

  final hasFirewallSection = text.contains('echo Adding Firewall values...');
  final hasSharedAccessDisable = text.contains(
    'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess" /v "Start" /t REG_DWORD /d "4"',
  );
  if (hasFirewallSection && hasSharedAccessDisable) {
    findings.add('contains Firewall section together with SharedAccess Start=4');
  }

  if (fileName.contains('noshield') && text.contains('DoNotAllowExceptions')) {
    findings.add('contains DoNotAllowExceptions despite Shield Up = No');
  }

  if (fileName.contains('manual_office') || fileName.contains('office2016')) {
    if (!text.contains('Mission Accomplished! :)')) {
      findings.add('missing completion marker');
    }
  }

  return findings;
}

Future<void> main() async {
  final samplesDir = Directory(
    _joinPath([Directory.current.path, 'tool', 'generated_samples']),
  );

  if (!samplesDir.existsSync()) {
    stderr.writeln('generated_samples directory does not exist');
    exitCode = 1;
    return;
  }

  final files = samplesDir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var findingsCount = 0;
  for (final file in files) {
    final text = await file.readAsString();
    final findings = _validateFile(file.uri.pathSegments.last, text);
    if (findings.isEmpty) {
      stdout.writeln('OK ${file.path}');
      continue;
    }

    findingsCount += findings.length;
    stdout.writeln('FINDINGS ${file.path}');
    for (final finding in findings) {
      stdout.writeln('- $finding');
    }
  }

  if (findingsCount > 0) {
    exitCode = 1;
  }
}

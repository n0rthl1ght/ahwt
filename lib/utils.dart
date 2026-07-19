import 'dart:io';
import "package:validator_regex/validator_regex.dart" show Validator;


/* ----------------Validators------------- */

bool _isValidPortToken(String value) {
  final parsed = int.tryParse(value);
  return parsed != null && parsed >= 1 && parsed <= 65535;
}

bool _isValidPortRange(String value) {
  final parts = value.split('-');
  if (parts.length != 2) {
    return false;
  }

  if (!_isValidPortToken(parts[0]) || !_isValidPortToken(parts[1])) {
    return false;
  }

  return int.parse(parts[0]) <= int.parse(parts[1]);
}

String? validatePathToProgram(String pathToProgram) {
  RegExp expLocalPath = RegExp(r'^[a-zA-Z]:\\(?:[^\\\/:*?\"<>|\r\n]+\\)*[^\\\/:*?"<>|\r\n]+\.(exe|bat|ps1)$');
  RegExp expNetworkPath = RegExp(r'^\\\\[^\\\/:*?"<>|\r\n]+\\(?:[^\\\/:*?"<>|\r\n]+\\)*[^\\\/:*?"<>|\r\n]+\.(exe|bat|ps1)$');
  if (expLocalPath.hasMatch(pathToProgram)) {
    return null;
  }
  if (expNetworkPath.hasMatch(pathToProgram)) {
    return null;
  }

  return 'invalid value';
}

String? validatePorts(String ipPort, String currentSelectedMode) {
  try {
    if (ipPort=='' && currentSelectedMode=='ip') {
      return null;
    }

    ipPort = ipPort.replaceAll(' ', '').trim();

    if (ipPort == '') {
      return null;
    }

    if (_isValidPortToken(ipPort)) {
      return null;
    }

    if (ipPort.contains(',')) {
      for (String ipPortSingle in ipPort.split(',')) {
        if (!_isValidPortToken(ipPortSingle)) {
          return 'in list invalid port';
        }
      }
      return null;
    }

    if (ipPort.contains('-')) {
      if (_isValidPortRange(ipPort)) {
        return null;
      }
      return 'in range invalid port';
    }

    return 'invalid value';
  }
  catch (err) {
    return 'error validation';
  }

}

String? validateIPAddresses(String ipAddress, bool allowLocalnet, bool isSilentField) {

  ipAddress = ipAddress.replaceAll(' ', '').trim();

  if (isSilentField) {
    return null;
  }

  if (ipAddress == '') {
    return null;
  }
  // if (ipAddress == '' && currentSelectedMode=='port') {
  //   return null;
  // }
  // if (ipAddress == '' && currentSelectedMode=='program') {
  //   return null;
  // }

  // localsubnet
  if (ipAddress.toLowerCase() == 'localsubnet' && allowLocalnet) {
    return null;
  }

  // одиночный ip
  bool isIpValid = Validator.ipAddress(ipAddress);
  if (isIpValid) {
    return null;
  }

  // список ip
  if (ipAddress.contains(',')) {
    bool overallResults = true;
    for (String ipAddrSingle in ipAddress.split(',')) {
      if (!Validator.ipAddress(ipAddrSingle)) {
        overallResults = false;
      }
    }
    if (!overallResults) {
      return 'list has invalid ip';
    }
    else {
      return null;
    }
  }
    if (ipAddress.contains('-')) {
      bool overallResults = true;
      for (String ipAddrSingle in ipAddress.split('-')) {
        if (!Validator.ipAddress(ipAddrSingle)) {
          overallResults = false;
        }
      }
      if (!overallResults) {
        return 'range has invalid ip';
      }
      else {
        return null;
      }
  }

  return 'invalid value';
}

String? validateIPAddressesXP(String ipAddress) {
  RegExp expSubNet = RegExp(r'^([01]?\d\d?|2[0-4]\d|25[0-5])(?:\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])){3}(?:/[0-2]\d|/3[0-2])?$');
  ipAddress = ipAddress.replaceAll(' ', '').trim();

  if (ipAddress == '') {
    return null;
  }

  // localsubnet
  if (ipAddress.toLowerCase() == 'localsubnet') {
    return null;
  }

  // одиночный ip
  bool isIpValid = Validator.ipAddress(ipAddress);
  if (isIpValid) {
    return null;
  }

  // список ip
  if (ipAddress.contains(',')) {
    bool overallResults = true;
    for (String ipAddrSingle in ipAddress.split(',')) {
      if (ipAddrSingle.contains('/')) {
        if (!expSubNet.hasMatch(ipAddrSingle)) {
          overallResults = false;
        }
      }
      else {
        if (ipAddrSingle!='localsubnet') {
          bool isIpValid = Validator.ipAddress(ipAddrSingle);
          if (!isIpValid) {
            overallResults = false;
          }
        }
      }
    }
    if (!overallResults) {
      return 'list has invalid ip';
    }
    else {
      return null;
    }
  }
  return 'invalid value';
}

String? validatePortsXP(String ipPort) {
  try {
    if (ipPort=='') {
      return null;
    }

    ipPort = ipPort.replaceAll(' ', '').trim();

    if (ipPort == '') {
      return null;
    }

    if (_isValidPortToken(ipPort)) {
      return null;
    }

    if (ipPort.contains(',')) {
      for (String ipPortSingle in ipPort.split(',')) {
        if (!_isValidPortToken(ipPortSingle)) {
          return 'in list invalid port';
        }
      }
      return null;
    }

    if (ipPort.contains('-')) {
      if (_isValidPortRange(ipPort)) {
        return null;
      }
      return 'in range invalid port';
    }

    return 'invalid value';
  }
  catch (err) {
    return 'error validation';
  }

}

/* ---------------- read/write text-files ------------- */

Future<String> readTextFile(fPath) async {
  String? text = '';
  // print(fPath);
  try {
    final File file = File(fPath);
    text = await file.readAsString();
    return text;
  } catch (e) {
    // print("Couldn't read file");
    return '';
  }
}

Future<void> writeTextFile(fPath, recordString) async {
  try {
    final File file = File(fPath);
    await file.writeAsString(recordString);
  } catch (e) {

    // print("Couldn't write to file");
  }
}

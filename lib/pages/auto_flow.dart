part of '../main.dart';

/* -------------Addons Page--------------------- */
class AddonsPage extends StatefulWidget {
  const AddonsPage({super.key});
  static const routeName = '/setAddons';

  @override
  State<AddonsPage> createState() => _AddonsPageState();
}

class _AddonsPageState extends State<AddonsPage> {
  var currentHardenin = batParameters['Hardenin'];
  var currentFilename = batParameters['fnameBat'];
  var currentMode = batParameters['Mode'];
  List<String> isChoosingAddons = [];

  static const listAddonsIE = ["Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10"];
  static const listAddonsDefender = ["Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsBitlocker = ["Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsEdge = ["Windows 10", "Windows 11"];
  static const listAddonsNextGenerationSecurity = ["Windows 10", "Windows 11"];

  List<String> _buildAvailableAddons() {
    final List<String> addonsList = <String>['Firewall'];
    if (listAddonsIE.contains(currentHardenin)) {
      addonsList.add('IE');
    }
    if (listAddonsDefender.contains(currentHardenin)) {
      addonsList.add('Defender');
    }
    if (listAddonsBitlocker.contains(currentHardenin)) {
      addonsList.add('Bitlocker');
    }
    if (listAddonsEdge.contains(currentHardenin)) {
      addonsList.add('Edge');
    }
    if (listAddonsNextGenerationSecurity.contains(currentHardenin)) {
      addonsList.add('NextGenerationSecurity');
    }
    return addonsList;
  }

  String _buildAddonsSummary() {
    return '${tr('Hardening', 'Харденинг')}: $currentHardenin\n'
        '${tr('Filename', 'Имя файла')}: $currentFilename\n'
        '${tr('Mode', 'Режим')}: $currentMode';
  }

  Widget _buildAddonsChecklist(List<String> addonsList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 250,
        child: ListView(
          shrinkWrap: true,
          children: addonsList.map((option) => CheckboxListTile(
            title: Text(option),
            value: isChoosingAddons.contains(option),
            contentPadding: const EdgeInsets.symmetric(horizontal: 1),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  isChoosingAddons.add(option);
                } else {
                  isChoosingAddons.remove(option);
                }
              });
            },
          )).toList(),
        ),
      ),
    );
  }

  void _goFromAddonsPage(BuildContext context) {
    batParameters['Addons'] = isChoosingAddons;

    if (isChoosingAddons.contains('IE')) {
      if (currentHardenin == 'Windows 8.1' || currentHardenin == 'Windows 10') {
        batParameters['VersionIE'] = 'ie11';
        if (isChoosingAddons.contains('Firewall')) {
          Navigator.of(context).pushNamed('/chooseShieldUpMode');
        } else {
          Navigator.of(context).pushNamed('/finishHardeninPage');
        }
      } else {
        Navigator.of(context).pushNamed('/chooseIEPage');
      }
      return;
    }

    if (isChoosingAddons.contains('Firewall')) {
      Navigator.of(context).pushNamed('/chooseShieldUpMode');
    } else {
      Navigator.of(context).pushNamed('/finishHardeninPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final List<String> addonsList = _buildAvailableAddons();
      final String currentSummary = _buildAddonsSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentSummary,
                  style: TextStyle(
                    fontSize: 19,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Choose addons:', 'Выберите аддоны:'),
                  style: TextStyle(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildAddonsChecklist(addonsList),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () => _goFromAddonsPage(context),
                  child: Text(
                    tr('Next', 'Далее'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/* -------------IE Choosing Page--------------------- */
class IeChoosingMode extends StatefulWidget {
  const IeChoosingMode({super.key});
  static const routeName = '/chooseIEPage';
  @override
  State<IeChoosingMode> createState() => _IeChoosingModeState();
}

class _IeChoosingModeState extends State<IeChoosingMode> {
  String currentSelectedOS = batParameters['Hardenin'];
  String currentFilename = batParameters['fnameBat'];
  String currentSelectedMode = batParameters['Mode'];
  List<String> currentAddonsList = batParameters['Addons'] ?? [];
  String? selectedValue;

  List<DropdownMenuItem<String>> menuItems = [];
  final _dropdownFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> _buildIeMenuItems() {
    final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
    if (!currentAddonsList.contains('IE')) {
      return items;
    }
    if (currentSelectedOS == 'Windows XP') {
      items.add(const DropdownMenuItem(value: 'ie6', child: Text('ie6')));
      items.add(const DropdownMenuItem(value: 'ie6,ie7', child: Text('ie7')));
      items.add(const DropdownMenuItem(value: 'ie6,ie7,ie8', child: Text('ie8')));
    }
    if (currentSelectedOS == 'Windows Vista') {
      items.add(const DropdownMenuItem(value: 'ie7', child: Text('ie7')));
      items.add(const DropdownMenuItem(value: 'ie7,ie8', child: Text('ie8')));
      items.add(const DropdownMenuItem(value: 'ie7,ie8,ie9', child: Text('ie9')));
    }
    if (currentSelectedOS == 'Windows 7') {
      items.add(const DropdownMenuItem(value: 'ie8', child: Text('ie8')));
      items.add(const DropdownMenuItem(value: 'ie8,ie9', child: Text('ie9')));
      items.add(const DropdownMenuItem(value: 'ie8,ie9,ie10', child: Text('ie10')));
      items.add(const DropdownMenuItem(value: 'ie8,ie9,ie10,ie11', child: Text('ie11')));
    }
    if (currentSelectedOS == 'Windows 8') {
      items.add(const DropdownMenuItem(value: 'ie10', child: Text('ie10')));
      items.add(const DropdownMenuItem(value: 'ie10,ie11', child: Text('ie11')));
    }
    return items;
  }

  void _goFromIeChoosingPage(BuildContext context) {
    selectedIEVersion = selectedValue;
    if (selectedIEVersion == '') {
      return;
    }
    batParameters['VersionIE'] = selectedIEVersion;
    if (currentSelectedMode == 'Addon') {
      batParameters['Addons'] = ['IE'];
      currentListValuesSingleAddon = [];
      Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
      return;
    }
    if (currentSelectedMode == 'Manual') {
      batParameters['Addons'] = ['IE'];
      currentListValuesSingleAddon = [];
      Navigator.pushNamed(context, '/finishHardeninSingleAddonPage').then((_) => setState(() {}));
      return;
    }
    if (currentAddonsList.contains('Firewall')) {
      Navigator.pushNamed(context, '/chooseShieldUpMode');
    } else {
      Navigator.pushNamed(context, '/finishHardeninPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      batParameters['makeTwiceGoBack'] = '+';
      menuItems = _buildIeMenuItems();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _dropdownFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Choose IE Version:', 'Выберите версию IE:'),
                  style: TextStyle(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null ? tr('Choose version', 'Выберите версию') : null,
                    dropdownColor: colorScheme.surfaceContainerHigh,
                    initialValue: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                        selectedIEVersion = newValue;
                      });
                    },
                    items: menuItems,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () => _goFromIeChoosingPage(context),
                  child: Text(
                    tr('Next', 'Далее'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/* -------------ShieldUpMode Page--------------------- */
class ShieldUpModePage extends StatefulWidget {
  const ShieldUpModePage({super.key});
  static const routeName = '/chooseShieldUpMode';
  @override
  State<ShieldUpModePage> createState() => _ShieldUpModePageState();
}

class _ShieldUpModePageState extends State<ShieldUpModePage> {
  List<DropdownMenuItem<String>> get modeListChoiceItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "No", child: Text("No")),
      const DropdownMenuItem(value: "Yes", child: Text("Yes")),
    ];
    return menuItems;
  }

  var selectedValue = 'No';

  String _buildShieldUpSummary() {
    final String currentSelectedOS = batParameters['Hardenin'];
    final String currentFilename = batParameters['fnameBat'];
    final String currentSelectedMode = batParameters['Mode'];
    return 'Hardening: $currentSelectedOS\nFilename: $currentFilename\nMode: $currentSelectedMode';
  }

  Widget _buildShieldUpDropdown() {
    return Center(
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (value) => value == null ? 'Yes or No' : null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          initialValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: modeListChoiceItems,
        ),
      ),
    );
  }

  void _goFromShieldUpPage(BuildContext context) {
    batParameters['isShieldUpMode'] = selectedValue;
    Navigator.of(context).pushNamed('/finishHardeninPage');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final String currentSummary = _buildShieldUpSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentSummary,
                  style: TextStyle(fontSize: 19, color: colorScheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Enable ShieldUp Mode?', 'Включить режим ShieldUp?'),
                  style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                ),
              ),
              _buildShieldUpDropdown(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () => _goFromShieldUpPage(context),
                  child: Text(
                    tr('Next', 'Далее'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/* ----------------Finish Hardenin Mode------------- */
class FinishHardeninPage extends StatefulWidget {
  const FinishHardeninPage({super.key});
  static const routeName = '/finishHardeninPage';
  @override
  State<FinishHardeninPage> createState() => _FinishHardeninPageState();
}

class _FinishHardeninPageState extends State<FinishHardeninPage> {
  String currentHardenin = batParameters['Hardenin'];
  String currentFilename = batParameters['fnameBat'];
  String currentLevelAutoMode = batParameters['levelAutoMode'] ?? '-';
  String currentSelectedMode = batParameters['Mode'];
  String selectedIEVersion = batParameters['VersionIE'] ?? '-';
  List<String> currentAddonsList = List<String>.from(batParameters['Addons'] ?? <String>[]);
  String isShieldUpMode = batParameters['isShieldUpMode'] ?? 'No';

  String _normalizeIeVersion() {
    if (!selectedIEVersion.contains(',')) {
      return selectedIEVersion;
    }
    final List<String> ieParts = selectedIEVersion.split(',');
    return ieParts[ieParts.length - 1];
  }

  String _buildFinishSummary() {
    selectedIEVersion = _normalizeIeVersion();
    String currentAddonsListString = currentAddonsList.join(',');
    if (currentAddonsListString.isEmpty) {
      currentAddonsListString = '-';
    }
    final List<String> listItems = <String>[
      '${tr('Hardening', 'Харденинг')}: $currentHardenin',
      '${tr('Filename', 'Имя файла')}: $currentFilename',
      '${tr('Mode', 'Режим')}: $currentSelectedMode',
      '${tr('Level (auto)', 'Уровень (авто)')}: $currentLevelAutoMode',
      '${tr('Addons', 'Аддоны')}: $currentAddonsListString',
      'IE: $selectedIEVersion',
      '${tr('ShieldUpMode', 'ShieldUp режим')}: $isShieldUpMode',
    ];
    final List<String> filteredItems = <String>[];
    for (final String element in listItems) {
      if (element.contains(': -')) {
        continue;
      }
      if (element.contains(tr('ShieldUpMode', 'ShieldUp режим')) &&
          !currentAddonsListString.contains('Firewall')) {
        continue;
      }
      filteredItems.add(element);
    }
    return filteredItems.join('\n');
  }

  Future<void> _showFinishMessage(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message, style: const TextStyle(fontSize: 20)),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(tr('OK', 'ОК')),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAutoBat(BuildContext context) async {
    try {
      await generateBatFileOSAuto(batParameters);
      if (!context.mounted) return;
      await _showFinishMessage(
        context,
        tr('Your file is saved.', 'Файл успешно сохранен.'),
      );
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/');
    } catch (error) {
      if (!context.mounted) return;
      await _showFinishMessage(
        context,
        '${tr('Some Error', 'Ошибка')}: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final String presentString = _buildFinishSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Current config:', 'Текущая конфигурация:'),
                  style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  presentString,
                  style: TextStyle(fontSize: 19, color: colorScheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () async => _submitAutoBat(context),
                  child: Text(
                    tr('Make .bat-file!', 'Создать .bat-файл!'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/* ----------------Choose Auto Mode (Full, Medium, Min)------------- */
class LevelDetailAutoPage extends StatefulWidget {
  const LevelDetailAutoPage({super.key});
  static const routeName = '/chooseLevelAutoMode';
  @override
  State<LevelDetailAutoPage> createState() => _LevelDetailAutoPageState();
}

class _LevelDetailAutoPageState extends State<LevelDetailAutoPage> {
  String? selectedValue = 'Minimum';

  List<DropdownMenuItem<String>> get modeListChoiceItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Minimum", child: Text("Minimum")),
      const DropdownMenuItem(value: "Medium", child: Text("Medium")),
      const DropdownMenuItem(value: "Full", child: Text("Full")),
    ];
    return menuItems;
  }

  String _buildLevelAutoSummary() {
    final String currentSelectedOS = batParameters['Hardenin'];
    final String currentFilename = batParameters['fnameBat'];
    final String currentSelectedMode = batParameters['Mode'];
    return '${tr('Hardening', 'Харденинг')}: $currentSelectedOS\n'
        '${tr('Filename', 'Имя файла')}: $currentFilename\n'
        '${tr('Mode', 'Режим')}: $currentSelectedMode';
  }

  Widget _buildLevelAutoDropdown() {
    return Center(
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (value) => value == null ? tr('Choose level', 'Выберите уровень') : null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          initialValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: modeListChoiceItems,
        ),
      ),
    );
  }

  void _goToAddonsPage(BuildContext context) {
    batParameters['levelAutoMode'] = selectedValue;
    Navigator.of(context).pushNamed('/setAddons');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final String currentSummary = _buildLevelAutoSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentSummary,
                  style: TextStyle(fontSize: 19, color: colorScheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Choose Level Auto Mode:', 'Выберите уровень авто-режима:'),
                  style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                ),
              ),
              _buildLevelAutoDropdown(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () => _goToAddonsPage(context),
                  child: Text(
                    tr('Next', 'Далее'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/* ----------------Addons Single Page------------- */
class AddonsSinglePage extends StatefulWidget {
  const AddonsSinglePage({super.key});
  static const routeName = '/setSingleAddons';
  @override
  State<AddonsSinglePage> createState() => _AddonsSinglePageState();
}

class _AddonsSinglePageState extends State<AddonsSinglePage> {
  var currentHardenin = batParameters['Hardenin'];
  var currentFilename = batParameters['fnameBat'];
  List<String> currentAddonsList = batParameters['Addons'] ?? [];
  var currentMode = batParameters['Mode'];
  List<DropdownMenuItem<String>> menuItems = [];
  String? selectedValue;

  static const listAddonsIE = ["Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10"];
  static const listAddonsDefender = ["Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsBitlocker = ["Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsEdge = ["Windows 10", "Windows 11"];
  static const listAddonsNextGenerationSecurity = ["Windows 10", "Windows 11"];
  final _dropdownFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> _buildSingleAddonMenuItems() {
    final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: "Firewall", child: Text("Firewall")),
    ];
    if (listAddonsIE.contains(currentHardenin)) {
      items.add(const DropdownMenuItem(value: "IE", child: Text("IE")));
    }
    if (listAddonsDefender.contains(currentHardenin)) {
      items.add(const DropdownMenuItem(value: "Defender", child: Text("Defender")));
    }
    if (listAddonsBitlocker.contains(currentHardenin)) {
      items.add(const DropdownMenuItem(value: "Bitlocker", child: Text("Bitlocker")));
    }
    if (listAddonsEdge.contains(currentHardenin)) {
      items.add(const DropdownMenuItem(value: "Edge", child: Text("Edge")));
    }
    if (listAddonsNextGenerationSecurity.contains(currentHardenin)) {
      items.add(const DropdownMenuItem(value: "NextGenerationSecurity", child: Text("NextGenerationSecurity")));
    }
    return items;
  }

  String _buildSingleAddonSummary() {
    return '${tr('Hardening', 'Харденинг')}: $currentHardenin\n'
        '${tr('Filename', 'Имя файла')}: $currentFilename\n'
        '${tr('Mode', 'Режим')}: $currentMode';
  }

  Widget _buildSingleAddonDropdown(List<DropdownMenuItem<String>> menuItems) {
    return Center(
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (value) => value == null ? tr('Choose addon', 'Выберите аддон') : null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          initialValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: menuItems,
        ),
      ),
    );
  }

  void _goFromSingleAddonPage(BuildContext context) {
    currentListValuesSingleAddon = [
      '',
      '-',
      '-',
      '-',
      '-',
      tr('Choose any item in left list', 'Выберите любой элемент в левом списке'),
      'Выберите любой элемент в левом списке',
    ];
    batParameters['SingleAddon'] = selectedValue;
    batParameters['FirewallRules'] = [];
    _keyControllerOffset = 0;

    if (selectedValue == 'IE') {
      batParameters['Addons'] = ['IE'];
      if (batParameters['Hardenin'] == 'Windows 10' ||
          batParameters['Hardenin'] == 'Windows 8.1') {
        batParameters['VersionIE'] = 'ie11';
        Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
      } else {
        Navigator.pushNamed(context, '/chooseIEPage');
      }
      return;
    }

    Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      menuItems = _buildSingleAddonMenuItems();
      final String currentSummary = _buildSingleAddonSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      selectedValue ??= menuItems[0].value;

      return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _dropdownFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentSummary,
                  style: TextStyle(fontSize: 19, color: colorScheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr('Choose Addon:', 'Выберите аддон:'),
                  style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                ),
              ),
              _buildSingleAddonDropdown(menuItems),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () {
                    if (selectedValue != '') {
                      _goFromSingleAddonPage(context);
                    }
                  },
                  child: Text(
                    tr('Next', 'Далее'),
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

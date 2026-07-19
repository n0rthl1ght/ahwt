part of '../main.dart';

/* ------------Main Page---------------------- */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  static const routeName = '/';
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedValue;
  final _dropdownFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> get hardeningListChoiceItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Windows XP", child: Text("Windows XP")),
      const DropdownMenuItem(value: "Windows Vista", child: Text("Windows Vista")),
      const DropdownMenuItem(value: "Windows 7", child: Text("Windows 7")),
      const DropdownMenuItem(value: "Windows 8", child: Text("Windows 8")),
      const DropdownMenuItem(value: "Windows 8.1", child: Text("Windows 8.1")),
      const DropdownMenuItem(value: "Windows 10", child: Text("Windows 10")),
      const DropdownMenuItem(value: "Windows 11", child: Text("Windows 11")),
      const DropdownMenuItem(value: "Microsoft Office", child: Text("Microsoft Office")),
    ];
    return menuItems;
  }

  var selectedOS = "Windows XP";

  Widget _buildLanguageAndThemeControls() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, _, __) => ValueListenableBuilder<String>(
        valueListenable: appLanguageNotifier,
        builder: (context, language, _) {
          final bool isRussian = language == 'ru';
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: tr('Toggle theme', 'Сменить тему'),
                onPressed: () {
                  appThemeModeNotifier.value =
                      isDarkTheme ? ThemeMode.light : ThemeMode.dark;
                },
                icon: Icon(
                  isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  appLanguageNotifier.value = isRussian ? 'en' : 'ru';
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    isRussian ? 'ENG' : 'RUS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHardeningDropdown() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double dropdownWidth =
            constraints.maxWidth < 332 ? constraints.maxWidth - 32 : 300;

        return Center(
          child: SizedBox(
            width: dropdownWidth,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                filled: true,
              ),
              validator: (value) => value == null ? tr('Choose value', 'Выберите значение') : null,
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              initialValue: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  selectedOS = newValue;
                });
              },
              items: hardeningListChoiceItems,
            ),
          ),
        );
      },
    );
  }

  void _goFromHomePage(BuildContext context) {
    batParameters['Hardenin'] = selectedOS;
    Navigator.of(context).pushNamed('/setFname');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      batParameters = {};
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        body: SafeArea(
          child: Form(
            key: _dropdownFormKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: _buildLanguageAndThemeControls(),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tr(
                            'Choose Hardening',
                            'Выберите элемент для усиления защиты',
                          ),
                          style: TextStyle(
                            fontSize: 26,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      _buildHardeningDropdown(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                          ),
                          onPressed: () async {
                            if (_dropdownFormKey.currentState!.validate()) {
                              if (selectedOS != '') {
                                _goFromHomePage(context);
                              }
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
              ],
            ),
          ),
        ),
      );
    });
  }
}

/* ------------Set Filename---------------------- */
class SetFilename extends StatefulWidget {
  const SetFilename({super.key});
  static const routeName = '/setFname';

  @override
  State<SetFilename> createState() => _SetFilenameState();
}

class _SetFilenameState extends State<SetFilename> {
  TextEditingController fnameController = TextEditingController();

  String currentHardening = batParameters['Hardenin'];

  String _buildFilenameSummary() {
    return '${tr('Selected hardening', 'Выбранный харденинг')}: $currentHardening';
  }

  Future<void> _showFilenameMessage(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          message,
          style: const TextStyle(fontSize: 20),
        ),
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

  Future<void> _goFromSetFilename(BuildContext context) async {
    String fnameBat = fnameController.text;
    if (fnameBat.isEmpty) {
      return;
    }

    fnameBat = normalizeBatFileName(fnameBat);
    if (outputBatFileExists(fnameBat)) {
      await _showFilenameMessage(
        context,
        tr('File already exists :(', 'Файл уже существует :('),
      );
      return;
    }

    batParameters['fnameBat'] = fnameBat;
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushNamed('/setMode');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final String currentSummary = _buildFilenameSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Text(
                  currentSummary,
                  style: TextStyle(
                    fontSize: 19,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: fnameController,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText:
                          tr('Enter bat filename', 'Введите имя bat-файла'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () {
                    _goFromSetFilename(context);
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

/* -----------Set Mode-------------------- */
class SetMode extends StatefulWidget {
  const SetMode({super.key});
  static const routeName = '/setMode';
  @override
  State<SetMode> createState() => _SetModeState();
}

class _SetModeState extends State<SetMode> {
  String? selectedValue;
  final _dropdownFormKey = GlobalKey<FormState>();
  String currentHardening = batParameters['Hardenin'];
  String currentFname = batParameters['fnameBat'];

  var selectedMode = 'Auto';

  List<DropdownMenuItem<String>> _buildModeMenuItems() {
    final List<DropdownMenuItem<String>> menuItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'Auto', child: Text(tr('Auto', 'Авто'))),
      DropdownMenuItem(value: 'Manual', child: Text(tr('Manual', 'Ручной'))),
    ];
    if (currentHardening != 'Microsoft Office') {
      menuItems.add(DropdownMenuItem(value: 'Addon', child: Text(tr('Addon', 'Аддон'))));
    }
    return menuItems;
  }

  String _buildModeSummary() {
    return '${tr('Hardening', 'Харденинг')}: $currentHardening\n${tr('Filename', 'Имя файла')}: $currentFname';
  }

  Widget _buildModeDropdown(List<DropdownMenuItem<String>> menuItems) {
    return Center(
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (value) => value == null ? tr('Choose value', 'Выберите значение') : null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          initialValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
              selectedMode = newValue;
            });
          },
          items: menuItems,
        ),
      ),
    );
  }

  void _resetModeState() {
    chooseManualPageItems = [];
    currentListValuesSingleAddon = [];
    for (final keyAddon in manualAddonResetKeys) {
      batParameters[keyAddon] = null;
    }
    _keyControllerOffset = 0;
    _keyControllerOffsetManualPage = 0;
  }

  void _goFromSetMode(BuildContext context) {
    batParameters['Mode'] = selectedMode;
    _resetModeState();

    if (currentHardening == 'Microsoft Office') {
      Navigator.of(context).pushNamed('/OfficeSettingsPageAuto');
      return;
    }

    if (selectedMode == 'Auto') {
      Navigator.of(context).pushNamed('/chooseLevelAutoMode');
      return;
    }
    if (selectedMode == 'Addon') {
      batParameters['levelAutoMode'] = '-';
      Navigator.of(context).pushNamed('/setSingleAddons');
      return;
    }
    if (selectedMode == 'Manual') {
      chooseManualPageItems = [];
      Navigator.of(context).pushNamed('/ManualPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      batParameters['FirewallRules'] = [];
      final List<DropdownMenuItem<String>> menuItems = _buildModeMenuItems();
      final String currentSummary = _buildModeSummary();
      final ColorScheme colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Form(
            key: _dropdownFormKey,
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
                    tr('Choose mode:', 'Выберите режим:'),
                    style: TextStyle(
                      fontSize: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildModeDropdown(menuItems),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                    onPressed: () async {
                      if (_dropdownFormKey.currentState!.validate()) {
                        if (selectedMode != '') {
                          _goFromSetMode(context);
                        }
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
        ),
      );
    });
  }
}

/* ----------Microsoft Office------------------ */
class ModeChooseOffice extends StatefulWidget {
  const ModeChooseOffice({super.key});
  static const routeName = '/setModeOffice';
  @override
  State<ModeChooseOffice> createState() => _ModeChooseOfficeState();
}

class _ModeChooseOfficeState extends State<ModeChooseOffice> {
  String? selectedValue;
  final _dropdownFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> get modeListChoiceItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "2003", child: Text("2003")),
      const DropdownMenuItem(value: "2007", child: Text("2007")),
      const DropdownMenuItem(value: "2010", child: Text("2010")),
      const DropdownMenuItem(value: "2013", child: Text("2013")),
      const DropdownMenuItem(value: "2016", child: Text("2016")),
      const DropdownMenuItem(value: "365", child: Text("365")),
    ];
    return menuItems;
  }

  var selectedOffice = '2003';
  String currentFname = batParameters['fnameBat'];

  String _buildOfficeModeSummary() {
    return '${tr('Filename', 'Имя файла')}: $currentFname';
  }

  Widget _buildOfficeModeDropdown() {
    return Center(
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
          ),
          validator: (value) => value == null ? tr('Choose value', 'Выберите значение') : null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          initialValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
              selectedOffice = newValue;
            });
          },
          items: modeListChoiceItems,
        ),
      ),
    );
  }

  void _goFromModeChooseOffice(BuildContext context) {
    batParameters['VersionOffice'] = selectedOffice;
    Navigator.of(context).pushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      final String currentSummary = _buildOfficeModeSummary();
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
                  tr('Choose Office Version', 'Выберите версию Office'),
                  style: TextStyle(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildOfficeModeDropdown(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () {
                    if (_dropdownFormKey.currentState!.validate()) {
                      if (selectedOffice != '') {
                        _goFromModeChooseOffice(context);
                      }
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

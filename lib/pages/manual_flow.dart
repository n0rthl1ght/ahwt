part of '../main.dart';

class SingleAddonFinishPage extends StatefulWidget {
  const SingleAddonFinishPage({super.key});
  static const routeName = '/finishHardeninSingleAddonPage';

  @override
  State<SingleAddonFinishPage> createState() => _SingleAddonFinishPageState();
}

class _SingleAddonFinishPageState extends State<SingleAddonFinishPage> {
  String singleAddon = batParameters['SingleAddon'];
  String hardeninType = batParameters['Hardenin'];
  String mode = batParameters['Mode'];
  List manualAdditionAddonsList = batParameters['ManualAdditionsAddonsList'] ?? [];
  List paramsMap = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  DataChoosedProvider? _singleAddonDataProvider;
  late final Future<List> _dataFuture;
  String _searchQuery = '';
  String _sortMode = 'key';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataFuture = getData();
  }

  Future<List> getData() async {
    if (paramsMap.isEmpty) {
      if (singleAddon == 'Firewall') {
        paramsMap = await returnFirewallSingleAddonParams(batParameters);
      } else {
        paramsMap = await returnSingleAddonParams(batParameters);
      }
    }
    return paramsMap;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _singleAddonDataProvider?.dispose();
    super.dispose();
  }

  String _normalizeRecordText(dynamic value) {
    return value?.toString().toLowerCase() ?? '';
  }

  void _restoreSearchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  List _applySingleAddonViewState(List sourceItems) {
    final List filtered = sourceItems.where((dynamic item) {
      final List record = item as List;
      final String regKey = _normalizeRecordText(record[1]);
      final String regValue = _normalizeRecordText(record[2]);
      final bool matchesSearch = _searchQuery.isEmpty ||
          regKey.contains(_searchQuery) ||
          regValue.contains(_searchQuery);

      return matchesSearch;
    }).toList(growable: false);

    filtered.sort((dynamic a, dynamic b) {
      final List left = a as List;
      final List right = b as List;
      final String leftValue = _sortMode == 'value'
          ? _normalizeRecordText(left[2])
          : _normalizeRecordText(left[1]);
      final String rightValue = _sortMode == 'value'
          ? _normalizeRecordText(right[2])
          : _normalizeRecordText(right[1]);
      final int result = leftValue.compareTo(rightValue);
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  Widget _buildSingleAddonSearchAndFilterBar(
    BuildContext context,
    List visibleItems,
    int totalItemsCount,
  ) {
    final Color activeColor = Theme.of(context).colorScheme.primary;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Search', 'Поиск'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
              _restoreSearchFocus();
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _restoreSearchFocus();
                      },
                      icon: const Icon(Icons.close),
                    ),
              labelText: tr('Search by key', 'Поиск по ключам'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr('Sorting', 'Сортировка'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: tr('Sort by key', 'Сортировать по ключу'),
                onPressed: () => setState(() => _sortMode = 'key'),
                icon: Icon(
                  Icons.sort_by_alpha,
                  color: _sortMode == 'key' ? activeColor : null,
                ),
              ),
              IconButton(
                tooltip: tr('Sort by value', 'Сортировать по значению'),
                onPressed: () => setState(() => _sortMode = 'value'),
                icon: Icon(
                  Icons.data_object,
                  color: _sortMode == 'value' ? activeColor : null,
                ),
              ),
              IconButton(
                tooltip: tr(
                  _sortAscending ? 'Ascending' : 'Descending',
                  _sortAscending ? 'По возрастанию' : 'По убыванию',
                ),
                onPressed: () =>
                    setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
              IconButton(
                tooltip: tr('Reset filters', 'Сбросить фильтры'),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _sortMode = 'key';
                    _sortAscending = true;
                  });
                },
                icon: const Icon(Icons.restart_alt),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr(
                    'Filtered: ${visibleItems.length} / $totalItemsCount',
                    'Отфильтровано: ${visibleItems.length} / $totalItemsCount',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSingleAddonActions(
    BuildContext context,
    List<String> allIds,
  ) {
    final List<Widget> actions = <Widget>[];

    if (singleAddon == 'Firewall') {
      actions.add(
        Text(
          tr('RULES: ', 'ПРАВИЛА: '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 23,
          ),
        ),
      );
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 1),
          child: IconButton(
            onPressed: () {
              if (hardeninType == 'Windows XP') {
                Navigator.of(context).pushNamed('/AddNewFirewallRuleXP');
              } else {
                Navigator.of(context).pushNamed('/AddNewFirewallRule');
              }
            },
            icon: const Icon(Icons.queue, size: 30),
          ),
        ),
      );
    }

    actions.add(
      Text(
        tr('ALL: ', 'ВСЕ: '),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: 23,
        ),
      ),
    );

    actions.add(
      Padding(
        padding: const EdgeInsets.only(right: 5, left: 5),
        child: IconButton(
          onPressed: () {
            Provider.of<DataChoosedProvider>(context, listen: false)
                .setAllCheckingIds(allIds);
          },
          icon: const Icon(Icons.playlist_add_check, size: 30),
        ),
      ),
    );

    actions.add(
      Padding(
        padding: const EdgeInsets.only(right: 32),
        child: IconButton(
          onPressed: () {
            Provider.of<DataChoosedProvider>(context, listen: false)
                .setAllUnchecking();
          },
          icon: const Icon(Icons.playlist_remove, size: 30),
        ),
      ),
    );

    return actions;
  }

  Future<void> _saveSingleAddonSelection(
    BuildContext context,
    List itemsToList,
    List<String> isChoosingFeatureList,
    List firewallRulesList,
  ) async {
    if (isChoosingFeatureList.isEmpty &&
        firewallRulesList.isEmpty &&
        mode == 'Addon') {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            tr('Warning! No items for saving!', 'Внимание! Нет элементов для сохранения!'),
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
      return;
    }

    _keyControllerOffset = 0;

    if (mode == 'Addon') {
      await generateBatFileSingleAddon(
        batParameters,
        itemsToList,
        isChoosingFeatureList,
      );
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            tr('Your file is saved.', 'Файл успешно сохранен.'),
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
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamed(context, '/');
      return;
    }

    final String paramsTitle = 'ManualOptions_$singleAddon';
    final List<String> data_ =
        Provider.of<DataChoosedProvider>(context, listen: false).myData;
    batParameters[paramsTitle] = <Object>[itemsToList, data_];

    if (firewallRulesList.isNotEmpty) {
      batParameters['ManualOptions_FirewallRulesList'] = firewallRulesList;
    } else {
      batParameters['ManualOptions_FirewallRulesList'] = [];
    }

    if (batParameters['makeTwiceGoBack'] != null && singleAddon == 'IE') {
      batParameters['makeTwiceGoBack'] = null;
      Navigator.of(context, rootNavigator: true).pop();
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget _buildSingleAddonItemsPane(
    BuildContext context,
    List itemsToList,
    List<String> isChoosingFeatureList,
    ScrollController controller,
    double screenWidth,
    int totalItemsCount,
  ) {
    return SizedBox(
      width: screenWidth * 0.65,
      child: SingleChildScrollView(
        controller: controller,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSingleAddonSearchAndFilterBar(
                context,
                itemsToList,
                totalItemsCount,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  child: ListView.builder(
                    itemCount: itemsToList.length,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final currentItem = itemsToList[index];
                      return Card(
                        child: CheckboxListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentItem[1]}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${tr('Value', 'Значение')}: ${currentItem[2]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          value: isChoosingFeatureList
                              .contains(currentItem[0].toString()),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 1),
                          onChanged: (bool? value) {
                            _keyControllerOffset = controller.offset;
                            Provider.of<DataChoosedProvider>(
                              context,
                              listen: false,
                            ).fetchDataById(
                              currentItem[0].toString(),
                              value ?? false,
                            );
                            currentListValuesSingleAddon = currentItem;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleAddonDetailsPane(double screenWidth) {
    return buildSelectedRecordDetailsPane(screenWidth);
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      List firewallRulesList = batParameters['FirewallRules'];
      ScrollController controller =
          ScrollController(initialScrollOffset: _keyControllerOffset);

      final screen = MediaQuery.of(context).size;
      var screenWidth = screen.width;
      return FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(child: Center(child: Text(tr('ERROR', 'ОШИБКА')))),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          var itemsToList = snapshot.data!;

          if (currentListValuesSingleAddon.isEmpty) {
            currentListValuesSingleAddon = itemsToList[0];
          }

          String paramsTitle = 'ManualOptions_$singleAddon';
          List optionsSingleAddonGlobal = batParameters[paramsTitle] ?? [];
          final List<String> allIds = itemsToList
              .map<String>((dynamic item) => item[0].toString())
              .toList();
          _singleAddonDataProvider ??=
              DataChoosedProvider('SingleAddon', optionsSingleAddonGlobal);

          return ChangeNotifierProvider<DataChoosedProvider>.value(
            value: _singleAddonDataProvider!,
            child: Consumer<DataChoosedProvider>(
              builder: (context, dataProvider, _) {
                List<String> isChoosingFeatureList = dataProvider.myData;
                final List visibleItems =
                    _applySingleAddonViewState(itemsToList);

                if (visibleItems.isNotEmpty &&
                    !visibleItems.contains(currentListValuesSingleAddon)) {
                  currentListValuesSingleAddon = visibleItems.first;
                }

                return Scaffold(
                  appBar: AppBar(
                    actions: _buildSingleAddonActions(
                      context,
                      allIds,
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: FloatingActionButton(
                    focusElevation: 5,
                    isExtended: true,
                    elevation: 40,
                    tooltip: mode == 'Addon'
                        ? tr('Make .bat', 'Создать .bat')
                        : tr('Save addon & go back', 'Сохранить аддон и вернуться'),
                    hoverElevation: 50,
                    backgroundColor: Colors.blueGrey,
                    child: mode == 'Addon'
                        ? const Icon(Icons.save)
                        : const Icon(Icons.thumb_up_alt),
                    onPressed: () async => _saveSingleAddonSelection(
                      context,
                      itemsToList,
                      isChoosingFeatureList.cast<String>(),
                      firewallRulesList,
                    ),
                  ),
                  body: Row(
                    children: [
                      _buildSingleAddonItemsPane(
                        context,
                        visibleItems,
                        isChoosingFeatureList.cast<String>(),
                        controller,
                        screenWidth,
                        itemsToList.length,
                      ),
                      const VerticalDivider(width: 1.0),
                      _buildSingleAddonDetailsPane(screenWidth),
                    ],
                  ),
                );
              },
            ),
          );
        }
        },
      );
    });
  }
}

class ErrorsPage extends StatefulWidget {
  const ErrorsPage({super.key});

  @override
  State<ErrorsPage> createState() => _ErrorsPageState();
}

class _ErrorsPageState extends State<ErrorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(tr('ERROR', 'ОШИБКА')),
        ),
      ),
    );
  }
}

class AddingNewRuleFirewall extends StatefulWidget {
  const AddingNewRuleFirewall({super.key});
  static const routeName = '/AddNewFirewallRule';

  @override
  State<AddingNewRuleFirewall> createState() => _AddingNewRuleFirewallState();
}

class _AddingNewRuleFirewallState extends State<AddingNewRuleFirewall> {
  final TextEditingController _textIPControllerLocal = TextEditingController();
  final TextEditingController _textIPControllerRemote = TextEditingController();
  final TextEditingController _textPortControllerLocal = TextEditingController();
  final TextEditingController _textPortControllerRemote =
      TextEditingController();
  final TextEditingController _textControllerPathToProgram =
      TextEditingController();

  List firewallRulesList = batParameters['FirewallRules'];
  String hardeninType = batParameters['Hardenin'];

  List<DropdownMenuItem<String>> get modeListChoiceItems {
    return const [
      DropdownMenuItem(value: 'ip', child: Text('IP-address')),
      DropdownMenuItem(value: 'port', child: Text('Port')),
      DropdownMenuItem(value: 'program', child: Text('Program')),
    ];
  }

  var selectedValueIpPortOrProgram = 'ip';

  List<DropdownMenuItem<String>> get modeListChoiceItemsDirection {
    return [
      const DropdownMenuItem(value: 'in', child: Text('IN')),
      const DropdownMenuItem(value: 'out', child: Text('OUT')),
    ];
  }

  var selectedValueDirection = 'in';

  List<DropdownMenuItem<String>> get modeListChoiceProfileRule {
    return const [
      DropdownMenuItem(value: 'domain', child: Text('Domain')),
      DropdownMenuItem(value: 'private', child: Text('Private')),
      DropdownMenuItem(value: 'public', child: Text('Public')),
      DropdownMenuItem(value: 'any', child: Text('Any')),
    ];
  }

  var selectedValueProfile = 'domain';

  List<DropdownMenuItem<String>> get modeListChoiceAction {
    return const [
      DropdownMenuItem(value: 'block', child: Text('Block')),
      DropdownMenuItem(value: 'allow', child: Text('Allow')),
    ];
  }

  var selectedValueAction = 'block';

  List<DropdownMenuItem<String>> get modeListChoiceItemsProto {
    return [
      const DropdownMenuItem(value: 'tcp', child: Text('TCP')),
      const DropdownMenuItem(value: 'udp', child: Text('UDP')),
    ];
  }

  String? selectedValueProto;

  List<DropdownMenuItem<String>> get modeListChoiceItemsTypeIP {
    return const [
      DropdownMenuItem(value: 'localip', child: Text('Local IP')),
      DropdownMenuItem(value: 'remoteip', child: Text('Remote IP')),
    ];
  }

  var selectedValueLocalOrRemoteIP = 'localip';

  Future<void> _showFirewallMessage(BuildContext context, String message) async {
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

  Future<void> _pickProgramPath() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    final String choosedFileToFirewallTmp =
        result != null ? result.files.single.path! : '';
    setState(() {
      _textControllerPathToProgram.text = choosedFileToFirewallTmp;
    });
  }

  bool _isEmptyBaseRule() {
    return ['ip', 'port'].contains(selectedValueIpPortOrProgram) &&
        selectedValueProto == null &&
        _textIPControllerRemote.text.isEmpty &&
        _textIPControllerLocal.text.isEmpty &&
        _textPortControllerRemote.text.isEmpty &&
        _textPortControllerLocal.text.isEmpty;
  }

  Future<bool> _validateFirewallRule(BuildContext context) async {
    bool hasProblems = false;

    if (selectedValueProto == null &&
        (_textPortControllerLocal.text.isNotEmpty ||
            _textPortControllerRemote.text.isNotEmpty)) {
      hasProblems = true;
      if (!context.mounted) {
        return false;
      }
      await _showFirewallMessage(
        context,
        tr('Protocol validation check not passed!', 'Проверка протокола не пройдена!'),
      );
    }

    if (validatePorts(
          _textPortControllerRemote.text,
          selectedValueLocalOrRemoteIP,
        ) !=
        null) {
      hasProblems = true;
      if (!context.mounted) {
        return false;
      }
      await _showFirewallMessage(
        context,
        tr('Remote port failed validation check!', 'Проверка удаленного порта не пройдена!'),
      );
    }

    if (validatePorts(
          _textPortControllerLocal.text,
          selectedValueLocalOrRemoteIP,
        ) !=
        null) {
      hasProblems = true;
      if (!context.mounted) {
        return false;
      }
      await _showFirewallMessage(
        context,
        tr('Local port failed validation check!', 'Проверка локального порта не пройдена!'),
      );
    }

    if (selectedValueIpPortOrProgram == 'ip' ||
        selectedValueIpPortOrProgram == 'port') {
      if (validateIPAddresses(_textIPControllerRemote.text, true, false) !=
          null) {
        hasProblems = true;
        if (!context.mounted) {
          return false;
        }
        await _showFirewallMessage(
          context,
          tr('Remote IP address failed validation check!', 'Проверка удаленного IP-адреса не пройдена!'),
        );
      }

      if (validateIPAddresses(_textIPControllerLocal.text, false, false) !=
          null) {
        hasProblems = true;
        if (!context.mounted) {
          return false;
        }
        await _showFirewallMessage(
          context,
          tr('Local IP address failed validation check!', 'Проверка локального IP-адреса не пройдена!'),
        );
      }
    }

    if (selectedValueIpPortOrProgram == 'program' &&
        validatePathToProgram(_textControllerPathToProgram.text) != null) {
      hasProblems = true;
      if (!context.mounted) {
        return false;
      }
      await _showFirewallMessage(
        context,
        tr('Program path failed validation check!', 'Проверка пути к программе не пройдена!'),
      );
    }

    return !hasProblems;
  }

  String _appendRuleNamePart(String ruleName, String value) {
    if (value.isEmpty) {
      return ruleName;
    }
    final String normalized = value.replaceAll(',', '_').replaceAll('-', '_');
    return '${ruleName}_$normalized';
  }

  String _buildFirewallRuleName() {
    String ruleName = '${selectedValueAction}_$selectedValueDirection';
    ruleName = _appendRuleNamePart(ruleName, _textIPControllerLocal.text);
    ruleName = _appendRuleNamePart(ruleName, _textIPControllerRemote.text);
    ruleName = _appendRuleNamePart(ruleName, _textPortControllerLocal.text);
    ruleName = _appendRuleNamePart(ruleName, _textPortControllerRemote.text);

    if (_textControllerPathToProgram.text.isNotEmpty &&
        selectedValueIpPortOrProgram == 'program') {
      String programPath = _textControllerPathToProgram.text;
      programPath = programPath
          .replaceAll(',', '_')
          .replaceAll(' ', '_')
          .replaceAll('-', '_')
          .replaceAll('\\', '_')
          .replaceAll(':', '_');
      ruleName += '_$programPath';
    }

    return '${ruleName}_$selectedValueProfile';
  }

  String _buildFirewallRuleCommand(String ruleName) {
    String command =
        'netsh advfirewall firewall add rule name="$ruleName" '
        'dir=$selectedValueDirection action=$selectedValueAction '
        'profile=$selectedValueProfile';

    if (_textIPControllerLocal.text.isNotEmpty) {
      final String ipAddress = _textIPControllerLocal.text.replaceAll(' ', '');
      command += ' localip="$ipAddress"';
    }
    if (_textIPControllerRemote.text.isNotEmpty) {
      final String ipAddress = _textIPControllerRemote.text.replaceAll(' ', '');
      command += ' remoteip="$ipAddress"';
    }
    if (_textPortControllerLocal.text.isNotEmpty) {
      command += ' localport="${_textPortControllerLocal.text}"';
    }
    if (_textPortControllerRemote.text.isNotEmpty) {
      command += ' remoteport="${_textPortControllerRemote.text}"';
    }
    if (selectedValueProto != null) {
      command += ' protocol="$selectedValueProto"';
    }
    if (_textControllerPathToProgram.text.isNotEmpty &&
        selectedValueIpPortOrProgram == 'program') {
      command += ' program="${_textControllerPathToProgram.text}" enable=yes';
    }

    return command;
  }

  Future<void> _addFirewallRule(BuildContext context) async {
    if (_isEmptyBaseRule()) {
      final String ruleName =
          '${selectedValueAction}_${selectedValueDirection}_$selectedValueProfile';
      final String command =
          'netsh advfirewall firewall add rule name="$ruleName" '
          'dir=$selectedValueDirection action=$selectedValueAction '
          'profile=$selectedValueProfile';
      firewallRulesList.add(<String>[ruleName, command]);
      if (!context.mounted) {
        return;
      }
      await _showFirewallMessage(
        context,
        tr('New rule is added.', 'Новое правило добавлено.'),
      );
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context, true);
      return;
    }

    final bool isValid = await _validateFirewallRule(context);
    if (!isValid || !context.mounted) {
      return;
    }

    final String ruleName = _buildFirewallRuleName();
    final String command = _buildFirewallRuleCommand(ruleName);
    firewallRulesList.add(<String>[ruleName, command]);

    await _showFirewallMessage(
      context,
      tr('New rule is added.', 'Новое правило добавлено.'),
    );
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context, true);
  }

  Widget _buildFirewallSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildFirewallInfoBlock(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(subtitle, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFirewallDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    double width = 300,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          filled: true,
        ),
        validator: (value) => value == null ? tr('Choose value', 'Выберите значение') : null,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        initialValue: value,
        onChanged: onChanged,
        items: items,
      ),
    );
  }

  Widget _buildProgramPickerSection(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tr('Selected program:', 'Выбранная программа:'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.6,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textControllerPathToProgram,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    onEditingComplete: () => setState(() {}),
                    decoration: InputDecoration(
                      errorText:
                          validatePathToProgram(_textControllerPathToProgram.text),
                      border: InputBorder.none,
                      hintText: tr('path/to/application', 'путь/к/приложению'),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickProgramPath,
                  icon: const Icon(Icons.folder, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpInputs(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.5,
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textIPControllerLocal,
                enabled: !(selectedValueIpPortOrProgram == 'ip' &&
                    selectedValueLocalOrRemoteIP == 'remoteip'),
                textAlign: TextAlign.center,
                onEditingComplete: () => setState(() {}),
                decoration: InputDecoration(
                  errorText: validateIPAddresses(
                    _textIPControllerLocal.text,
                    false,
                    selectedValueIpPortOrProgram == 'ip' &&
                        selectedValueLocalOrRemoteIP == 'remoteip',
                  ),
                  border: InputBorder.none,
                  hintText: selectedValueIpPortOrProgram == 'ip' &&
                          selectedValueLocalOrRemoteIP == 'remoteip'
                      ? ''
                      : tr('LOCAL IP', 'ЛОКАЛЬНЫЙ IP'),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const VerticalDivider(width: 1.0),
            Expanded(
              child: TextField(
                controller: _textIPControllerRemote,
                enabled: !(selectedValueIpPortOrProgram == 'ip' &&
                    selectedValueLocalOrRemoteIP == 'localip'),
                textAlign: TextAlign.center,
                onEditingComplete: () => setState(() {}),
                decoration: InputDecoration(
                  errorText: validateIPAddresses(
                    _textIPControllerRemote.text,
                    true,
                    selectedValueIpPortOrProgram == 'ip' &&
                        selectedValueLocalOrRemoteIP == 'localip',
                  ),
                  border: InputBorder.none,
                  hintText: selectedValueIpPortOrProgram == 'ip' &&
                          selectedValueLocalOrRemoteIP == 'localip'
                      ? ''
                      : tr('REMOTE IP', 'УДАЛЕННЫЙ IP'),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortInputs(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.5,
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textPortControllerLocal,
                onEditingComplete: () => setState(() {}),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: validatePorts(
                    _textPortControllerLocal.text,
                    selectedValueLocalOrRemoteIP,
                  ),
                  border: InputBorder.none,
                  hintText: tr('LOCAL PORT', 'ЛОКАЛЬНЫЙ ПОРТ'),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const VerticalDivider(width: 1.0),
            Expanded(
              child: TextField(
                controller: _textPortControllerRemote,
                onEditingComplete: () => setState(() {}),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: validatePorts(
                    _textPortControllerRemote.text,
                    selectedValueLocalOrRemoteIP,
                  ),
                  border: InputBorder.none,
                  hintText: tr('REMOTE PORT', 'УДАЛЕННЫЙ ПОРТ'),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirewallDirectionSection() {
    return Column(
      children: [
        _buildFirewallSectionTitle(
          tr('Specify the action direction:', 'Укажите направление действия:'),
        ),
        _buildFirewallDropdown(
          value: selectedValueDirection,
          items: modeListChoiceItemsDirection,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueDirection = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFirewallItemSection(double screenWidth) {
    return Column(
      children: [
        _buildFirewallSectionTitle(
          tr('Select item:', 'Выберите тип элемента:'),
        ),
        _buildFirewallDropdown(
          value: selectedValueIpPortOrProgram,
          items: modeListChoiceItems,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueIpPortOrProgram = newValue!;
            });
          },
        ),
        if (selectedValueIpPortOrProgram == 'ip')
          _buildFirewallSectionTitle(tr('Specify type:', 'Укажите тип:')),
        if (selectedValueIpPortOrProgram == 'ip')
          _buildFirewallDropdown(
            value: selectedValueLocalOrRemoteIP,
            items: modeListChoiceItemsTypeIP,
            onChanged: (String? newValue) {
              setState(() {
                selectedValueLocalOrRemoteIP = newValue!;
                _textIPControllerLocal.clear();
                _textIPControllerRemote.clear();
              });
            },
          ),
        if (selectedValueIpPortOrProgram == 'program')
          _buildProgramPickerSection(screenWidth),
      ],
    );
  }

  Widget _buildFirewallNetworkSection(double screenWidth) {
    return Column(
      children: [
        _buildFirewallInfoBlock(
          tr('Enter IP address(es)', 'Введите IP-адрес(а)'),
          tr(
            '(single or range, or with mask), separated by commas',
            '(одиночные, диапазон или с маской), через запятую',
          ),
        ),
        _buildIpInputs(screenWidth),
        _buildFirewallInfoBlock(
          tr('Enter port number(s)', 'Введите номер(а) портов'),
          tr(
            '(single or a range (e.g., 80,443,1000-2000)',
            '(одиночный или диапазон, например 80,443,1000-2000)',
          ),
        ),
        _buildPortInputs(screenWidth),
      ],
    );
  }

  Widget _buildFirewallPolicySection() {
    return Column(
      children: [
        _buildFirewallSectionTitle(tr('Specify the protocol:', 'Укажите протокол:')),
        _buildFirewallDropdown(
          value: selectedValueProto,
          items: modeListChoiceItemsProto,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueProto = newValue!;
            });
          },
        ),
        _buildFirewallSectionTitle(tr('Specify the action:', 'Укажите действие:')),
        _buildFirewallDropdown(
          value: selectedValueAction,
          items: modeListChoiceAction,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueAction = newValue!;
            });
          },
        ),
        _buildFirewallSectionTitle(
          tr('For which profile will the rule be used?', 'Для какого профиля будет использоваться правило?'),
        ),
        _buildFirewallDropdown(
          value: selectedValueProfile,
          items: modeListChoiceProfileRule,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueProfile = newValue!;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    var screenWidth = screen.width;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${tr('Adding new Firewall Rule', 'Добавление нового правила брандмауэра')} (${firewallRulesList.length}):',
                  style: TextStyle(
                    fontSize: 21,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildFirewallDirectionSection(),
              _buildFirewallItemSection(screenWidth),
              _buildFirewallNetworkSection(screenWidth),
              _buildFirewallPolicySection(),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () async => _addFirewallRule(context),
                  child: Text(
                    tr('ADD NEW RULE', 'ДОБАВИТЬ НОВОЕ ПРАВИЛО'),
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
  }
}

class AddingNewRuleFirewallXP extends StatefulWidget {
  const AddingNewRuleFirewallXP({super.key});
  static const routeName = '/AddNewFirewallRuleXP';

  @override
  State<AddingNewRuleFirewallXP> createState() =>
      _AddingNewRuleFirewallXPState();
}

class _AddingNewRuleFirewallXPState extends State<AddingNewRuleFirewallXP> {
  List firewallRulesList = batParameters['FirewallRules'];

  List<DropdownMenuItem<String>> get modeListChoiceItemsRuleTypes {
    return const [
      DropdownMenuItem(value: 'port', child: Text('Port')),
      DropdownMenuItem(value: 'program', child: Text('Program')),
    ];
  }

  var selectedValuePortOrProgram = 'port';

  List<DropdownMenuItem<String>> get modeListChoiceItemsProto {
    return [
      const DropdownMenuItem(value: 'tcp', child: Text('TCP')),
      const DropdownMenuItem(value: 'udp', child: Text('UDP')),
      const DropdownMenuItem(value: 'all', child: Text('ALL')),
    ];
  }

  var selectedValueProto = 'tcp';

  List<DropdownMenuItem<String>> get modeListChoiceMode {
    return const [
      DropdownMenuItem(value: 'disable', child: Text('Disable')),
      DropdownMenuItem(value: 'enable', child: Text('Enable')),
    ];
  }

  var selectedValueMode = 'disable';

  List<DropdownMenuItem<String>> get modeListChoiceModeIpScope {
    return const [
      DropdownMenuItem(value: 'all', child: Text('All')),
      DropdownMenuItem(value: 'subnet', child: Text('Subnet')),
      DropdownMenuItem(value: 'custom', child: Text('Custom')),
    ];
  }

  var selectedValueIpScope = 'all';

  List<DropdownMenuItem<String>> get modeListChoiceProfile {
    return const [
      DropdownMenuItem(value: 'all', child: Text('All')),
      DropdownMenuItem(value: 'domain', child: Text('Domain')),
      DropdownMenuItem(value: 'standard', child: Text('Standard')),
    ];
  }

  var selectedValueProfile = 'all';

  final TextEditingController _textPortController = TextEditingController();
  final TextEditingController _textIPControllerCustom = TextEditingController();
  final TextEditingController _textControllerPathToProgram =
      TextEditingController();

  Future<void> _showFirewallXpMessage(
    BuildContext context,
    String message,
  ) async {
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

  Future<void> _pickProgramPath() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    final String choosedFileToFirewallTmp =
        result != null ? result.files.single.path! : '';
    setState(() {
      _textControllerPathToProgram.text = choosedFileToFirewallTmp;
    });
  }

  bool _hasValidXpFirewallInput() {
    bool hasProblems = true;

    if (selectedValuePortOrProgram == 'port' &&
        _textPortController.text.isNotEmpty &&
        validatePortsXP(_textPortController.text) == null) {
      hasProblems = false;
    }
    if (selectedValuePortOrProgram == 'program' &&
        _textControllerPathToProgram.text.isNotEmpty &&
        validatePathToProgram(_textControllerPathToProgram.text) == null) {
      hasProblems = false;
    }
    if (selectedValueIpScope == 'custom' &&
        validateIPAddressesXP(_textIPControllerCustom.text) != null) {
      hasProblems = true;
    }

    return !hasProblems;
  }

  String _buildXpFirewallRuleName() {
    String ruleName = selectedValueMode;
    if (_textPortController.text.isNotEmpty) {
      ruleName += '_${_textPortController.text}_$selectedValueProto';
    }
    if (_textControllerPathToProgram.text.isNotEmpty) {
      String programPath = _textControllerPathToProgram.text;
      programPath = programPath
          .replaceAll(',', '_')
          .replaceAll(' ', '_')
          .replaceAll('-', '_')
          .replaceAll('\\', '_')
          .replaceAll(':', '_');
      ruleName += '_$programPath';
    }
    return '${ruleName}_$selectedValueProfile';
  }

  String _appendXpScope(String command) {
    if (selectedValueIpScope == 'custom') {
      final String ipscopeaddress =
          _textIPControllerCustom.text.replaceAll(' ', '');
      return '$command scope=custom addresses=$ipscopeaddress';
    }
    if (selectedValueIpScope == 'subnet') {
      return '$command scope=subnet';
    }
    return command;
  }

  String _buildXpFirewallCommand(String ruleName) {
    if (selectedValuePortOrProgram == 'program') {
      String command =
          'netsh firewall add allowedprogram '
          'program="${_textControllerPathToProgram.text}" name="$ruleName"';
      command += ' mode=${selectedValueMode.toUpperCase()}';
      command += ' profile=${selectedValueProfile.toUpperCase()}';
      return _appendXpScope(command);
    }

    String command =
        'netsh firewall add portopening '
        'protocol=$selectedValueProto port=${_textPortController.text} '
        'name="$ruleName"';
    command += ' mode=${selectedValueMode.toUpperCase()}';
    command += ' profile=${selectedValueProfile.toUpperCase()}';
    return _appendXpScope(command);
  }

  Future<void> _addXpFirewallRule(BuildContext context) async {
    setState(() {});

    if (!_hasValidXpFirewallInput()) {
      await _showFirewallXpMessage(
        context,
        tr('Error validation! Check form.', 'Ошибка проверки! Проверьте форму.'),
      );
      return;
    }

    final String ruleName = _buildXpFirewallRuleName();
    final String command = _buildXpFirewallCommand(ruleName);
    firewallRulesList.add(<String>[ruleName, command]);

    if (!context.mounted) {
      return;
    }
    await _showFirewallXpMessage(
      context,
      tr('New rule is added.', 'Новое правило добавлено.'),
    );
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context, true);
  }

  Widget _buildFirewallXpSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildFirewallXpInfoBlock(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(subtitle, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFirewallXpDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    double width = 300,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          filled: true,
        ),
        validator: (value) => value == null ? tr('Choose value', 'Выберите значение') : null,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        initialValue: value,
        onChanged: onChanged,
        items: items,
      ),
    );
  }

  Widget _buildFirewallXpProgramPickerSection(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tr('Selected program:', 'Выбранная программа:'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.6,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textControllerPathToProgram,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    onEditingComplete: () => setState(() {}),
                    decoration: InputDecoration(
                      errorText:
                          validatePathToProgram(_textControllerPathToProgram.text),
                      border: InputBorder.none,
                      hintText: tr('path/to/application', 'путь/к/приложению'),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickProgramPath,
                  icon: const Icon(Icons.folder, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirewallXpModeSection() {
    return Column(
      children: [
        _buildFirewallXpSectionTitle(
          tr('Specify the action mode:', 'Укажите режим действия:'),
        ),
        _buildFirewallXpDropdown(
          value: selectedValueMode,
          items: modeListChoiceMode,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueMode = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFirewallXpTargetSection(double screenWidth) {
    return Column(
      children: [
        _buildFirewallXpSectionTitle(
          tr('What will be added - port or program?', 'Что будет добавлено — порт или программа?'),
        ),
        _buildFirewallXpDropdown(
          value: selectedValuePortOrProgram,
          items: modeListChoiceItemsRuleTypes,
          onChanged: (String? newValue) {
            setState(() {
              selectedValuePortOrProgram = newValue!;
            });
          },
        ),
        if (selectedValuePortOrProgram == 'program')
          _buildFirewallXpProgramPickerSection(screenWidth),
        if (selectedValuePortOrProgram == 'port')
          _buildFirewallXpInfoBlock(
            tr('Enter a single port number', 'Введите один номер порта'),
            tr('(e.g., 80)', '(например, 80)'),
          ),
        if (selectedValuePortOrProgram == 'port')
          SizedBox(
            width: screenWidth * 0.5,
            child: TextField(
              controller: _textPortController,
              onEditingComplete: () => setState(() {}),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                errorText: validatePortsXP(_textPortController.text),
                border: InputBorder.none,
                hintText: tr('PORT', 'ПОРТ'),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        if (selectedValuePortOrProgram == 'port')
          _buildFirewallXpSectionTitle(tr('Specify the protocol:', 'Укажите протокол:')),
        if (selectedValuePortOrProgram == 'port')
          _buildFirewallXpDropdown(
            value: selectedValueProto,
            items: modeListChoiceItemsProto,
            onChanged: (String? newValue) {
              setState(() {
                selectedValueProto = newValue!;
              });
            },
          ),
      ],
    );
  }

  Widget _buildFirewallXpScopeSection(double screenWidth) {
    return Column(
      children: [
        _buildFirewallXpSectionTitle(tr('Specify the scope:', 'Укажите область действия:')),
        _buildFirewallXpDropdown(
          value: selectedValueIpScope,
          items: modeListChoiceModeIpScope,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueIpScope = newValue!;
            });
          },
        ),
        if (selectedValueIpScope == 'custom')
          _buildFirewallXpInfoBlock(
            tr('Enter IP addresses:', 'Введите IP-адреса:'),
            tr(
              "(comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet')",
              "(через запятую, например '192.168.0.1, 192.168.1.0/24, localsubnet')",
            ),
          ),
        if (selectedValueIpScope == 'custom')
          SizedBox(
            width: screenWidth * 0.5,
            child: TextField(
              controller: _textIPControllerCustom,
              onEditingComplete: () => setState(() {}),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                errorText: validateIPAddressesXP(_textIPControllerCustom.text),
                border: InputBorder.none,
                hintText: tr('IP SCOPE', 'ОБЛАСТЬ IP'),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFirewallXpProfileSection() {
    return Column(
      children: [
        _buildFirewallXpSectionTitle(
          tr('For which profile will the rule be used?', 'Для какого профиля будет использоваться правило?'),
        ),
        _buildFirewallXpDropdown(
          value: selectedValueProfile,
          items: modeListChoiceProfile,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueProfile = newValue!;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    var screenWidth = screen.width;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${tr('Adding new XP Firewall Rule', 'Добавление нового XP-правила брандмауэра')} (${firewallRulesList.length}):',
                  style: TextStyle(
                    fontSize: 21,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildFirewallXpModeSection(),
              _buildFirewallXpTargetSection(screenWidth),
              _buildFirewallXpScopeSection(screenWidth),
              _buildFirewallXpProfileSection(),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () async => _addXpFirewallRule(context),
                  child: Text(
                    tr('ADD NEW RULE', 'ДОБАВИТЬ НОВОЕ ПРАВИЛО'),
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
  }
}

class OfficeSettingPage extends StatefulWidget {
  const OfficeSettingPage({super.key});
  static const routeName = '/OfficeSettingsPageAuto';

  @override
  State<OfficeSettingPage> createState() => _OfficeSettingPageState();
}

class _OfficeSettingPageState extends State<OfficeSettingPage> {
  List<DropdownMenuItem<String>> get modeListChoiceItemsVersion {
    return [
      const DropdownMenuItem(value: '2003', child: Text('2003')),
      const DropdownMenuItem(value: '2007', child: Text('2007')),
      const DropdownMenuItem(value: '2010', child: Text('2010')),
      const DropdownMenuItem(value: '2013', child: Text('2013')),
      const DropdownMenuItem(value: '2016', child: Text('2016')),
      const DropdownMenuItem(value: '365', child: Text('365')),
    ];
  }

  String selectedValueVersion = '2003';
  String? selectedValueVersionOS;
  bool makeRestoreOffice = false;
  String mode = batParameters['Mode'];
  List<String> addonsList = [
    tr(
      'Do you need to create the restore point before applying script?',
      'Нужно ли создать точку восстановления перед применением скрипта?',
    ),
  ];

  List<DropdownMenuItem<String>> _buildOfficeOsChoiceMenu() {
    if (selectedValueVersion == '2003') {
      return [
        DropdownMenuItem(
          value: 'xp',
          child: Text(tr('Windows XP', 'Windows XP')),
        ),
        DropdownMenuItem(
          value: 'vista',
          child: Text(tr('Windows Vista', 'Windows Vista')),
        ),
      ];
    }
    if (selectedValueVersion == '2007' || selectedValueVersion == '2010') {
      return [
        DropdownMenuItem(value: 'xp', child: Text(tr('Windows XP', 'Windows XP'))),
        DropdownMenuItem(
          value: 'vista',
          child: Text(tr('Windows Vista', 'Windows Vista')),
        ),
        DropdownMenuItem(
          value: 'seven',
          child: Text(tr('Windows 7', 'Windows 7')),
        ),
        DropdownMenuItem(
          value: 'eightzero',
          child: Text(tr('Windows 8', 'Windows 8')),
        ),
        DropdownMenuItem(
          value: 'eightone',
          child: Text(tr('Windows 8.1', 'Windows 8.1')),
        ),
        DropdownMenuItem(
          value: 'ten',
          child: Text(tr('Windows 10', 'Windows 10')),
        ),
      ];
    }
    if (selectedValueVersion == '2013' || selectedValueVersion == '2016') {
      return [
        DropdownMenuItem(
          value: 'seven',
          child: Text(tr('Windows 7', 'Windows 7')),
        ),
        DropdownMenuItem(
          value: 'eightzero',
          child: Text(tr('Windows 8', 'Windows 8')),
        ),
        DropdownMenuItem(
          value: 'eightone',
          child: Text(tr('Windows 8.1', 'Windows 8.1')),
        ),
        DropdownMenuItem(
          value: 'ten',
          child: Text(tr('Windows 10', 'Windows 10')),
        ),
        DropdownMenuItem(
          value: 'eleven',
          child: Text(tr('Windows 11', 'Windows 11')),
        ),
      ];
    }
    return [
      DropdownMenuItem(value: 'ten', child: Text(tr('Windows 10', 'Windows 10'))),
      DropdownMenuItem(
        value: 'eleven',
        child: Text(tr('Windows 11', 'Windows 11')),
      ),
    ];
  }

  String _defaultOfficeOsForVersion() {
    if (selectedValueVersion == '2003' ||
        selectedValueVersion == '2007' ||
        selectedValueVersion == '2010') {
      return 'xp';
    }
    if (selectedValueVersion == '2013' || selectedValueVersion == '2016') {
      return 'seven';
    }
    return 'ten';
  }

  Widget _buildOfficeSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildOfficeDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          filled: true,
        ),
        validator: (value) => value == null ? '?' : null,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        initialValue: value,
        onChanged: onChanged,
        items: items,
      ),
    );
  }

  Widget _buildOfficeVersionSection() {
    return Column(
      children: [
        _buildOfficeSectionTitle(
          tr(
            'Choose the version of MS Office you want to harden:',
            'Выберите версию MS Office для харденинга:',
          ),
        ),
        _buildOfficeDropdown(
          value: selectedValueVersion,
          items: modeListChoiceItemsVersion,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueVersion = newValue!;
              batParameters['SelectedValueVersionOffice'] = selectedValueVersion;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOfficeOsSection(List<DropdownMenuItem<String>> osChoiceMenu) {
    return Column(
      children: [
        _buildOfficeSectionTitle(
          tr('Choose the operating system:', 'Выберите операционную систему:'),
        ),
        _buildOfficeDropdown(
          value: selectedValueVersionOS,
          items: osChoiceMenu,
          onChanged: (String? newValue) {
            setState(() {
              selectedValueVersionOS = newValue;
              batParameters['SelectedValueVersionOSOffice'] =
                  selectedValueVersionOS;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOfficeRestoreSection(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: screenWidth * 0.45,
        child: ListView(
          shrinkWrap: true,
          children: addonsList
              .map(
                (option) => CheckboxListTile(
                  title: Text(option),
                  value: makeRestoreOffice,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 1),
                  onChanged: (bool? value) {
                    setState(() {
                      makeRestoreOffice = value!;
                      batParameters['neededRestoreBackupMOffice'] =
                          makeRestoreOffice;
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showOfficeMessage(BuildContext context, String message) async {
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

  Future<void> _submitOfficeSettings(BuildContext context) async {
    if (batParameters['SelectedValueVersionOSOffice'] == null) {
      batParameters['SelectedValueVersionOSOffice'] = selectedValueVersionOS;
    }
    if (batParameters['SelectedValueVersionOffice'] == null) {
      batParameters['SelectedValueVersionOffice'] = selectedValueVersion;
    }
    batParameters['neededRestoreBackupMOffice'] = makeRestoreOffice;

    try {
      if (mode == 'Auto') {
        await generateBatFileOffice(batParameters);
        if (!context.mounted) {
          return;
        }
        await _showOfficeMessage(
          context,
          tr('Your file is saved.', 'Файл успешно сохранен.'),
        );
        if (!context.mounted) {
          return;
        }
        Navigator.pushNamed(context, '/');
        return;
      }

      Navigator.pushNamed(context, '/ManualPage');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await _showOfficeMessage(
        context,
        '${tr('Some Error', 'Ошибка')}: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    batParameters['neededRestoreBackupMOffice'] = makeRestoreOffice;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final screen = MediaQuery.of(context).size;
    var screenWidth = screen.width;

    final List<DropdownMenuItem<String>> osChoiceMenu =
        _buildOfficeOsChoiceMenu();
    final allowedOsValues = osChoiceMenu
        .map((item) => item.value)
        .whereType<String>()
        .toSet();
    if (selectedValueVersionOS == null ||
        !allowedOsValues.contains(selectedValueVersionOS)) {
      selectedValueVersionOS = _defaultOfficeOsForVersion();
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tr(
                    'MS Office hardening settings:',
                    'Настройки харденинга MS Office:',
                  ),
                  style: TextStyle(
                    fontSize: 21,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildOfficeVersionSection(),
              _buildOfficeOsSection(osChoiceMenu),
              _buildOfficeRestoreSection(screenWidth),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async => _submitOfficeSettings(context),
                    child: Text(
                      mode == 'Auto'
                          ? tr('Make .bat-file!', 'Создать .bat-файл!')
                          : tr('Next', 'Далее'),
                      style: TextStyle(
                        fontSize: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});
  static const routeName = '/ManualPage';

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  String hardeninType = batParameters['Hardenin'];
  List paramsMap = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  DataChoosedProvider? _manualDataProvider;
  late final Future<List> _dataFuture;
  String _searchQuery = '';
  String _sortMode = 'key';
  bool _sortAscending = true;
  String _levelFilter = 'all';

  @override
  void initState() {
    super.initState();
    _dataFuture = getData();
  }

  static const listAddonsIE = [
    'Windows XP',
    'Windows Vista',
    'Windows 7',
    'Windows 8',
    'Windows 8.1',
    'Windows 10',
  ];
  static const listAddonsDefender = [
    'Windows Vista',
    'Windows 7',
    'Windows 8',
    'Windows 8.1',
    'Windows 10',
    'Windows 11',
  ];
  static const listAddonsBitlocker = [
    'Windows 7',
    'Windows 8',
    'Windows 8.1',
    'Windows 10',
    'Windows 11',
  ];
  static const listAddonsEdge = ['Windows 10', 'Windows 11'];
  static const listAddonsNextGenerationSecurity = [
    'Windows 10',
    'Windows 11',
  ];

  Future<List> getData() async {
    if (paramsMap.isEmpty) {
      paramsMap = await returnHardeninParams(batParameters);
    }
    return paramsMap;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _manualDataProvider?.dispose();
    super.dispose();
  }

  String _normalizeRecordText(dynamic value) {
    return value?.toString().toLowerCase() ?? '';
  }

  String _normalizeLevel(dynamic value) {
    final String raw = value?.toString().trim().toLowerCase() ?? '';
    if (raw == '1' || raw == 'full') {
      return '1';
    }
    if (raw == '2' || raw == 'med' || raw == 'medium') {
      return '2';
    }
    if (raw == '3' || raw == 'min' || raw == 'minimum') {
      return '3';
    }
    if (raw.contains('full') || raw.contains('max')) {
      return '1';
    }
    if (raw.contains('mid') ||
        raw.contains('med') ||
        raw.contains('aver') ||
        raw.contains('middle')) {
      return '2';
    }
    if (raw.contains('min')) {
      return '3';
    }
    return raw;
  }

  String _resolveRecordLevel(List record) {
    final String level = record.length > 7 ? _normalizeLevel(record[7]) : '';
    if (level.isNotEmpty) {
      return level;
    }

    return record.length > 8 ? _normalizeLevel(record[8]) : '';
  }

  void _restoreSearchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  List _applyManualViewState(List sourceItems, List<String> selectedIds) {
    final List filtered = sourceItems.where((dynamic item) {
      final List record = item as List;
      final String recordId = record[0].toString();
      final String regKey = _normalizeRecordText(record[1]);
      final String regValue = _normalizeRecordText(record[2]);
      final String level = _resolveRecordLevel(record);

      final bool matchesSearch = _searchQuery.isEmpty ||
          regKey.contains(_searchQuery) ||
          regValue.contains(_searchQuery);

      final bool matchesLevel = switch (_levelFilter) {
        'all' => true,
        'selected' => selectedIds.contains(recordId),
        'minimum' => level == '3',
        'medium' => level == '2' || level == '3',
        'full' => level == '1' || level == '2' || level == '3',
        _ => true,
      };

      return matchesSearch && matchesLevel;
    }).toList(growable: false);

    filtered.sort((dynamic a, dynamic b) {
      final List left = a as List;
      final List right = b as List;
      final String leftValue = _sortMode == 'value'
          ? _normalizeRecordText(left[2])
          : _normalizeRecordText(left[1]);
      final String rightValue = _sortMode == 'value'
          ? _normalizeRecordText(right[2])
          : _normalizeRecordText(right[1]);
      final int result = leftValue.compareTo(rightValue);
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  Widget _buildManualSearchAndFilterBar(
    BuildContext context,
    List visibleItems,
    int totalItemsCount,
  ) {
    final bool isOffice = hardeninType == 'Microsoft Office';
    final Color activeColor = Theme.of(context).colorScheme.primary;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Search', 'Поиск'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
              _restoreSearchFocus();
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _restoreSearchFocus();
                      },
                      icon: const Icon(Icons.close),
                    ),
              labelText: tr('Search by key', 'Поиск по ключам'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr('Sorting', 'Сортировка'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: tr('Sort by key', 'Сортировать по ключу'),
                onPressed: () => setState(() => _sortMode = 'key'),
                icon: Icon(
                  Icons.sort_by_alpha,
                  color: _sortMode == 'key' ? activeColor : null,
                ),
              ),
              IconButton(
                tooltip: tr('Sort by value', 'Сортировать по значению'),
                onPressed: () => setState(() => _sortMode = 'value'),
                icon: Icon(
                  Icons.data_object,
                  color: _sortMode == 'value' ? activeColor : null,
                ),
              ),
              IconButton(
                tooltip: tr(
                  _sortAscending ? 'Ascending' : 'Descending',
                  _sortAscending ? 'По возрастанию' : 'По убыванию',
                ),
                onPressed: () =>
                    setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
              if (!isOffice)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tr('Filtering', 'Фильтрация'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              if (!isOffice)
                IconButton(
                  tooltip: tr('Minimum level', 'Минимальный уровень'),
                  onPressed: () => setState(() => _levelFilter = 'minimum'),
                  icon: Icon(
                    Icons.star_border,
                    color: _levelFilter == 'minimum' ? activeColor : null,
                  ),
                ),
              if (!isOffice)
                IconButton(
                  tooltip: tr('Medium level', 'Средний уровень'),
                  onPressed: () => setState(() => _levelFilter = 'medium'),
                  icon: Icon(
                    Icons.star_half,
                    color: _levelFilter == 'medium' ? activeColor : null,
                  ),
                ),
              if (!isOffice)
                IconButton(
                  tooltip: tr('Full level', 'Полный уровень'),
                  onPressed: () => setState(() => _levelFilter = 'full'),
                  icon: Icon(
                    Icons.star,
                    color: _levelFilter == 'full' ? activeColor : null,
                  ),
                ),
              IconButton(
                tooltip: tr('Selected only', 'Только выбранные'),
                onPressed: () => setState(() => _levelFilter = 'selected'),
                icon: Icon(
                  Icons.check_box,
                  color: _levelFilter == 'selected' ? activeColor : null,
                ),
              ),
              IconButton(
                tooltip: tr('Reset filters', 'Сбросить фильтры'),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _sortMode = 'key';
                    _sortAscending = true;
                    _levelFilter = 'all';
                  });
                },
                icon: const Icon(Icons.restart_alt),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr(
                    'Filtered: ${visibleItems.length} / $totalItemsCount',
                    'Отфильтровано: ${visibleItems.length} / $totalItemsCount',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openManualAddonPage(
    BuildContext context,
    DataChoosedProvider dataProvider,
    String addon,
  ) {
    batParameters['SingleAddon'] = addon;
    chooseManualPageItems = dataProvider.myData;

    if (addon == 'IE') {
      batParameters['Addons'] = <String>['IE'];
      batParameters['ManualOptions_IE'] = null;
      if (hardeninType == 'Windows 8.1' || hardeninType == 'Windows 10') {
        batParameters['VersionIE'] = 'ie11';
        Navigator.of(context)
            .pushNamed('/finishHardeninSingleAddonPage')
            .then((_) => setState(() {}));
        return;
      }

      Navigator.of(context)
          .pushNamed('/chooseIEPage')
          .then((_) => setState(() {}));
      return;
    }

    Navigator.of(context)
        .pushNamed('/finishHardeninSingleAddonPage')
        .then((_) => setState(() {}));
  }

  Widget _buildManualAddonButton({
    required BuildContext context,
    required DataChoosedProvider dataProvider,
    required String addon,
    required String label,
    required IconData icon,
    required String optionKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, left: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _openManualAddonPage(context, dataProvider, addon),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            visualDensity: VisualDensity.compact,
            icon: Icon(
              icon,
              color:
                  batParameters[optionKey] != null ? Colors.green : Colors.grey,
              size: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildManualAddonActions(
    BuildContext context,
    DataChoosedProvider dataProvider,
    List<String> allIds,
  ) {
    final List<Widget> actions = <Widget>[];

    if (hardeninType != 'Microsoft Office') {
      actions.add(
        Text(
          tr('ADDONS: ', 'АДДОНЫ: '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 23,
          ),
        ),
      );

      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'Firewall',
          label: 'FIREWALL',
          icon: Icons.local_police,
          optionKey: 'ManualOptions_Firewall',
        ),
      );
    }

    if (listAddonsIE.contains(hardeninType)) {
      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'IE',
          label: 'IE',
          icon: Icons.public,
          optionKey: 'ManualOptions_IE',
        ),
      );
    }

    if (listAddonsDefender.contains(hardeninType)) {
      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'Defender',
          label: 'DEFENDER',
          icon: Icons.shield,
          optionKey: 'ManualOptions_Defender',
        ),
      );
    }

    if (listAddonsBitlocker.contains(hardeninType)) {
      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'Bitlocker',
          label: 'BITLOCKER',
          icon: Icons.enhanced_encryption,
          optionKey: 'ManualOptions_Bitlocker',
        ),
      );
    }

    if (listAddonsEdge.contains(hardeninType)) {
      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'Edge',
          label: 'EDGE',
          icon: Icons.wifi_protected_setup,
          optionKey: 'ManualOptions_Edge',
        ),
      );
    }

    if (listAddonsNextGenerationSecurity.contains(hardeninType)) {
      actions.add(
        _buildManualAddonButton(
          context: context,
          dataProvider: dataProvider,
          addon: 'NextGenerationSecurity',
          label: 'NEXTGEN',
          icon: Icons.backup,
          optionKey: 'ManualOptions_NextGenerationSecurity',
        ),
      );
    }

    actions.add(
      Padding(
        padding: EdgeInsets.only(left: 15),
        child: Text(
          tr('ALL: ', 'ВСЕ: '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 23,
          ),
        ),
      ),
    );

    actions.add(
      Padding(
        padding: const EdgeInsets.only(right: 5, left: 5),
        child: IconButton(
          onPressed: () {
            Provider.of<DataChoosedProvider>(context, listen: false)
                .setAllCheckingIds(allIds);
            chooseManualPageItems =
                Provider.of<DataChoosedProvider>(context, listen: false).myData;
          },
          icon: const Icon(Icons.playlist_add_check, size: 30),
        ),
      ),
    );

    actions.add(
      Padding(
        padding: const EdgeInsets.only(right: 32),
        child: IconButton(
          onPressed: () {
            Provider.of<DataChoosedProvider>(context, listen: false)
                .setAllUnchecking();
            chooseManualPageItems =
                Provider.of<DataChoosedProvider>(context, listen: false).myData;
          },
          icon: const Icon(Icons.playlist_remove, size: 30),
        ),
      ),
    );

    return actions;
  }

  Future<void> _saveManualSelection(
    BuildContext context,
    List itemsToList,
    List<String> isChoosingFeatureList,
  ) async {
    final bool hasAddonsOptions = !hasSelectedManualAddonOptions(batParameters);

    if (isChoosingFeatureList.isEmpty && hasAddonsOptions) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            tr('Warning! No items for saving!', 'Внимание! Нет элементов для сохранения!'),
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
      return;
    }

    final List mainListManualPage = <Object>[itemsToList, isChoosingFeatureList];
    batParameters['mainListManualPage'] = mainListManualPage;
    await generateBatFileOSManual(batParameters);

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          tr('Your file is saved.', 'Файл успешно сохранен.'),
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

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamed(context, '/');
  }

  Widget _buildManualItemsPane(
    BuildContext context,
    List itemsToList,
    List<String> isChoosingFeatureList,
    ScrollController scrollControllerManualPage,
    double screenWidth,
    DataChoosedProvider dataProvider,
    int totalItemsCount,
  ) {
    return SizedBox(
      width: screenWidth * 0.65,
      child: SingleChildScrollView(
        controller: scrollControllerManualPage,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildManualSearchAndFilterBar(
                context,
                itemsToList,
                totalItemsCount,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  child: ListView.builder(
                    itemCount: itemsToList.length,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final currentItem = itemsToList[index];
                      return Card(
                        child: CheckboxListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentItem[1]}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${tr('Value', 'Значение')}: ${currentItem[2]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          value: isChoosingFeatureList
                              .contains(currentItem[0].toString()),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 1),
                          onChanged: (bool? value) {
                            Provider.of<DataChoosedProvider>(
                              context,
                              listen: false,
                            ).fetchDataById(
                              currentItem[0].toString(),
                              value ?? false,
                            );

                            chooseManualPageItems =
                                Provider.of<DataChoosedProvider>(
                              context,
                              listen: false,
                            ).myData;

                            currentListValuesSingleAddon = currentItem;
                            _keyControllerOffsetManualPage =
                                scrollControllerManualPage.offset;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualDetailsPane(double screenWidth) {
    return buildSelectedRecordDetailsPane(screenWidth);
  }

  Widget _buildManualFooterStatus(
    BuildContext context,
    int totalItemsCount,
    int filteredItemsCount,
    int selectedItemsCount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Text(
        tr(
          'Records: $totalItemsCount, filtered: $filteredItemsCount, selected: $selectedItemsCount.',
          'Количество записей: $totalItemsCount, отфильтровано: $filteredItemsCount, выбрано: $selectedItemsCount.',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return reactivePage((context) {
      for (final keyAddon in manualAddonOptionKeys) {
        if (batParameters[keyAddon] != null) {
          final selectedAddonItems = batParameters[keyAddon][1];
          if (selectedAddonItems is List && selectedAddonItems.isEmpty) {
            batParameters[keyAddon] = null;
          }
        }
      }

      ScrollController scrollControllerManualPage =
          ScrollController(initialScrollOffset: _keyControllerOffsetManualPage);
      final screen = MediaQuery.of(context).size;
      var screenWidth = screen.width;
      return FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(child: Center(child: Text(tr('ERROR', 'ОШИБКА')))),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          var itemsToList = snapshot.data!;

          if (itemsToList.isEmpty) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text(
                    tr(
                      'No parameters were loaded for this scenario.',
                      'Для этого сценария параметры не были загружены.',
                    ),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          List initData = chooseManualPageItems;
          final List<String> allIds = itemsToList
              .map<String>((dynamic item) => item[0].toString())
              .toList();

          if (currentListValuesSingleAddon.isEmpty) {
            currentListValuesSingleAddon = itemsToList[0];
          }
          _manualDataProvider ??=
              DataChoosedProvider('ManualMainPage', initData);
          return ChangeNotifierProvider<DataChoosedProvider>.value(
            value: _manualDataProvider!,
            child: Consumer<DataChoosedProvider>(
              builder: (context, dataProvider, _) {
                List<String> isChoosingFeatureList = dataProvider.myData;
                final List visibleItems = _applyManualViewState(
                  itemsToList,
                  isChoosingFeatureList,
                );
                final int selectedItemsCount = isChoosingFeatureList.length;

                if (visibleItems.isNotEmpty &&
                    !visibleItems.contains(currentListValuesSingleAddon)) {
                  currentListValuesSingleAddon = visibleItems.first;
                }

                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      Row(
                        children: _buildManualAddonActions(
                          context,
                          dataProvider,
                          allIds,
                        ),
                      ),
                    ],
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: FloatingActionButton(
                    focusElevation: 5,
                    isExtended: true,
                    elevation: 40,
                    tooltip: tr('Make .bat', 'Создать .bat'),
                    hoverElevation: 50,
                    backgroundColor: Colors.blueGrey,
                    onPressed: () async => _saveManualSelection(
                      context,
                      itemsToList,
                      isChoosingFeatureList,
                    ),
                    child: const Icon(Icons.save),
                  ),
                  body: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _buildManualItemsPane(
                                    context,
                                    visibleItems,
                                    isChoosingFeatureList,
                                    scrollControllerManualPage,
                                    screenWidth,
                                    dataProvider,
                                    itemsToList.length,
                                  ),
                                  const VerticalDivider(width: 1.0),
                                  _buildManualDetailsPane(screenWidth),
                                ],
                              ),
                            ),
                            _buildManualFooterStatus(
                              context,
                              itemsToList.length,
                              visibleItems.length,
                              selectedItemsCount,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        },
      );
    });
  }
}

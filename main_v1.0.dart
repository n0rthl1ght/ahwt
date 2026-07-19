import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'generate_bat.dart';
import 'utils.dart';

// NOTES:
// https://github.com/go-flutter-desktop/go-flutter/issues/510  ==> icon on exe
//import 'package:provider/provider.dart';
// https://siro.hashnode.dev/setting-the-screen-size-of-your-flutter-desktop-app-at-startup

/* ---------------- Global Variables - not best practice :( ------------- */

Map batParameters = {};
String? selectedOS = '';
String? selectedMode = '';
String? selectedOffice = '';
String? selectedIEVersion = '';
late final ScrollController controller;
late final ScrollController scrollControllerManualPage;
double _keyControllerOffset = 0;
double _keyControllerOffsetManualPage = 0;
List currentListValuesSingleAddon = [];
List listAddonsManualPage = [];

String outputDir = Directory.current.path;
// String outputDir = 'D:\\FL\\ahwt-main\\AHWT__1.4';

/* ------------------------ MAIN CODE ------------------------ */

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(400, 600));
    WindowManager.instance.setMaximumSize(const Size(1200, 1500));

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 900),
      center: true,
      backgroundColor: Colors.transparent,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {

            case MyHomePage.routeName:
                  return MaterialPageRoute(builder: (BuildContext context) {
                    return const MyHomePage(title: 'AHWT 2.1');});

            case SetFilename.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
              return const SetFilename();});

            case SetMode.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const SetMode();});

            case ModeChooseOffice.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const ModeChooseOffice();});

            case AddonsPage.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const AddonsPage();});

            case IeChoosingMode.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const IeChoosingMode();});

            case ShieldUpModePage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const ShieldUpModePage();});

            case LevelDetailAutoPage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const LevelDetailAutoPage();});

            case AddonsSinglePage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const AddonsSinglePage();});

            case SingleAddonFinishPage.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                  return const SingleAddonFinishPage();});

            case FinishHardeninPage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const FinishHardeninPage();});

            case AddingNewRuleFirewall.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const AddingNewRuleFirewall();});

            case OfficeSettingPage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const OfficeSettingPage();});

            case AddingNewRuleFirewallXP.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const AddingNewRuleFirewallXP();});

            case ManualPage.routeName:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const ManualPage();});


            default:
              return MaterialPageRoute(builder: (BuildContext context) {
                return const ErrorsPage();});
          }
        },
      title: 'AHWT v.2',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AHWT v.2'),
    );
  }
}
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

  List<DropdownMenuItem<String>> get hardeningListChoiceItems{
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

  @override
  Widget build(BuildContext context) {
    batParameters = {};
    return Scaffold(
      backgroundColor: Colors.white,
      body:
        Form(
        key: _dropdownFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Choose Hardening',
                        style: TextStyle(
                          fontSize: 26,
                        ),),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    validator: (value) => value == null ? "Choose value" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                        selectedOS = newValue;
                      });
                    },
                    items: hardeningListChoiceItems),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    if (_dropdownFormKey.currentState!.validate()) {
                      if (selectedOS != '') {
                          batParameters['Hardenin'] = selectedOS;
                          Navigator.of(context).pushNamed('/setFname');
                      }
                    }
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
            ),
            ),
          ],
        ))
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,
        body:
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Padding(
                   padding: const EdgeInsets.all(35.0),
                    child: Text(
                        'Choosed Hardening: $currentHardening',
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                    ),
                 ),
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: fnameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter bat filename',
                      ),
                    ),
                  ),
                ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                            String fnameBat = fnameController.text;
                            if (fnameBat != '') {
                              if (!fnameBat.endsWith('.bat')) {fnameBat = '$fnameBat.bat';}
                              String fnameBatApsPath = '$outputDir\\$fnameBat';
                              // print(fnameBatApsPath);
                              if (FileSystemEntity.typeSync(fnameBatApsPath) != FileSystemEntityType.notFound) {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: const Text(
                                        'File is already exists :(',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black)),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true)
                                              .pop(); // dismisses only the dialog and returns nothing
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              else {
                                batParameters['fnameBat'] = fnameBat;
                                Navigator.of(context).pushNamed('/setMode');
                              }

                            }
                        },
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
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

  @override
  Widget build(BuildContext context) {

    batParameters['FirewallRules'] = [];

    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Auto", child: Text("Auto")),
      const DropdownMenuItem(value: "Manual", child: Text("Manual")),
      // const DropdownMenuItem(value: "Addon", child: Text("Addon")),
    ];
    if (currentHardening != 'Microsoft Office') {
      menuItems.add(const DropdownMenuItem(value: "Addon", child: Text("Addon")));
    }

    return Scaffold(
      appBar: AppBar(),
        backgroundColor: Colors.white,
        body:
          Center(
            child: Form(
              key: _dropdownFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Hardening: $currentHardening\nFilename: $currentFname',
                         style: const TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Choose mode:',
                      style: TextStyle(
                        fontSize: 24,
                      ),),
                  ),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value == null ? "Choose Value" : null,
                          dropdownColor: Colors.blueGrey,
                          value: selectedValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                              selectedMode = newValue;
                            });
                          },
                          items: menuItems),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        if (_dropdownFormKey.currentState!.validate()) {
                          if (selectedMode != '') {
                            batParameters['Mode'] = selectedMode;

                            if (currentHardening != 'Microsoft Office') {
                              if (selectedMode == 'Auto') {
                                Navigator.of(context).pushNamed('/chooseLevelAutoMode');
                              }
                              if (selectedMode == 'Addon') {
                                batParameters['levelAutoMode'] = '-';
                                Navigator.of(context).pushNamed('/setSingleAddons');
                              }
                              if (selectedMode == 'Manual') {
                                batParameters['ManualOptions_Firewall'] = null;
                                batParameters['ManualOptions_IE'] = null;
                                batParameters['ManualOptions_Defender'] = null;
                                batParameters['ManualOptions_Bitlocker'] = null;
                                batParameters['ManualOptions_Edge'] = null;
                                batParameters['ManualOptions_NextGenerationSecurity'] = null;

                                Navigator.of(context).pushNamed('/ManualPage');
                              }

                            }
                            else {
                                Navigator.of(context).pushNamed('/OfficeSettingsPageAuto');
                              }
                          }
                        }
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        )
    );
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

  List<DropdownMenuItem<String>> get modeListChoiceItems{
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,
        body:
          Form(
            key: _dropdownFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Choose Office Version',
                    style: TextStyle(
                      fontSize: 24,
                    ),),
                ),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) => value == null ? "Choose value" : null,
                        dropdownColor: Colors.blueGrey,
                        value: selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                            selectedOffice = newValue;
                          });
                        },
                        items: modeListChoiceItems),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (_dropdownFormKey.currentState!.validate()) {
                        if (selectedOffice != '') {
                          batParameters['VersionOffice'] = selectedOffice;
                          Navigator.of(context).pushNamed('/');
                        }
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),

                    ),

                  ),
                ),
              ],
            ))
    );
  }
}
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


  // "Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"

  static const listAddonsIE = ["Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10"];
  static const listAddonsDefender = ["Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsBitlocker = ["Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsEdge = ["Windows 10", "Windows 11"];
  static const listAddonsNextGenerationSecurity = ["Windows 10", "Windows 11"];

  @override
  Widget build(BuildContext context) {
    List<String> addonsList = ["Firewall"];

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

    return Scaffold(
        appBar: AppBar(),
        body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Hardening: $currentHardenin\nFilename: $currentFilename\nMode: $currentMode',
                     style: const TextStyle(
                      fontSize: 19,
                      ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Choose mode:',
                  style: TextStyle(
                    fontSize: 24,
                  ),),
              ),
              Padding(
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
                      ),
                    ).toList(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                      batParameters['Addons'] = isChoosingAddons;
                      if (isChoosingAddons.contains('IE')) {
                        // "Windows 8.1", "Windows 10"
                        if (currentHardenin == "Windows 8.1" || currentHardenin == "Windows 10") {
                          batParameters['VersionIE'] = 'ie11';
                          if (isChoosingAddons.contains('Firewall')) {
                            Navigator.of(context).pushNamed('/chooseShieldUpMode');
                          }
                          else
                          {
                            Navigator.of(context).pushNamed('/finishHardeninPage');  // !!!!! RESULT AUTO!
                          }
                        }
                        else {
                          Navigator.of(context).pushNamed('/chooseIEPage');
                        }
                      }
                      else {
                        if (isChoosingAddons.contains('Firewall')) {
                          Navigator.of(context).pushNamed('/chooseShieldUpMode');
                        }
                        else
                        {
                          Navigator.of(context).pushNamed('/finishHardeninPage');  // !!!!! RESULT AUTO!
                        }
                      }

                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      );
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
  // "Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"
  final _dropdownFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    batParameters['makeTwiceGoBack'] = '+';
    menuItems = [];
    if (currentAddonsList.contains('IE')) {
      if (currentSelectedOS == "Windows XP") {
        // selectedValue = "ie6";
        menuItems.add(const DropdownMenuItem(value: "ie6", child: Text("ie6")));
        menuItems.add(const DropdownMenuItem(value: "ie6,ie7", child: Text("ie7")));
        menuItems.add(const DropdownMenuItem(value: "ie6,ie7,ie8", child: Text("ie8")));
      }
      if (currentSelectedOS == "Windows Vista") {
        // selectedValue = "ie7";
        menuItems.add(const DropdownMenuItem(value: "ie7", child: Text("ie7")));
        menuItems.add(const DropdownMenuItem(value: "ie7,ie8", child: Text("ie8")));
        menuItems.add(const DropdownMenuItem(value: "ie7,ie8,ie9", child: Text("ie9")));
      }
      if (currentSelectedOS == "Windows 7") {
        // selectedValue = "ie8";
        menuItems.add(const DropdownMenuItem(value: "ie8", child: Text("ie8")));
        menuItems.add(const DropdownMenuItem(value: "ie8,ie9", child: Text("ie9")));
        menuItems.add(const DropdownMenuItem(value: "ie8,ie9,ie10", child: Text("ie10")));
        menuItems.add(const DropdownMenuItem(value: "ie8,ie9,ie10,ie11", child: Text("ie11")));
      }
      if (currentSelectedOS == "Windows 8") {
        // selectedValue = "ie10";
        menuItems.add(const DropdownMenuItem(value: "ie10", child: Text("ie10")));
        menuItems.add(const DropdownMenuItem(value: "ie10,ie11", child: Text("ie11")));
      }
    }

    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,
          body:
          Form(
            key: _dropdownFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Choose IE Version:',
                    style: TextStyle(
                      fontSize: 24,
                    ),),
                ),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) => value == null ? "Choose version" : null,
                        dropdownColor: Colors.blueGrey,
                        value: selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                            selectedIEVersion = newValue;
                          });
                        },
                        items: menuItems),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      selectedIEVersion = selectedValue;
                        if (selectedIEVersion != '') {
                          batParameters['VersionIE'] = selectedIEVersion;
                          if (currentSelectedMode == 'Addon') {
                            batParameters['Addons'] = ['IE'];
                            currentListValuesSingleAddon = [];
                            Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
                          }
                          else if (currentSelectedMode == 'Manual') {
                            batParameters['Addons'] = ['IE'];
                            currentListValuesSingleAddon = [];
                            Navigator.pushNamed(context, '/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                          }
                          else {

                            if (currentAddonsList.contains('Firewall')) {
                              Navigator.pushNamed(context, '/chooseShieldUpMode');
                            }
                            else {
                              Navigator.pushNamed(context, '/finishHardeninPage');
                            }
                          }
                        }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),

                    ),

                  ),
                ),
              ],
            ))
    );
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

  @override
  Widget build(BuildContext context) {
    String currentSelectedOS = batParameters['Hardenin'];
    String currentFilename = batParameters['fnameBat'];
    String currentSelectedMode = batParameters['Mode'];
    // var currentAddonsList = batParameters['Addons'];


    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hardening: $currentSelectedOS\nFilename: $currentFilename\nMode: $currentSelectedMode',
                style: const TextStyle(
                  fontSize: 19,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Enable ShieldUp Mode?',
                style: TextStyle(
                  fontSize: 24,
                ),),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    validator: (value) => value == null ? "Yes or No" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: modeListChoiceItems),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  batParameters['isShieldUpMode'] = selectedValue;
                  Navigator.of(context).pushNamed('/finishHardeninPage');
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  List<String> currentAddonsList = batParameters['Addons'] ?? '-';
  String isShieldUpMode = batParameters['isShieldUpMode'] ?? 'No';

  @override
  Widget build(BuildContext context) {

    if (selectedIEVersion.contains(',')) {
      selectedIEVersion = selectedIEVersion.split(',')[selectedIEVersion.split(',').length - 1];
    }
    
    String currentAddonsListString = currentAddonsList.join(',');
    if (currentAddonsListString == '') {
      currentAddonsListString = '-';
    }

    var listItems = ['Hardening: $currentHardenin',
                     'Filename: $currentFilename',
                     'Mode: $currentSelectedMode',
                      'Level (auto): $currentLevelAutoMode',
                      'Addons: $currentAddonsListString',
                      'IE: $selectedIEVersion',
                      'ShieldUpMode: $isShieldUpMode',
                    ];
    var newList = [];

    for (String element in listItems) {
      if (!element.contains(': -')) {
        if (element.contains('ShieldUpMode')) {
          if (currentAddonsListString.contains('Firewall')) {
            newList.add(element);
          }
        }
        else {
          newList.add(element);
        }
        //

      }
    }
    String presentString = newList.join('\n');

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Current config:',
                style: TextStyle(
                  fontSize: 24,
                ),),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(presentString,
                style: const TextStyle(
                  fontSize: 19,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                    // String error;
                    try {
                      await generateBatFileOSAuto(batParameters);
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                              'Your file is saved.',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black)),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop(); // dismisses only the dialog and returns nothing
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );

                      Navigator.pushNamed(context, '/');
                    }

                    catch (error) {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(
                              'Some Error: $error',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black)),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop(); // dismisses only the dialog and returns nothing
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }

                  },
                child: const Text(
                  'Make .bat-file!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    String currentSelectedOS = batParameters['Hardenin'];
    String currentFilename = batParameters['fnameBat'];
    String currentSelectedMode = batParameters['Mode'];

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hardening: $currentSelectedOS\nFilename: $currentFilename\nMode: $currentSelectedMode',
                style: const TextStyle(
                  fontSize: 19,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Choose Level Auto Mode:',
                style: TextStyle(
                  fontSize: 24,
                ),),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    validator: (value) => value == null ? "Level?" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: modeListChoiceItems),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  batParameters['levelAutoMode'] = selectedValue;
                  Navigator.of(context).pushNamed('/setAddons');
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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


  @override
  Widget build(BuildContext context) {
    menuItems = [];
    menuItems.add(const DropdownMenuItem(value: "Firewall", child: Text("Firewall")));
    if (listAddonsIE.contains(currentHardenin)) {
      menuItems.add(const DropdownMenuItem(value: "IE", child: Text("IE")));
    }
    if (listAddonsDefender.contains(currentHardenin)) {
      menuItems.add(const DropdownMenuItem(value: "Defender", child: Text("Defender")));
    }
    if (listAddonsBitlocker.contains(currentHardenin)) {
      menuItems.add(const DropdownMenuItem(value: "Bitlocker", child: Text("Bitlocker")));
    }
    if (listAddonsEdge.contains(currentHardenin)) {
      menuItems.add(const DropdownMenuItem(value: "Edge", child: Text("Edge")));
    }
    if (listAddonsNextGenerationSecurity.contains(currentHardenin)) {
      menuItems.add(const DropdownMenuItem(value: "NextGenerationSecurity", child: Text("NextGenerationSecurity")));
    }

    selectedValue = menuItems[0].value;
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,
        body:
        Form(
            key: _dropdownFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Choose Addon:',
                    style: TextStyle(
                      fontSize: 24,
                    ),),
                ),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) => value == null ? "Choose Addon" : null,
                        dropdownColor: Colors.blueGrey,
                        value: selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items: menuItems),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (selectedValue != '') {
                        currentListValuesSingleAddon = ['','-','-','-','-','Choose any item in left ScrollView'];
                        batParameters['SingleAddon'] = selectedValue;
                        batParameters['FirewallRules'] = [];
                        _keyControllerOffset = 0;
                        if (selectedValue == 'IE') {
                          batParameters['Addons'] = ['IE'];
                          if (batParameters['Hardenin'] == 'Windows 10' || batParameters['Hardenin'] == 'Windows 8.1') {
                            batParameters['VersionIE'] = 'ie11';
                            Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
                          }
                          else {
                            Navigator.pushNamed(context, '/chooseIEPage');
                          }

                        }
                        else {
                          Navigator.pushNamed(context, '/finishHardeninSingleAddonPage');
                        }
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),

                  ),
                ),
              ],
            ))
    );
  }
}
/* ----------------Finish Addons Single Page------------- */
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
  List<String> isChoosingFeatureList = [];
  List manualAdditionAddonsList = batParameters['ManualAdditionsAddonsList'] ?? [];
  List paramsMap = [];

  Future<List> getData() async {
    if (paramsMap.isEmpty) {
      if (singleAddon == 'Firewall') {
        paramsMap = await returnFirewallSingleAddonParams(batParameters);
      }
      else {
        paramsMap = await returnSingleAddonParams(batParameters);
      }
    }
    return paramsMap;
  }

  @override
  Widget build(BuildContext context) {

    if (mode == 'Manual') {
      String paramsTitle = 'ManualOptions_$singleAddon';
      if (batParameters[paramsTitle] != null) {
        isChoosingFeatureList = batParameters[paramsTitle][1];
      }
    }


    List firewallRulesList = batParameters['FirewallRules'];
    ScrollController controller = ScrollController(initialScrollOffset: _keyControllerOffset);
    final screen =  MediaQuery.of(context).size;
    var screenWidth = screen.width;
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const Scaffold(body: SafeArea(child: Center(child: Text('ERROR'))));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          else {
            var itemsToList = snapshot.data!;

              if (currentListValuesSingleAddon.isEmpty) {
                currentListValuesSingleAddon = itemsToList[0];
              }
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    if (singleAddon == 'Firewall') const Text('RULES: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontSize: 23,
                        )),
                    if (singleAddon == 'Firewall') Padding(
                        padding: const EdgeInsets.only(right: 10, left: 1),
                        child: IconButton(
                          onPressed: () {
                            if (hardeninType == "Windows XP") {
                              Navigator.of(context).pushNamed('/AddNewFirewallRuleXP');
                            }
                            else {
                              Navigator.of(context).pushNamed('/AddNewFirewallRule');
                            }

                          },
                          icon: const Icon(
                            Icons.queue,
                            size: 30,
                          ),
                        )
                    ),
                    const Text('ALL: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontSize: 23,
                        )),
                    Padding(
                        padding: const EdgeInsets.only(right: 5, left: 5),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isChoosingFeatureList = itemsToList.map((x) => x[0].toString()).toList();
                            });
                          },
                          icon: const Icon(
                            Icons.playlist_add_check,
                            size: 30,
                          ),
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isChoosingFeatureList = [];
                            });
                          },
                          icon: const Icon(
                            Icons.playlist_remove,
                            size: 30,
                          ),
                        )
                    ),
                  ],
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: FloatingActionButton(
                  // autoFocus: true,
                  focusElevation: 5,
                  isExtended: true,
                  elevation: 40,
                  tooltip: mode=='Addon' ? 'Make .bat' : 'Save addon & go back',
                  hoverElevation: 50,
                  backgroundColor: Colors.blueGrey,
                  child: mode=='Addon' ? const Icon(Icons.save) : const Icon(Icons.thumb_up_alt), // https://fonts.google.com/icons
                  onPressed: () async {



                      if (isChoosingFeatureList.isEmpty && firewallRulesList.isEmpty) {

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Warning! No items for saving!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );

                      }
                      else {

                        _keyControllerOffset = 0;

                        if (mode=='Addon') {
                          await generateBatFileSingleAddon(batParameters, itemsToList, isChoosingFeatureList);
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: const Text(
                                  'Your file is saved.',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black)),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(); // dismisses only the dialog and returns nothing
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          Navigator.pushNamed(context, '/');
                        }
                        else {
                            List optionsSingleAddon = [itemsToList, isChoosingFeatureList];
                            batParameters['ManualOptions_$singleAddon'] = optionsSingleAddon;
                            if (firewallRulesList.isNotEmpty) {
                              batParameters['ManualOptions_FirewallRulesList'] = firewallRulesList;
                            }
                            else {
                              batParameters['ManualOptions_FirewallRulesList'] = [];
                            }

                            setState(() {
                            });

                          if (batParameters['makeTwiceGoBack'] != null && singleAddon=='IE') {
                            batParameters['makeTwiceGoBack'] = null;
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          Navigator.of(context, rootNavigator: true).pop();
                          }
                      }
                  },

                ),
                body: Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.65,
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SizedBox(
                                  child: ListView.builder(
                                      itemCount: itemsToList.length,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var currentItem = itemsToList[index];
                                        return Card(
                                          child: CheckboxListTile(
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${currentItem[1]}',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),),
                                                Text('Value: ${currentItem[2]}',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FontStyle.italic
                                                  ),),
                                              ],
                                            ),
                                            value: isChoosingFeatureList.contains(
                                                currentItem[0].toString()),
                                            contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                currentListValuesSingleAddon = currentItem;
                                                _keyControllerOffset = controller.offset;
                                                if (value!) {
                                                  isChoosingFeatureList.add(currentItem[0].toString());
                                                } else {
                                                  isChoosingFeatureList.remove(currentItem[0].toString());
                                                }
                                              });
                                            },
                                          ),
                                        );
                                      }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: screenWidth * 0.3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText('Key: ${currentListValuesSingleAddon[1]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic
                                  ),
                                ),
                                SelectableText.rich(
                                  TextSpan(
                                      style: const TextStyle(fontSize: 15),
                                      children: [
                                        TextSpan(text:'Value: ${currentListValuesSingleAddon[2]}\n',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.italic
                                          ),),
                                        TextSpan(text:'Type: ${currentListValuesSingleAddon[3]}\n',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.italic
                                          ),),
                                        TextSpan(text:'Parameter: ${currentListValuesSingleAddon[4]}\n',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.italic
                                          ),),
                                        const TextSpan(text:'\nDescription:\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            // fontStyle: FontStyle.italic
                                          ),),
                                        TextSpan(text: currentListValuesSingleAddon[5]),
                                      ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
          }
      }
    );
  }
}
/*----------------------------------------------------------------------*/
class ErrorsPage extends StatefulWidget {
  const ErrorsPage({super.key});

  @override
  State<ErrorsPage> createState() => _ErrorsPageState();
}

class _ErrorsPageState extends State<ErrorsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Center(
            child: Text('ОШИБКА!!!!!!!!!!!'),
          )),);
  }
}
/*------------------Adding New Rules Firewall-----------------------------*/
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
  final TextEditingController _textPortControllerRemote = TextEditingController();
  final TextEditingController _textControllerPathToProgram = TextEditingController();

  List firewallRulesList = batParameters['FirewallRules'];
  String hardeninType = batParameters['Hardenin'];

  List<DropdownMenuItem<String>> get modeListChoiceItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "ip", child: Text("IP-address")),
      const DropdownMenuItem(value: "port", child: Text("Port")),
      const DropdownMenuItem(value: "program", child: Text("Program")),
    ];
    return menuItems;
  }
  var selectedValueIpPortOrProgram = 'ip';

  List<DropdownMenuItem<String>> get modeListChoiceItemsDirection {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "in", child: Text("IN")),
      const DropdownMenuItem(value: "out", child: Text("OUT")),
    ];
    return menuItems;
  }
  var selectedValueDirection = 'in';

  List<DropdownMenuItem<String>> get modeListChoiceProfileRule {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "domain", child: Text("Domain")),
      const DropdownMenuItem(value: "private", child: Text("Private")),
      const DropdownMenuItem(value: "public", child: Text("Public")),
      const DropdownMenuItem(value: "any", child: Text("Any")),
    ];
    return menuItems;
  }
  var selectedValueProfile = 'domain';

  List<DropdownMenuItem<String>> get modeListChoiceAction {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "block", child: Text("Block")),
      const DropdownMenuItem(value: "allow", child: Text("Allow")),
    ];
    return menuItems;
  }
  var selectedValueAction = 'block';

  List<DropdownMenuItem<String>> get modeListChoiceItemsProto {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "tcp", child: Text("TCP")),
      const DropdownMenuItem(value: "udp", child: Text("UDP")),
    ];
    return menuItems;
  }
  // var selectedValueProto = 'tcp';
  String? selectedValueProto;

  List<DropdownMenuItem<String>> get modeListChoiceItemsTypeIP {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "localip", child: Text("Local IP")),
      const DropdownMenuItem(value: "remoteip", child: Text("Remote IP")),
    ];
    return menuItems;
  }
  var selectedValueLocalOrRemoteIP = 'localip';


  @override
  Widget build(BuildContext context) {

    final screen =  MediaQuery.of(context).size;
    var screenWidth = screen.width;

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
                'Adding new Firewall Rule (${firewallRulesList.length}):',
                style: const TextStyle(
                  fontSize: 21,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Specify the action direction:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    validator: (value) => value == null ? "?" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValueDirection,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValueDirection = newValue!;
                      });
                    },
                    items: modeListChoiceItemsDirection),
              ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Select item:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  validator: (value) => value == null ? "?" : null,
                  dropdownColor: Colors.blueGrey,
                  value: selectedValueIpPortOrProgram,
                  onChanged: (String? newValue) async {

                    setState(() {
                      selectedValueIpPortOrProgram = newValue!;
                    });

                  },

                  items: modeListChoiceItems),
            ),
            if (selectedValueIpPortOrProgram=='ip') const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Specify type:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            if (selectedValueIpPortOrProgram=='ip') SizedBox(
              width: 300,
              child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  validator: (value) => value == null ? "?" : null,
                  dropdownColor: Colors.blueGrey,
                  value: selectedValueLocalOrRemoteIP,
                  onChanged: (String? newValue) {

                    setState (() {
                      selectedValueLocalOrRemoteIP = newValue!;
                      _textIPControllerLocal.clear();
                      _textIPControllerRemote.clear();
                  });},
                  items: modeListChoiceItemsTypeIP),
            ),
            if (selectedValueIpPortOrProgram=='program') Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Choosed Program:',
                      style: TextStyle(
                        fontSize: 16,
                      ),),
                  ),
                  SizedBox(
                    width: screenWidth*0.6,
                    child: Row(
                      children: [
                          Expanded(
                          child: TextField(
                            controller: _textControllerPathToProgram,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                            onEditingComplete: () => setState(() {
                            }),
                            decoration: InputDecoration(
                              errorText: validatePathToProgram(_textControllerPathToProgram.text),
                              border: InputBorder.none,
                              hintText: 'path/to/application',

                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  ),
                            ),
                          ),),
                        IconButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles();

                            String choosedFileToFirewallTmp;
                            if (result != null) {
                              choosedFileToFirewallTmp = result.files.single.path!;
                            } else {
                              choosedFileToFirewallTmp = '';
                            }
                            setState((){
                              // choosedFileToFirewall = choosedFileToFirewallTmp;
                              _textControllerPathToProgram.text = choosedFileToFirewallTmp;
                            });
                          },
                          icon: const Icon(
                            Icons.folder,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Enter IP address(es)',
                    style: TextStyle(
                      fontSize: 16,
                    ),),
                  Text(
                    '(single or range, or with mask), separated by commas',
                    style: TextStyle(
                      fontSize: 13,
                    ),),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth*0.5,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textIPControllerLocal,
                        enabled: selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP=='remoteip' ? false : true,
                        textAlign: TextAlign.center,
                        onEditingComplete: () => setState(() {
                        }),
                        decoration: InputDecoration(
                          errorText: validateIPAddresses(_textIPControllerLocal.text, false, selectedValueIpPortOrProgram, selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP == 'remoteip'),
                          border: InputBorder.none,
                          hintText: selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP=='remoteip' ? '': 'LOCAL IP',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      child: TextField(
                        controller: _textIPControllerRemote,
                        enabled: selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP=='localip' ? false : true,
                        textAlign: TextAlign.center,
                        onEditingComplete: () => setState(() {
                        }),
                        decoration: InputDecoration(
                          errorText: validateIPAddresses(_textIPControllerRemote.text, true, selectedValueIpPortOrProgram, selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP == 'localip'),
                          border: InputBorder.none,
                          hintText: selectedValueIpPortOrProgram == 'ip' && selectedValueLocalOrRemoteIP=='localip' ? '': 'REMOTE IP',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                Text(
                  'Enter port number(s)',
                  style: TextStyle(
                  fontSize: 16,
                ),),
              Text(
                '(single or a range (e.g., 80,443,1000-2000)',
                style: TextStyle(
                  fontSize: 13,
                ),),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth*0.5,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textPortControllerLocal,
                        onEditingComplete: () => setState(() {
                        }),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          errorText: validatePorts(_textPortControllerLocal.text, selectedValueLocalOrRemoteIP),
                          border: InputBorder.none,
                          hintText: 'LOCAL PORT',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      child: TextField(
                        controller: _textPortControllerRemote,
                        onEditingComplete: () => setState(() {
                        }),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          errorText: validatePorts(_textPortControllerRemote.text, selectedValueLocalOrRemoteIP),
                          border: InputBorder.none,
                          hintText: 'REMOTE PORT',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Specify the protocol:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  validator: (value) => value == null ? "?" : null,
                  dropdownColor: Colors.blueGrey,
                  value: selectedValueProto,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValueProto = newValue!;
                    });
                  },
                  items: modeListChoiceItemsProto),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Specify the action:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  validator: (value) => value == null ? "?" : null,
                  dropdownColor: Colors.blueGrey,
                  value: selectedValueAction,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValueAction = newValue!;
                    });
                  },
                  items: modeListChoiceAction),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'For which profile will the rule be used?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  validator: (value) => value == null ? "?" : null,
                  dropdownColor: Colors.blueGrey,
                  value: selectedValueProfile,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValueProfile = newValue!;
                    });
                  },
                  items: modeListChoiceProfileRule),
            ),
            //
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {

                  if (['ip','port'].contains(selectedValueIpPortOrProgram) && selectedValueProto==null && _textIPControllerRemote.text == '' && _textIPControllerLocal.text == '' && _textPortControllerRemote.text == '' && _textPortControllerLocal.text == '') {
                    String ruleName = "${selectedValueAction}_${selectedValueDirection}_$selectedValueProfile";
                    String? command = 'netsh advfirewall firewall add rule name="$ruleName" dir=$selectedValueDirection action=$selectedValueAction profile=$selectedValueProfile';
                    firewallRulesList.add([ruleName, command]);

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text(
                            'New rule is added.',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black)),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(); // dismisses only the dialog and returns nothing
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    Navigator.pop(context, true);

                  }

                  else {
                    bool hasProblems = false;

                    if (selectedValueProto==null) {
                      if (_textPortControllerLocal.text != '' || _textPortControllerRemote.text != '')
                      {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Protocol validation check not passed!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    if (validatePorts(_textPortControllerRemote.text, selectedValueLocalOrRemoteIP) != null) {
                      hasProblems = true;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                              'Remote Port failed validation check!',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black)),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop(); // dismisses only the dialog and returns nothing
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (validatePorts(_textPortControllerLocal.text, selectedValueLocalOrRemoteIP) != null) {
                      hasProblems = true;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                              'Local Port failed validation check!',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black)),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop(); // dismisses only the dialog and returns nothing
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }

                    // В РЕЖИМЕ IP только 1 вариант адреса
                    if (selectedValueIpPortOrProgram == 'ip') {

                      if (validateIPAddresses(_textIPControllerRemote.text, true, selectedValueIpPortOrProgram, true) != null) {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Remote IP-Address failed validation check!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (validateIPAddresses(_textIPControllerLocal.text, false, selectedValueIpPortOrProgram, true) != null) {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Local IP-Address failed validation check!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    if (selectedValueIpPortOrProgram == 'port') {

                      if (validateIPAddresses(_textIPControllerRemote.text, true, selectedValueIpPortOrProgram, false) != null) {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Remote IP-Address failed validation check!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (validateIPAddresses(_textIPControllerLocal.text, false, selectedValueIpPortOrProgram, false) != null) {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Local IP-Address failed validation check!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    if (selectedValueIpPortOrProgram == 'program') {
                      if (validatePathToProgram(_textControllerPathToProgram.text) != null) {
                        hasProblems = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Program path failed validation check!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    if (!hasProblems) {
                      String ruleName = "${selectedValueAction}_$selectedValueDirection";
                      if (_textIPControllerLocal.text != '') {
                        String ipAddress = _textIPControllerLocal.text;
                        ipAddress = ipAddress.replaceAll(',', '_').replaceAll('-', '_');
                        ruleName += '_$ipAddress';
                      }
                      if (_textIPControllerRemote.text != '') {
                        String ipAddress = _textIPControllerRemote.text;
                        ipAddress = ipAddress.replaceAll(',', '_').replaceAll('-', '_');
                        ruleName += '_$ipAddress';
                      }
                      if (_textPortControllerLocal.text != '') {
                        String ipPorts = _textPortControllerLocal.text;
                        ipPorts = ipPorts.replaceAll(',', '_').replaceAll('-', '_');
                        ruleName += '_$ipPorts';
                      }
                      if (_textPortControllerRemote.text != '') {
                        String ipPorts = _textPortControllerRemote.text;
                        ipPorts = ipPorts.replaceAll(',', '_').replaceAll('-', '_');
                        ruleName += '_$ipPorts';
                      }
                      if (_textControllerPathToProgram.text != '' && selectedValueIpPortOrProgram=='program') {
                        String programPath = _textControllerPathToProgram.text;
                        programPath = programPath.replaceAll(',', '_').replaceAll(' ', '_').replaceAll('-', '_').replaceAll('\\', '_').replaceAll(':', '_');
                        ruleName += '_$programPath';
                      }
                      ruleName += '_$selectedValueProfile';

                      String command = "netsh advfirewall firewall add rule name=\"$ruleName\" dir=$selectedValueDirection action=$selectedValueAction profile=$selectedValueProfile";
                      if (_textIPControllerLocal.text != '') {
                        String ipAddress = _textIPControllerLocal.text;
                        ipAddress = ipAddress.replaceAll(' ', '');
                        command += ' localip="$ipAddress"';
                      }
                      if (_textIPControllerRemote.text != '') {
                        String ipAddress = _textIPControllerRemote.text;
                        ipAddress = ipAddress.replaceAll(' ', '');
                        command += ' remoteip="$ipAddress"';
                      }
                      if (_textPortControllerLocal.text != '') {
                        String ipPorts = _textPortControllerLocal.text;
                        command += ' localport="$ipPorts"';
                      }
                      if (_textPortControllerRemote.text != '') {
                        String ipPorts = _textPortControllerRemote.text;
                        command += ' remoteport="$ipPorts"';
                      }

                      if (selectedValueProto != null) {
                        command += ' protocol="$selectedValueProto"';
                      }

                      if (_textControllerPathToProgram.text != '' && selectedValueIpPortOrProgram=='program') {
                        String programPath = _textControllerPathToProgram.text;
                        command += ' program="$programPath" enable=yes';
                      }

                      firewallRulesList.add([ruleName, command]);

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                              'New rule is added.',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black)),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop(); // dismisses only the dialog and returns nothing
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      Navigator.pop(context, true);
                    }
                  }

                },
                child: const Text(
                  'ADD NEW RULE',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
/*------------------Adding New Rules Firewall FOR WINDOWS ХP-----------------*/
class AddingNewRuleFirewallXP extends StatefulWidget {
  const AddingNewRuleFirewallXP({super.key});
  static const routeName = '/AddNewFirewallRuleXP';
  @override
  State<AddingNewRuleFirewallXP> createState() => _AddingNewRuleFirewallXPState();
}

class _AddingNewRuleFirewallXPState extends State<AddingNewRuleFirewallXP> {

  List firewallRulesList = batParameters['FirewallRules'];

  List<DropdownMenuItem<String>> get modeListChoiceItemsRuleTypes {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "port", child: Text("Port")),
      const DropdownMenuItem(value: "program", child: Text("Program")),
    ];
    return menuItems;
  }
  var selectedValuePortOrProgram = 'port';

  List<DropdownMenuItem<String>> get modeListChoiceItemsProto {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "tcp", child: Text("TCP")),
      const DropdownMenuItem(value: "udp", child: Text("UDP")),
      const DropdownMenuItem(value: "all", child: Text("ALL")),
    ];
    return menuItems;
  }
  var selectedValueProto = 'tcp';

  List<DropdownMenuItem<String>> get modeListChoiceMode {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "disable", child: Text("Disable")),
      const DropdownMenuItem(value: "enable", child: Text("Enable")),
    ];
    return menuItems;
  }
  var selectedValueMode = 'disable';


  List<DropdownMenuItem<String>> get modeListChoiceModeIpScope {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "all", child: Text("All")),
      const DropdownMenuItem(value: "subnet", child: Text("Subnet")),
      const DropdownMenuItem(value: "custom", child: Text("Custom")),
    ];
    return menuItems;
  }
  var selectedValueIpScope = 'all';

  List<DropdownMenuItem<String>> get modeListChoiceProfile {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "all", child: Text("All")),
      const DropdownMenuItem(value: "domain", child: Text("Domain")),
      const DropdownMenuItem(value: "standard", child: Text("Standard")),
    ];
    return menuItems;
  }
  var selectedValueProfile = 'all';

  final TextEditingController _textPortController = TextEditingController();
  final TextEditingController _textIPControllerCustom = TextEditingController();
  final TextEditingController _textControllerPathToProgram = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screen =  MediaQuery.of(context).size;
    var screenWidth = screen.width;

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
                    'Adding new XP Firewall Rule (${firewallRulesList.length}):',
                    style: const TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Specify the action mode:',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) => value == null ? "?" : null,
                      dropdownColor: Colors.blueGrey,
                      value: selectedValueMode,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValueMode = newValue!;
                        });
                      },
                      items: modeListChoiceMode),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'What will be added - port or program?',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) => value == null ? "?" : null,
                      dropdownColor: Colors.blueGrey,
                      value: selectedValuePortOrProgram,
                      onChanged: (String? newValue) async {

                        setState(() {
                          selectedValuePortOrProgram = newValue!;
                        });
                      },
                      items: modeListChoiceItemsRuleTypes),
                ),
                if (selectedValuePortOrProgram=='program') Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Choosed Program:',
                          style: TextStyle(
                            fontSize: 16,
                          ),),
                      ),
                      SizedBox(
                        width: screenWidth*0.6,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textControllerPathToProgram,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                                onEditingComplete: () => setState(() {
                                }),
                                decoration: InputDecoration(
                                  errorText: validatePathToProgram(_textControllerPathToProgram.text),
                                  border: InputBorder.none,
                                  hintText: 'path/to/application',

                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),),
                            IconButton(
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles();

                                String choosedFileToFirewallTmp;
                                if (result != null) {
                                  choosedFileToFirewallTmp = result.files.single.path!;
                                } else {
                                  choosedFileToFirewallTmp = '';
                                }
                                setState((){
                                  // choosedFileToFirewall = choosedFileToFirewallTmp;
                                  _textControllerPathToProgram.text = choosedFileToFirewallTmp;
                                });
                              },
                              icon: const Icon(
                                Icons.folder,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedValuePortOrProgram=='port') const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Enter a single port number ',
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                      Text(
                        '(e.g., 80)',
                        style: TextStyle(
                          fontSize: 13,
                        ),),
                    ],
                  ),
                ),
                if (selectedValuePortOrProgram=='port') SizedBox(
                  width: screenWidth*0.5,
                  child: TextField(
                    controller: _textPortController,
                    onEditingComplete: () => setState(() {
                    }),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: validatePortsXP(_textPortController.text),
                      border: InputBorder.none,
                      hintText: 'PORT',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                if (selectedValuePortOrProgram=='port') const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Specify the protocol:',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                if (selectedValuePortOrProgram=='port')  SizedBox(
                  width: 300,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) => value == null ? "?" : null,
                      dropdownColor: Colors.blueGrey,
                      value: selectedValueProto,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValueProto = newValue!;
                        });
                      },
                      items: modeListChoiceItemsProto),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Specify the scope:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) => value == null ? "?" : null,
                      dropdownColor: Colors.blueGrey,
                      value: selectedValueIpScope,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValueIpScope = newValue!;
                        });
                      },
                      items: modeListChoiceModeIpScope),
                ),
                if (selectedValueIpScope=='custom') const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Enter IP addresses:',
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                      Text(
                        "(comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet')",
                        style: TextStyle(
                          fontSize: 11,
                        ),),
                    ],
                  ),
                ),
                if (selectedValueIpScope=='custom') SizedBox(
                  width: screenWidth*0.5,
                  child: TextField(
                    controller: _textIPControllerCustom,
                    onEditingComplete: () => setState(() {
                    }),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: validateIPAddressesXP(_textIPControllerCustom.text),
                      border: InputBorder.none,
                      hintText: 'IP SCOPE',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'For which profile will the rule be used?',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) => value == null ? "?" : null,
                      dropdownColor: Colors.blueGrey,
                      value: selectedValueProfile,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValueProfile = newValue!;
                        });
                      },
                      items: modeListChoiceProfile),
                ),
                // button
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {

                      bool hasProblems = true;

                      setState(() {

                      });


                      if (selectedValuePortOrProgram == 'port' && _textPortController.text != '' && validatePortsXP(_textPortController.text) == null) {
                        hasProblems = false;
                      }
                      if (selectedValuePortOrProgram == 'program' && _textControllerPathToProgram.text != '' && validatePathToProgram(_textControllerPathToProgram.text) == null) {
                        hasProblems = false;
                      }
                      if (selectedValueIpScope=='custom' && validateIPAddressesXP(_textIPControllerCustom.text) != null) {
                        hasProblems = true;
                      }
                      if (!hasProblems) {
                        String command;
                        String ruleName = selectedValueMode;
                        if (_textPortController.text != '') {
                          ruleName += '_${_textPortController.text}_$selectedValueProto';
                        }
                        if (_textControllerPathToProgram.text != '') {
                          String programPath = _textControllerPathToProgram.text;
                          programPath = programPath.replaceAll(',', '_').replaceAll(' ', '_').replaceAll('-', '_').replaceAll('\\', '_').replaceAll(':', '_');
                          ruleName += '_$programPath';
                        }
                        ruleName += '_$selectedValueProfile';

                        if (selectedValuePortOrProgram == 'program') {

                          command = 'netsh firewall add allowedprogram program="${_textControllerPathToProgram.text}" name="$ruleName"';
                          command += ' mode=${selectedValueMode.toUpperCase()}';
                          command += ' profile=${selectedValueProfile.toUpperCase()}';
                          if (selectedValueIpScope=='custom') {
                            String ipscopeaddress = _textIPControllerCustom.text;
                            ipscopeaddress = ipscopeaddress.replaceAll(' ', '');
                            command += ' scope=custom addresses=$ipscopeaddress';
                          }
                          if (selectedValueIpScope=='subnet') {
                            command += ' scope=subnet';
                          }
                        }
                        else {
                          command = 'netsh firewall add portopening protocol=$selectedValueProto port=${_textPortController.text} name="$ruleName"';
                          command += ' mode=${selectedValueMode.toUpperCase()}';
                          command += ' profile=${selectedValueProfile.toUpperCase()}';
                          if (selectedValueIpScope=='custom') {
                            String ipscopeaddress = _textIPControllerCustom.text;
                            ipscopeaddress = ipscopeaddress.replaceAll(' ', '');
                            command += ' scope=custom addresses=$ipscopeaddress';
                          }
                          if (selectedValueIpScope=='subnet') {
                            command += ' scope=subnet';
                          }

                        }

                        firewallRulesList.add([ruleName, command]);
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'New rule is added.',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                      else {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Error validation! Check form.',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }

                    },
                    child: const Text(
                      'ADD NEW RULE',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );





  }
}
/*------------------Choose version MOffice-----------------*/
class OfficeSettingPage extends StatefulWidget {
  const OfficeSettingPage({super.key});
  static const routeName = '/OfficeSettingsPageAuto';
  @override
  State<OfficeSettingPage> createState() => _OfficeSettingPageState();
}

class _OfficeSettingPageState extends State<OfficeSettingPage> {

  // Enter the version of MS Office you want to harden (2003/2007/2010/2013/2016/365/none):
  List<DropdownMenuItem<String>> get modeListChoiceItemsVersion {
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
  String selectedValueVersion = '2003';
  String? selectedValueVersionOS;
  bool makeRestoreOffice = false;
  String mode = batParameters['Mode'];
  List<String> addonsList = ["Do you need to create the restore point before applying script?"];


  @override
  Widget build(BuildContext context) {

    batParameters['neededRestoreBackupMOffice'] = makeRestoreOffice;

    final screen =  MediaQuery.of(context).size;
    var screenWidth = screen.width;

    List<DropdownMenuItem<String>> osChoiceMenu = [];

    if (selectedValueVersion == '2003') {
      selectedValueVersionOS = 'xp';
      osChoiceMenu = [
        const DropdownMenuItem(value: "xp", child: Text("Windows XP")),
        const DropdownMenuItem(value: "vista", child: Text("Windows Vista"))
      ];
    }
    else if (selectedValueVersion == '2007' || selectedValueVersion == '2010') {
      selectedValueVersionOS = 'xp';
      osChoiceMenu = [
        const DropdownMenuItem(value: "xp", child: Text("Windows XP")),
        const DropdownMenuItem(value: "vista", child: Text("Windows Vista")),
        const DropdownMenuItem(value: "seven", child: Text("Windows 7")),
        const DropdownMenuItem(value: "eightzero", child: Text("Windows 8")),
        const DropdownMenuItem(value: "eightone", child: Text("Windows 8.1")),
        const DropdownMenuItem(value: "ten", child: Text("Windows 10")),
      ];
    }
    else if (selectedValueVersion == '2013' || selectedValueVersion == '2016') {
      selectedValueVersionOS = 'seven';
      osChoiceMenu = [
        const DropdownMenuItem(value: "seven", child: Text("Windows 7")),
        const DropdownMenuItem(value: "eightzero", child: Text("Windows 8")),
        const DropdownMenuItem(value: "eightone", child: Text("Windows 8.1")),
        const DropdownMenuItem(value: "ten", child: Text("Windows 10")),
        const DropdownMenuItem(value: "eleven", child: Text("Windows 11")),
      ];
    }
    else {
      selectedValueVersionOS = 'ten';
      osChoiceMenu = [
        const DropdownMenuItem(value: "ten", child: Text("Windows 10")),
        const DropdownMenuItem(value: "eleven", child: Text("Windows 11")),
      ];
    }

    return Scaffold(
        appBar: AppBar(),
    body: Center(
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Auto Mode MOffice hardening:',
                  style: TextStyle(
                    fontSize: 21,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Choose the version of MS Office you want to harden:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    validator: (value) => value == null ? "?" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValueVersion,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValueVersion = newValue!;
                        batParameters['SelectedValueVersionOffice'] = selectedValueVersion;
                      });
                    },
                    items: modeListChoiceItemsVersion),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Choose the operating system:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    // validator: (value) => value == null ? "?" : null,
                    dropdownColor: Colors.blueGrey,
                    value: selectedValueVersionOS,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValueVersionOS = newValue;
                        batParameters['SelectedValueVersionOSOffice'] = selectedValueVersionOS;
                      });
                    },
                    items: osChoiceMenu),
                  ),


              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: screenWidth * 0.45,
                  child: ListView(
                    shrinkWrap: true,
                    children: addonsList.map((option) => CheckboxListTile(
                      title: Text(option),
                      value: makeRestoreOffice,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 1),
                      onChanged: (bool? value) {
                        setState(() {
                          makeRestoreOffice = value!;
                          batParameters['neededRestoreBackupMOffice'] = makeRestoreOffice;

                        });
                      },
                    ),
                    ).toList(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {

                    if (batParameters['SelectedValueVersionOSOffice'] == null) {
                      batParameters['SelectedValueVersionOSOffice'] = selectedValueVersionOS;
                    }
                    if (batParameters['SelectedValueVersionOffice'] == null) {
                      batParameters['SelectedValueVersionOffice'] = selectedValueVersion;
                    }
                    batParameters['neededRestoreBackupMOffice'] = makeRestoreOffice;

                      try {

                        if (mode=='Auto') {
                          await generateBatFileOffice(batParameters);
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: const Text(
                                  'Your file is saved.',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black)),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(); // dismisses only the dialog and returns nothing
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          Navigator.pushNamed(context, '/');
                        }
                        else {
                          Navigator.pushNamed(context, '/ManualPage');
                        }

                    }
                      catch (error) {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                                'Some Error: $error',
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // dismisses only the dialog and returns nothing
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }

                  },
                  child: Text(
                    mode=='Auto' ? 'Make .bat-file!' : 'Next',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

            ]
          ),
      ),
    ),
  );
}
}
/*------------------Manual MAIN Page-----------------*/
class ManualPage extends StatefulWidget {
  const ManualPage({super.key});
  static const routeName = '/ManualPage';
  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {

  String hardeninType = batParameters['Hardenin'];
  List<String> isChoosingFeatureList = [];
  List paramsMap = [];

  static const listAddonsIE = ["Windows XP", "Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10"];
  static const listAddonsDefender = ["Windows Vista", "Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsBitlocker = ["Windows 7", "Windows 8", "Windows 8.1", "Windows 10", "Windows 11"];
  static const listAddonsEdge = ["Windows 10", "Windows 11"];
  static const listAddonsNextGenerationSecurity = ["Windows 10", "Windows 11"];

  Future<List> getData() async {
    if (paramsMap.isEmpty) {
      paramsMap = await returnHardeninParams(batParameters);
    }
    return paramsMap;
  }

  @override
  Widget build(BuildContext context) {

    ScrollController scrollControllerManualPage = ScrollController(initialScrollOffset: _keyControllerOffsetManualPage);
    final screen =  MediaQuery.of(context).size;
    var screenWidth = screen.width;
    return FutureBuilder(

        future: getData(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const Scaffold(body: SafeArea(child: Center(child: Text('ERROR'))));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          else {
            var itemsToList = snapshot.data!;

            if (currentListValuesSingleAddon.isEmpty) {
              currentListValuesSingleAddon = itemsToList[0];
            }
            return Scaffold(
              appBar: AppBar(
                actions: [
                  Row(
                    children: [
                      if (hardeninType != 'Microsoft Office') const Text('ADDONS: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 23,
                          )),
                      if (hardeninType != 'Microsoft Office') Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'Firewall';
                                    // batParameters['FirewallRules'] = [];
                                    // batParameters['ManualOptions_Firewall'] = [];
                                    Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                  });
                                },
                                icon: Icon(
                                  Icons.local_police,
                                  color: batParameters['ManualOptions_Firewall'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('FIREWALL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),
                      if (listAddonsIE.contains(hardeninType)) Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'IE';
                                    batParameters['Addons'] = ['IE'];
                                    batParameters['ManualOptions_IE'] = null;
                                    if (hardeninType == "Windows 8.1" || hardeninType == "Windows 10") {
                                      batParameters['VersionIE'] = 'ie11';
                                      Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                    }
                                    else {
                                      Navigator.of(context).pushNamed('/chooseIEPage').then((_) => setState(() {}));
                                    }
                                  });
                                },
                                icon: Icon(
                                  Icons.public,
                                  color: batParameters['ManualOptions_IE'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('IE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),
                      if (listAddonsDefender.contains(hardeninType)) Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'Defender';
                                    // batParameters['ManualOptions_Defender'] = [];
                                    Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                  });
                                },
                                icon: Icon(
                                  Icons.shield,
                                  color: batParameters['ManualOptions_Defender'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('DEFENDER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),
                      if (listAddonsBitlocker.contains(hardeninType)) Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'Bitlocker';
                                    // batParameters['ManualOptions_Bitlocker'] = [];
                                    Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                  });
                                },
                                icon: Icon(
                                  Icons.enhanced_encryption,
                                  color: batParameters['ManualOptions_Bitlocker'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('BITLOCKER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),
                      if (listAddonsEdge.contains(hardeninType)) Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'Edge';
                                    // batParameters['ManualOptions_Edge'] = [];
                                    Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                  });
                                },
                                icon: Icon(
                                  Icons.wifi_protected_setup,
                                  color: batParameters['ManualOptions_Edge'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('EDGE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),
                      if (listAddonsNextGenerationSecurity.contains(hardeninType)) Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    batParameters['SingleAddon'] = 'NextGenerationSecurity';
                                    // batParameters['ManualOptions_NextGenerationSecurity'] = [];
                                    Navigator.of(context).pushNamed('/finishHardeninSingleAddonPage').then((_) => setState(() {}));
                                  });
                                },
                                icon: Icon(
                                  Icons.backup,
                                  color: batParameters['ManualOptions_NextGenerationSecurity'] != null ? Colors.green : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              const Text('NEXTGEN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.normal,
                                    fontSize: 10,
                                  )),
                            ],
                          )
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text('ALL: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              fontSize: 23,
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isChoosingFeatureList = itemsToList.map((x) => x[0].toString()).toList();
                              });
                            },
                            icon: const Icon(
                              Icons.playlist_add_check,
                              size: 30,
                            ),
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isChoosingFeatureList = [];
                              });
                            },
                            icon: const Icon(
                              Icons.playlist_remove,
                              size: 30,
                            ),
                          )
                      ),
                    ],
                  )

                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: FloatingActionButton(
                // autoFocus: true,
                focusElevation: 5,
                isExtended: true,
                elevation: 40,
                tooltip: 'Make .bat',
                hoverElevation: 50,
                backgroundColor: Colors.blueGrey,
                onPressed: () async {

                  bool hasAddonsOptions = batParameters['ManualOptions_Firewall'] == null && batParameters['ManualOptions_IE'] == null && batParameters['ManualOptions_Defender'] == null && batParameters['ManualOptions_Bitlocker'] == null && batParameters['ManualOptions_Edge'] == null && batParameters['ManualOptions_NextGenerationSecurity'] == null;

                  if (isChoosingFeatureList.isEmpty && hasAddonsOptions) {

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text(
                            'Warning! No items for saving!',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black)),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(); // dismisses only the dialog and returns nothing
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                  }
                  else {

                    List mainListManualPage = [itemsToList, isChoosingFeatureList];
                    batParameters['mainListManualPage'] = mainListManualPage;
                    await generateBatFileOSManual(batParameters);

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text(
                            'Your file is saved.',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black)),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(); // dismisses only the dialog and returns nothing
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    Navigator.pushNamed(context, '/');


                  }
                },
                child: const Icon(Icons.save), // https://fonts.google.com/icons
              ),
              body: Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.65,
                    child: SingleChildScrollView(
                      controller: scrollControllerManualPage,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                child: ListView.builder(
                                    itemCount: itemsToList.length,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var currentItem = itemsToList[index];
                                      return Card(
                                        child: CheckboxListTile(
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${currentItem[1]}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),),
                                              Text('Value: ${currentItem[2]}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.italic
                                                ),),
                                            ],
                                          ),
                                          value: isChoosingFeatureList.contains(
                                              currentItem[0].toString()),
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              currentListValuesSingleAddon = currentItem;
                                              _keyControllerOffsetManualPage = scrollControllerManualPage.offset;
                                              if (value!) {
                                                isChoosingFeatureList.add(currentItem[0].toString());
                                              } else {
                                                isChoosingFeatureList.remove(currentItem[0].toString());
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1.0),
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: screenWidth * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText('Key: ${currentListValuesSingleAddon[1]}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic
                                ),
                              ),
                              SelectableText.rich(
                                TextSpan(
                                    style: const TextStyle(fontSize: 15),
                                    children: [
                                      TextSpan(text:'Value: ${currentListValuesSingleAddon[2]}\n',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.italic
                                        ),),
                                      TextSpan(text:'Type: ${currentListValuesSingleAddon[3]}\n',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.italic
                                        ),),
                                      TextSpan(text:'Parameter: ${currentListValuesSingleAddon[4]}\n',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.italic
                                        ),),
                                      const TextSpan(text:'\nDescription:\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          // fontStyle: FontStyle.italic
                                        ),),
                                      TextSpan(text: currentListValuesSingleAddon[5]),
                                    ]
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        }
    );
  }
}

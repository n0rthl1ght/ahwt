import 'dart:ffi' show DynamicLibrary;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqlite3/open.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ahwt_win/generate_bat.dart';
import 'package:ahwt_win/providers.dart';
import 'package:ahwt_win/utils.dart';

part 'pages/start_flow.dart';
part 'pages/auto_flow.dart';
part 'pages/manual_flow.dart';

// NOTES:
// https://github.com/go-flutter-desktop/go-flutter/issues/510  ==> icon on exe
//import 'package:provider/provider.dart';
// https://siro.hashnode.dev/setting-the-screen-size-of-your-flutter-desktop-app-at-startup

/* ---------------- Global Variables - not best practice :( ------------- */

Map<String, dynamic> batParameters = <String, dynamic>{};
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
List chooseManualPageItems = [];
final ValueNotifier<String> appLanguageNotifier = ValueNotifier<String>('ru');
final ValueNotifier<ThemeMode> appThemeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.dark);

bool get isRussianLanguage => appLanguageNotifier.value == 'ru';
bool get isDarkTheme => appThemeModeNotifier.value == ThemeMode.dark;

String tr(String englishText, String russianText) {
  return isRussianLanguage ? russianText : englishText;
}

Widget reactivePage(Widget Function(BuildContext context) builder) {
  return AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[
      appLanguageNotifier,
      appThemeModeNotifier,
    ]),
    builder: (context, _) => builder(context),
  );
}

Future<void> loadRuntimePreferences() async {
  final String? langPath = resolveOptionalRuntimeFile('lang.ini');
  if (langPath != null) {
    final String language = File(langPath).readAsStringSync().trim().toLowerCase();
    if (language.startsWith('rus')) {
      appLanguageNotifier.value = 'ru';
    } else if (language.startsWith('eng')) {
      appLanguageNotifier.value = 'en';
    }
  }

  final String? themePath = resolveOptionalRuntimeFile('theme.ini');
  if (themePath != null) {
    final String theme = File(themePath).readAsStringSync().trim().toLowerCase();
    if (theme == 'dark') {
      appThemeModeNotifier.value = ThemeMode.dark;
    } else if (theme == 'light') {
      appThemeModeNotifier.value = ThemeMode.light;
    }
  }
}

const List<String> manualAddonOptionKeys = <String>[
  'ManualOptions_Firewall',
  'ManualOptions_IE',
  'ManualOptions_Defender',
  'ManualOptions_Bitlocker',
  'ManualOptions_Edge',
  'ManualOptions_NextGenerationSecurity',
];

const List<String> manualAddonResetKeys = <String>[
  ...manualAddonOptionKeys,
  'ManualOptions_FirewallRulesList',
  'ManualOptions_Office',
];

bool hasSelectedManualAddonOptions(Map<String, dynamic> batParameters) {
  for (final key in manualAddonOptionKeys) {
    if (batParameters[key] != null) {
      return true;
    }
  }
  return false;
}

Widget buildSelectedRecordDetailsPane(double screenWidth) {
  final String descriptionEn = currentListValuesSingleAddon.length > 5
      ? currentListValuesSingleAddon[5].toString()
      : '-';
  final String descriptionRu = currentListValuesSingleAddon.length > 6
      ? currentListValuesSingleAddon[6].toString()
      : descriptionEn;
  final String activeDescription = isRussianLanguage ? descriptionRu : descriptionEn;

  return SingleChildScrollView(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: screenWidth * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '${tr('Key', 'Ключ')}: ${currentListValuesSingleAddon[1]}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SelectableText.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 15),
                  children: [
                    TextSpan(
                      text: '${tr('Value', 'Значение')}: ${currentListValuesSingleAddon[2]}\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '${tr('Type', 'Тип')}: ${currentListValuesSingleAddon[3]}\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '${tr('Parameter', 'Параметр')}: ${currentListValuesSingleAddon[4]}\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '\n${tr('Description', 'Описание')}:\n',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: activeDescription),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


/* ------------------------ MAIN CODE ------------------------ */

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('/lib/x86_64-linux-gnu/libsqlite3.so.0'),
    );
  }
  await windowManager.ensureInitialized();
  initializeRuntimePaths();
  await loadRuntimePreferences();
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, themeMode, __) {
        return ValueListenableBuilder<String>(
          valueListenable: appLanguageNotifier,
          builder: (context, _, __) {
        return MaterialApp(
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {

              case MyHomePage.routeName:
                return MaterialPageRoute(builder: (BuildContext context) {
                  return const MyHomePage(title: 'AHWT v.1.4');});

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
          title: 'AHWT v.1.4',
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A84A5),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF11161A),
            cardColor: const Color(0xFF1A2328),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF11161A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2D3439),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF4C5A63)),
              ),
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'AHWT v.1.4'),
        );
          },
        );
      },
    );
  }
}

import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:ahwt_win/generate_bat.dart' as generator;
import 'package:ahwt_win/main.dart';
import 'package:flutter/material.dart';
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
  });

  late Directory testOutputDir;

  setUp(() async {
    batParameters = <String, dynamic>{};
    currentListValuesSingleAddon = [];
    listAddonsManualPage = [];
    chooseManualPageItems = [];
    appLanguageNotifier.value = 'en';
    appThemeModeNotifier.value = ThemeMode.light;
    generator.assetRootDir = Directory.current.path;
    testOutputDir = await Directory.systemTemp.createTemp('ahwt_test_output_');
    generator.outputDir = testOutputDir.path;
  });

  tearDown(() async {
    if (testOutputDir.existsSync()) {
      await testOutputDir.delete(recursive: true);
    }
  });

  Future<void> pumpDesktopApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  Future<void> chooseDropdownValue(
    WidgetTester tester, {
    required String value,
    int dropdownIndex = 0,
  }) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(dropdownIndex));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Future<void> goToSetMode(
    WidgetTester tester, {
    required String hardening,
    required String fileName,
  }) async {
    await pumpDesktopApp(tester);
    await chooseDropdownValue(tester, value: hardening);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Selected hardening:'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), fileName);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Choose mode:'), findsOneWidget);
  }

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
  }

  Future<void> acknowledgeDialog(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
    await tester.pumpAndSettle();
  }

Future<void> triggerRealAsyncAction(
  WidgetTester tester,
  Finder finder, {
    Duration settleDelay = const Duration(seconds: 1),
  }) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await tester.pump();
      await Future<void>.delayed(settleDelay);
    });
    await tester.pumpAndSettle();
  }

  Future<void> waitForFileCreated(
    WidgetTester tester,
    File file, {
    int attempts = 20,
    Duration step = const Duration(milliseconds: 500),
  }) async {
    await tester.runAsync(() async {
      for (int i = 0; i < attempts; i++) {
        if (file.existsSync()) {
          return;
        }
        await Future<void>.delayed(step);
      }
    });
    await tester.pumpAndSettle();
  }

  testWidgets('MyApp renders the hardening entry screen', (
    WidgetTester tester,
  ) async {
    await pumpDesktopApp(tester);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Choose Hardening'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Windows flow reaches mode selection after filename input', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_mode_test',
    );

    expect(find.textContaining('Hardening: Windows 10'), findsOneWidget);
    expect(find.textContaining('Filename: widget_nav_mode_test.bat'), findsOneWidget);
  });

  test('Duplicate filename detection uses configured output directory', () async {
    final duplicateFile = File('${testOutputDir.path}${Platform.pathSeparator}duplicate_case.bat');
    await duplicateFile.writeAsString('existing');

    expect(generator.outputBatFileExists('duplicate_case'), isTrue);
    expect(generator.outputBatFileExists('duplicate_case.bat'), isTrue);
    expect(generator.outputBatFileExists('missing_case'), isFalse);
  });

  testWidgets('Auto flow reaches addons selection screen', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_auto_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);

    expect(find.text('Choose Level Auto Mode:'), findsOneWidget);
    await tapNext(tester);

    expect(find.text('Choose mode:'), findsOneWidget);
    expect(find.text('Firewall'), findsOneWidget);
    expect(find.text('IE'), findsOneWidget);
  });

  testWidgets('Addon flow reaches single addon selection screen', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_addon_test',
    );

    await chooseDropdownValue(tester, value: 'Addon');
    await tapNext(tester);

    expect(find.text('Choose Addon:'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.textContaining('Mode: Addon'), findsOneWidget);
  });

  testWidgets('Microsoft Office flow reaches office settings screen', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Microsoft Office',
      fileName: 'widget_nav_office_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);

    expect(find.text('MS Office hardening settings:'), findsOneWidget);
    expect(
      find.text('Choose the version of MS Office you want to harden:'),
      findsOneWidget,
    );
    expect(find.text('Choose the operating system:'), findsOneWidget);
  });

  testWidgets('Auto flow saves bat file successfully', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_auto_save_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);
    await tapNext(tester);
    await tapNext(tester);

    expect(find.text('Current config:'), findsOneWidget);
    await triggerRealAsyncAction(
      tester,
      find.widgetWithText(ElevatedButton, 'Make .bat-file!'),
      settleDelay: const Duration(seconds: 2),
    );

    final File generatedFile = File(
      '${testOutputDir.path}${Platform.pathSeparator}widget_auto_save_test.bat',
    );
    await waitForFileCreated(tester, generatedFile);

    expect(
      generatedFile.existsSync(),
      isTrue,
    );
    expect(find.textContaining('Some Error:'), findsNothing);
    if (find.text('Your file is saved.').evaluate().isNotEmpty) {
      await acknowledgeDialog(tester);
    }
  });

  testWidgets('Auto firewall flow reaches ShieldUp screen', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_shieldup_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);
    await tapNext(tester);

    await tester.tap(find.text('Firewall'));
    await tester.pumpAndSettle();
    await tapNext(tester);

    expect(find.text('Enable ShieldUp Mode?'), findsOneWidget);
    expect(find.textContaining('Mode: Auto'), findsOneWidget);
  });

  testWidgets('Windows 7 auto IE flow reaches IE chooser and ShieldUp', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 7',
      fileName: 'widget_nav_ie_auto_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);
    await tapNext(tester);

    await tester.tap(find.text('IE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Firewall'));
    await tester.pumpAndSettle();
    await tapNext(tester);

    expect(find.text('Choose IE Version:'), findsOneWidget);
    await chooseDropdownValue(tester, value: 'ie11');
    await tapNext(tester);

    expect(find.text('Enable ShieldUp Mode?'), findsOneWidget);
    expect(find.textContaining('Hardening: Windows 7'), findsOneWidget);
  });

  testWidgets('Windows 10 addon IE flow reaches single addon finish page', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_ie_addon_test',
    );

    await chooseDropdownValue(tester, value: 'Addon');
    await tapNext(tester);

    expect(find.text('Choose Addon:'), findsOneWidget);
    await chooseDropdownValue(tester, value: 'IE');
    await tapNext(tester);

    expect(find.byType(CheckboxListTile), findsWidgets);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('Office auto flow saves bat file successfully', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Microsoft Office',
      fileName: 'widget_office_save_test',
    );

    await chooseDropdownValue(tester, value: 'Auto');
    await tapNext(tester);

    await triggerRealAsyncAction(
      tester,
      find.widgetWithText(ElevatedButton, 'Make .bat-file!'),
      settleDelay: const Duration(seconds: 2),
    );

    final File generatedFile = File(
      '${testOutputDir.path}${Platform.pathSeparator}widget_office_save_test.bat',
    );
    await waitForFileCreated(tester, generatedFile);

    expect(
      generatedFile.existsSync(),
      isTrue,
    );
    expect(find.textContaining('Some Error:'), findsNothing);
    if (find.text('Your file is saved.').evaluate().isNotEmpty) {
      await acknowledgeDialog(tester);
    }
  });

  testWidgets('Office manual flow reaches manual hardening page', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Microsoft Office',
      fileName: 'widget_office_manual_test',
    );

    await chooseDropdownValue(tester, value: 'Manual');
    await tapNext(tester);

    expect(find.text('MS Office hardening settings:'), findsOneWidget);
    await tapNext(tester);

    expect(find.byType(CheckboxListTile), findsWidgets);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('Windows 10 firewall addon opens firewall rule form', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_firewall_addon_test',
    );

    await chooseDropdownValue(tester, value: 'Addon');
    await tapNext(tester);
    await tapNext(tester);

    expect(find.byType(CheckboxListTile), findsWidgets);
    await tester.tap(find.byIcon(Icons.queue));
    await tester.pumpAndSettle();

    expect(find.textContaining('Adding new Firewall Rule'), findsOneWidget);
    expect(find.text('Specify the action direction:'), findsOneWidget);
    expect(find.text('ADD NEW RULE'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'ADD NEW RULE'));
    await tester.pumpAndSettle();

    expect(find.text('New rule is added.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('Windows XP firewall addon opens XP firewall rule form', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows XP',
      fileName: 'widget_nav_firewall_xp_test',
    );

    await chooseDropdownValue(tester, value: 'Addon');
    await tapNext(tester);
    await tapNext(tester);

    expect(find.byType(CheckboxListTile), findsWidgets);
    await tester.tap(find.byIcon(Icons.queue));
    await tester.pumpAndSettle();

    expect(find.textContaining('Adding new XP Firewall Rule'), findsOneWidget);
    expect(find.text('What will be added - port or program?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '80');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'ADD NEW RULE'));
    await tester.pumpAndSettle();

    expect(find.text('New rule is added.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('Manual flow reaches manual hardening page', (
    WidgetTester tester,
  ) async {
    await goToSetMode(
      tester,
      hardening: 'Windows 10',
      fileName: 'widget_nav_manual_test',
    );

    await chooseDropdownValue(tester, value: 'Manual');
    await tapNext(tester);

    expect(find.byType(CheckboxListTile), findsWidgets);
    expect(find.text('ADDONS: '), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });
}

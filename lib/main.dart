import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _currentLanguage = 'en';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _currentLanguage = await LanguageManager.getLanguage();
    runApp(const AppRestarter(child: MyApp()));
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
  });
}


class AppRestarter extends StatefulWidget {
  final Widget child;

  const AppRestarter({super.key, required this.child});

  static restartApp(BuildContext context) {
    final AppRestarterState state =
        context.findAncestorStateOfType<AppRestarterState>()!;
    state.restartApp();
  }

  @override
  AppRestarterState createState() => AppRestarterState();
}

class AppRestarterState extends State<AppRestarter> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(_currentLanguage),
      home: const LanguageSelectionScreen(),
    );
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  LanguageSelectionScreenState createState() => LanguageSelectionScreenState();
}

class LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  var methodChannel = const MethodChannel("shokal");

  @override
  initState(){
    super.initState();
    callNativeCode(_currentLanguage);
  }
  Future<String> callNativeCode(String languageCode) async {
    debugPrint("Language Code: $languageCode");
    try {
      var data = await methodChannel
          .invokeMethod('languageFunction', {"languageCode": languageCode});
      return data;
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  Future<String> showNativeView() async {
    try {
      var data = await methodChannel.invokeMethod('messageFunction');
      return data;
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _currentLanguage,
              onChanged: (String? value) {
                callNativeCode('en');
                setState(() {
                  _currentLanguage = value!;
                });
                LanguageManager.setLanguage(value!);
                AppRestarter.restartApp(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Japanese'),
              value: 'ja',
              groupValue: _currentLanguage,
              onChanged: (String? value) {
                callNativeCode('ja');
                setState(() {
                  _currentLanguage = value!;
                });
                LanguageManager.setLanguage(value!);
                AppRestarter.restartApp(context);
              },
            ),
            ElevatedButton(
              onPressed: showNativeView,
              child: Text(AppLocalizations.of(context).btn1),
            ),
            Text(
              AppLocalizations.of(context).title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              AppLocalizations.of(context)
                  .screen_one_text("Solaiman", "Shokal", 12),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageManager {
  static Future<void> setLanguage(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Utils.kLanguagePreferenceKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(Utils.kLanguagePreferenceKey);
    return languageCode ?? 'en'; // Default language is English
  }
}

class Utils {
  static const String kLanguagePreferenceKey = 'language_preference';
}

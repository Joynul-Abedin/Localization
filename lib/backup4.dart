import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const RestartWidget(
        child:  MyApp()
    ),
  );
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, this.child});

  final Widget? child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<StatefulWidget> createState() {
    return _RestartWidgetState();
  }
}

class _RestartWidgetState extends State<RestartWidget> {
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
      child: widget.child ?? Container(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}


class MyAppState extends State<MyApp> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    LanguageManager.getLanguage().then((lang) {
      setState(() {
        _currentLanguage = lang;
      });
    });
  }

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
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  LanguageSelectionScreenState createState() =>
      LanguageSelectionScreenState();
}

class LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _currentLanguage = 'en';
  var methodChannel = const MethodChannel("shokal");

  Future<String> callNativeCode(String languageCode) async {
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
  void initState() {
    super.initState();
    LanguageManager.getLanguage().then((lang) {
      setState(() {
        _currentLanguage = lang;
      });
    });
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
                RestartWidget.restartApp(context);
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
                RestartWidget.restartApp(context);
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

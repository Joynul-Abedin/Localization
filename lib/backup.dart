import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _currentLanguage = LanguageManager.getLanguage().toString();
    debugPrint("Current Language: $_currentLanguage");
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _currentLanguage = languageCode;
      LanguageManager.setLanguage(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.deepPurple,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(_currentLanguage),
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            LanguageManager.setLanguage(locale!.languageCode);
            return supportedLocale;
          }
        }
        LanguageManager.setLanguage(supportedLocales.first.languageCode);
        return supportedLocales.first;
      },
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final ValueChanged<String> onLanguageChanged;

  const MyHomePage({Key? key, required this.title, required this.onLanguageChanged}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedLanguage = 'en';
  var methodChannel = const MethodChannel("shokal");

  Future<String> callNativeCode() async {
    try {
      var data =
      await methodChannel.invokeMethod('languageFunction', {"languageCode": _selectedLanguage});
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
    _selectedLanguage = LanguageManager.getLanguage().toString();
  }

  void _handleLanguageChange(String? languageCode) {
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
        LanguageManager.setLanguage(languageCode);
        widget.onLanguageChanged(languageCode);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged:(String? value) {
                _handleLanguageChange(value);
                callNativeCode();
              },
            ),
            RadioListTile(
              title: const Text('Japanese'),
              value: 'ja',
              groupValue: _selectedLanguage,
              onChanged:(String? value) {
                _handleLanguageChange(value);
                callNativeCode();
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
              AppLocalizations.of(context).screen_one_text("Solaiman", "Shokal", 12),
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

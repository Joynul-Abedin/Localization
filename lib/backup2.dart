import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageManager(),
      child: Consumer<LanguageManager>(
        builder: (context, languageManager, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.deepPurple,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(languageManager.currentLanguage),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  Widget build(BuildContext context) {
    var languageManager = Provider.of<LanguageManager>(context);
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
              groupValue: languageManager.currentLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  languageManager.changeLanguage(value);
                  callNativeCode(value);
                }
              },
            ),
            RadioListTile(
              title: const Text('Japanese'),
              value: 'ja',
              groupValue: languageManager.currentLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  languageManager.changeLanguage(value);
                  callNativeCode(value);
                }
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

class LanguageManager extends ChangeNotifier {
  String _currentLanguage = 'en';

  LanguageManager() {
    getLanguage();
  }

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    setLanguage(languageCode);
    notifyListeners();
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(Utils.kLanguagePreferenceKey);
    _currentLanguage = languageCode ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Utils.kLanguagePreferenceKey, languageCode);
  }
}

class Utils {
  static const String kLanguagePreferenceKey = 'language_preference';
}

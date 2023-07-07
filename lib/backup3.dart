import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageBloc(),
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
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
            locale: Locale(state.languageCode),
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
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
              groupValue: BlocProvider.of<LanguageBloc>(context).state.languageCode,
              onChanged: (String? value) {
                if (value != null) {
                  BlocProvider.of<LanguageBloc>(context).add(ChangeLanguageEvent(value));
                  callNativeCode(value);
                }
              },
            ),
            RadioListTile(
              title: const Text('Japanese'),
              value: 'ja',
              groupValue: BlocProvider.of<LanguageBloc>(context).state.languageCode,
              onChanged: (String? value) {
                if (value != null) {
                  BlocProvider.of<LanguageBloc>(context).add(ChangeLanguageEvent(value));
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

class LanguageState {
  final String languageCode;

  LanguageState(this.languageCode);
}

class ChangeLanguageEvent {
  final String languageCode;

  ChangeLanguageEvent(this.languageCode);
}

class LanguageBloc extends Bloc<ChangeLanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageState('en')) {
    on<ChangeLanguageEvent>(_onLanguageChanged);
    getLanguage();
  }

  void _onLanguageChanged(ChangeLanguageEvent event, Emitter<LanguageState> emit) async {
    final newLanguageCode = event.languageCode;
    await setLanguage(newLanguageCode);
    emit(LanguageState(newLanguageCode));
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(Utils.kLanguagePreferenceKey);
    add(ChangeLanguageEvent(languageCode ?? 'en'));
  }

  Future<void> setLanguage(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Utils.kLanguagePreferenceKey, languageCode);
  }
}


class Utils {
  static const String kLanguagePreferenceKey = 'language_preference';
}

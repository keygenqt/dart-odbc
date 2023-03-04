import 'package:settings_yaml/settings_yaml.dart';

/// Read file yaml with configuration app
class Configuration {
  static final Map<String, dynamic> _data =
      SettingsYaml.load(pathToSettings: './configuration.yaml').valueMap;

  static String driver = _data['driver']!.toString();
  static String username = _data['username']!.toString();
  static String password = _data['password']!.toString();
}

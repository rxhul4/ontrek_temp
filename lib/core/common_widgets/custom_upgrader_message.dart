import 'package:upgrader/upgrader.dart';

class CustomUpgraderMessage extends UpgraderMessages {
  @override
  String get prompt => "";

  @override
  String get title => "Update Alert";

  @override
  String get body =>
      "We've just released a new update for our app and we need you to download it! This update includes some great new features and improvements, as well as bug fixes and stability enhancements. So please, install the update and enjoy the best experience.";
}

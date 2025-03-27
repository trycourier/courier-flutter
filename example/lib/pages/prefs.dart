import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter_sample/pages/prefs_custom.dart';
import 'package:courier_flutter_sample/theme.dart';
import 'package:flutter/material.dart';

class PrefsPage extends StatefulWidget {
  const PrefsPage({super.key});

  @override
  State<PrefsPage> createState() => _PrefsPageState();
}

class _PrefsPageState extends State<PrefsPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final customTheme = CourierPreferencesTheme(
    topicSeparator: null,
    sectionTitleStyle: AppTheme.sectionText,
    topicTitleStyle: AppTheme.titleText,
    topicSubtitleStyle: AppTheme.bodyText,
    topicTrailing: const Icon(
      Icons.edit_outlined,
      color: AppTheme.secondaryColor,
    ),
    sheetSeparator: null,
    sheetTitleStyle: AppTheme.sectionText,
    sheetSettingStyles: SheetSettingStyles(
      textStyle: AppTheme.titleText,
      activeTrackColor: AppTheme.primaryColor,
      activeThumbColor: AppTheme.lightColor,
      inactiveTrackColor: AppTheme.secondaryColor,
      inactiveThumbColor: AppTheme.lightColor,
    ),
    sheetShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16.0),
      ),
    ),
    infoViewStyle: CourierInfoViewStyle(
      textStyle: AppTheme.titleText,
      buttonStyle: AppTheme.buttonStyle,
    ),
  );

  late final Map<String, Widget> pages = {
    'Default': CourierPreferences(
      keepAlive: true,
      mode: TopicMode(),
    ),
    'Styled': CourierPreferences(
      keepAlive: true,
      showCourierFooter: false,
      lightTheme: customTheme,
      darkTheme: customTheme,
      mode: ChannelsMode(channels: [CourierUserPreferencesChannel.push, CourierUserPreferencesChannel.sms, CourierUserPreferencesChannel.email]),
      onError: (error) {
        print(error);
         return 'You can now pass a custom error message here if you want to.';
      },
    ),
    'Custom': const CustomPrefsPage(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        bottom: TabBar(
          controller: _tabController,
          tabs: pages.keys.map((String title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: pages.values.toList(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter_sample/env.dart';
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
    brandId: Env.brandId,
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
      lightTheme: customTheme,
      darkTheme: customTheme,
      mode: ChannelsMode(channels: [CourierUserPreferencesChannel.push, CourierUserPreferencesChannel.sms, CourierUserPreferencesChannel.email]),
      onError: (error) => print(error),
    ),
    // 'Custom': Container(
    //   color: Colors.red,
    // ),
  };

  // CourierUserPreferences? _preferences;
  // String? _error;
  // bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
  }

  // Future<void> _start() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final preferences = await Courier.shared.getUserPreferences();
  //     setState(() {
  //       _error = null;
  //       _isLoading = false;
  //       _preferences = preferences;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //       _preferences = null;
  //     });
  //   }
  // }
  //
  // Future<void> _refresh() async {
  //   return _start();
  // }
  //
  // List<CourierUserPreferencesChannel> _getRandomChannels() {
  //   List<CourierUserPreferencesChannel> channelValues = [
  //     CourierUserPreferencesChannel.directMessage,
  //     CourierUserPreferencesChannel.email,
  //     CourierUserPreferencesChannel.push,
  //     CourierUserPreferencesChannel.sms,
  //     CourierUserPreferencesChannel.webhook,
  //   ];
  //
  //   Random random = Random();
  //   int randomCount = random.nextInt(channelValues.length + 1);
  //   List<CourierUserPreferencesChannel> randomChannels = [];
  //
  //   while (randomChannels.length < randomCount) {
  //     CourierUserPreferencesChannel randomChannel = channelValues[random.nextInt(channelValues.length)];
  //     if (!randomChannels.contains(randomChannel)) {
  //       randomChannels.add(randomChannel);
  //     }
  //   }
  //
  //   return randomChannels;
  // }

  // Future<void> _updateTopic(BuildContext context, String topicId) async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     final topic = await Courier.shared.getUserPreferencesTopic(topicId: topicId);
  //
  //     await Courier.shared.putUserPreferencesTopic(
  //       topicId: topic.topicId,
  //       status: CourierUserPreferencesStatus.optedIn,
  //       hasCustomRouting: true,
  //       customRouting: _getRandomChannels(),
  //     );
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     rethrow;
  //   }
  // }

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

// Widget _buildContent(BuildContext buildContext) {
//   if (_isLoading) {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }
//
//   if (_error != null) {
//     return Center(
//       child: Text(_error!),
//     );
//   }
//
//   return RefreshIndicator(
//     onRefresh: _refresh,
//     child: Scrollbar(
//       child: ListView.separated(
//         separatorBuilder: (context, index) => const Divider(),
//         itemCount: _preferences?.items.length ?? 0,
//         itemBuilder: (BuildContext context, int index) {
//           final topic = _preferences!.items[index];
//           return InkWell(
//             onTap: () {
//               _updateTopic(context, topic.topicId).catchError((error) {
//                 showAlert(buildContext, "Error Updating Preferences", error.toString());
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 topic.toJson(),
//                 style: GoogleFonts.robotoMono(fontSize: 16.0),
//               ),
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Preferences'),
//     ),
//     body: _buildContent(context),
//   );
// }
}

// extension TopicExtension on CourierUserPreferencesTopic {
//   String toJson() => jsonEncode({
//         'topicId': topicId,
//         'topicName': topicName,
//         'status': status.value,
//         'hasCustomRouting': hasCustomRouting,
//         'defaultStatus': defaultStatus.value,
//         'customRouting': customRouting.map((e) => e.value).join(", "),
//       });
// }

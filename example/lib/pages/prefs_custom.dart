import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:courier_flutter_sample/pages/pref_detail.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class CustomPrefsPage extends StatefulWidget {
  const CustomPrefsPage({super.key});

  @override
  State<CustomPrefsPage> createState() => _CustomPrefsPageState();
}

class _CustomPrefsPageState extends State<CustomPrefsPage> with AutomaticKeepAliveClientMixin {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  CourierUserPreferences? _preferences;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {

    _refreshIndicatorKey.currentState?.show();

    try {
      final preferences = await Courier.shared.getUserPreferences();
      setState(() {
        _error = null;
        _preferences = preferences;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _preferences = null;
      });
    }

  }

  Future<void> _refresh() async {
    return _start();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_error != null) {
      return Center(
        child: Text(_error!),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _preferences?.items.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            final topic = _preferences!.items[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreferencesDetailPage(
                      topicId: topic.topicId,
                      onSave: () {
                        _start();
                      },
                    ),
                  ),
                );
              },
              subtitle: Text(
                // topic.toJson(),
                "TODO",
                style: GoogleFonts.robotoMono(),
              ),
            );
          },
        ),
      ),
    );

  }
}

// extension TopicExtension on CourierUserPreferencesTopic {
//   String toJson() {
//     var jsonObject = {
//       'topicId': topicId,
//       'topicName': topicName,
//       'sectionName': sectionName,
//       'sectionId': sectionId,
//       'status': status.value,
//       'hasCustomRouting': hasCustomRouting,
//       'defaultStatus': defaultStatus.value,
//       'customRouting': customRouting.map((e) => e.value).join(", "),
//     };
//
//     var encoder = const JsonEncoder.withIndent('  ');
//     return encoder.convert(jsonObject);
//   }
// }

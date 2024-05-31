import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences_section.dart';
import 'package:courier_flutter/preferences/courier_preferences_sheet.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Mode {}

class TopicMode extends Mode {}

class ChannelsMode extends Mode {
  final List<CourierUserPreferencesChannel> channels;
  ChannelsMode({required this.channels});
}

class CourierPreferences extends StatefulWidget {
  // Useful if you are placing your Inbox in a TabView or another widget that will recycle
  final bool keepAlive;

  // The theming for your Inbox
  final Mode mode;
  final CourierPreferencesTheme _lightTheme;
  final CourierPreferencesTheme _darkTheme;

  // Scroll handling
  final ScrollController? scrollController;

  CourierPreferences({
    super.key,
    this.keepAlive = false,
    Mode? mode,
    CourierPreferencesTheme? lightTheme,
    CourierPreferencesTheme? darkTheme,
    this.scrollController,
  }) : mode = mode ?? ChannelsMode(channels: CourierUserPreferencesChannel.allCases),
      _lightTheme = lightTheme ?? CourierPreferencesTheme(),
      _darkTheme = darkTheme ?? CourierPreferencesTheme();

  @override
  CourierInboxState createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierPreferences> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();

  bool _isLoading = true;
  String? _error;
  List<PreferenceSection> _sections = [];

  CourierBrand? _brand;
  String? _userId;

  @override
  void initState() {
    super.initState();

    // Ensure widget is mounted
    if (mounted) {
      _retry();
    }
  }

  Future<void> _getPreferences() async {

    final userId = await Courier.shared.userId;

    final brand = await _refreshBrand();

    try {

      final preferences = await Courier.shared.getUserPreferences();

      List<PreferenceSection> sections = [];

      for (var topic in preferences.items) {

        String sectionId = topic.sectionId;

        // Add the item to the proper section
        int sectionIndex = sections.indexWhere((section) => section.id == sectionId);

        if (sectionIndex != -1) {

          sections[sectionIndex].topics.add(topic);

        } else {

          PreferenceSection newSection = PreferenceSection(
            title: topic.sectionName,
            id: topic.sectionId,
            topics: [topic],
          );

          sections.add(newSection);

        }

      }

      setState(() {
        _userId = userId;
        _brand = brand;
        _sections = sections;
        _isLoading = false;
        _error = null;
      });

    } catch (error) {

      setState(() {
        _userId = userId;
        _brand = brand;
        _sections = [];
        _isLoading = false;
        _error = error.toString();
      });

    }

  }

  Future<CourierBrand?> _refreshBrand() async {

    if (!mounted) return null;

    // Get the theme
    Brightness currentBrightness = PlatformDispatcher.instance.platformBrightness;
    final brandId = currentBrightness == Brightness.dark ? widget._darkTheme.brandId : widget._lightTheme.brandId;

    if (brandId == null) {
      widget._lightTheme.brand = null;
      widget._darkTheme.brand = null;
      return null;
    }

    // Get / set the brand
    CourierBrand? brand = await Courier.shared.getBrand(id: brandId);
    widget._lightTheme.brand = brand;
    widget._darkTheme.brand = brand;
    return brand;

  }

  Future<void> _retry() async {

    final userId = await Courier.shared.userId;

    setState(() {
      _userId = userId;
      _sections = [];
      _isLoading = true;
      _error = null;
    });

    await _getPreferences();

  }

  int get _itemCount => _sections.length;

  CourierPreferencesTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  void _showTopicSheet(BuildContext context, bool isDarkMode, CourierUserPreferencesTopic topic) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CourierPreferencesSheet(
          mode: widget.mode,
          theme: getTheme(isDarkMode),
          topic: topic,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isDarkMode) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: getTheme(isDarkMode).getLoadingColor(context),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
              _userId == null ? 'No User Found' : _error!,
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              style: getTheme(isDarkMode).getInfoViewButtonStyle(context),
              onPressed: () => _retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sections.isEmpty) {
      return Center(
        child: Text(
          style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
          'No preferences found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: getTheme(isDarkMode).getLoadingColor(context),
            onRefresh: _getPreferences,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                separatorBuilder: (context, index) => getTheme(isDarkMode).separator ?? const SizedBox(),
                itemCount: _itemCount,
                itemBuilder: (BuildContext context, int index) {
                  return CourierPreferencesSection(
                    theme: getTheme(isDarkMode),
                    section: _sections[index],
                    onTopicClick: (topic) => _showTopicSheet(context, isDarkMode, topic),
                  );
                },
              ),
            ),
          ),
        ),
        CourierFooter(shouldShow: _brand?.settings?.inapp?.showCourierFooter ?? true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRect(
      child: CourierThemeBuilder(builder: (context, constraints, isDarkMode) {
        return _buildContent(context, isDarkMode);
      }),
    );
  }

  @override
  void dispose() {
    // Dispose the default controller
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }
}

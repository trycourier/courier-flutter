import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/inbox/courier_inbox_builder.dart';
import 'package:courier_flutter/inbox/watermark.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences_list_item.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CourierPreferences extends StatefulWidget {
  // Useful if you are placing your Inbox in a TabView or another widget that will recycle
  final bool keepAlive;

  // The theming for your Inbox
  final CourierPreferencesTheme _lightTheme;
  final CourierPreferencesTheme _darkTheme;

  // Scroll handling
  final ScrollController? scrollController;

  CourierPreferences({
    super.key,
    this.keepAlive = false,
    CourierPreferencesTheme? lightTheme,
    CourierPreferencesTheme? darkTheme,
    this.scrollController,
  })  : _lightTheme = lightTheme ?? CourierPreferencesTheme(),
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
  List<CourierUserPreferencesTopic> _topics = [];

  CourierBrand? _brand;
  String? _userId;

  @override
  void initState() {
    super.initState();

    // Ensure widget is mounted
    if (mounted) {
      _start();
    }
  }

  Future _start() async {

    final userId = await Courier.shared.userId;

    setState(() {
      _userId = userId;
      _topics = [];
      _isLoading = true;
      _error = null;
    });

    final brand = await _refreshBrand();

    try {

      final preferences = await Courier.shared.getUserPreferences();

      setState(() {
        _userId = userId;
        _brand = brand;
        _topics = preferences.items;
        _isLoading = false;
        _error = null;
      });

    } catch (error) {

      setState(() {
        _userId = userId;
        _brand = brand;
        _topics = [];
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

    CourierBrand? brand;

    // Get the brand
    if (brandId != null) {
      brand = await Courier.shared.getBrand(id: brandId);
    }

    // Set the theme brand
    widget._lightTheme.brand = brand;
    widget._darkTheme.brand = brand;

    return brand;
  }

  Future<void> _refresh() async {
    await Courier.shared.refreshInbox();
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _refreshBrand();
    await Courier.shared.refreshInbox();
  }

  int get _itemCount => _topics.length;

  CourierPreferencesTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  void _showTopicSheet(BuildContext context, CourierUserPreferencesTopic topic) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  jsonEncode({
                    'topicId': topic.topicId,
                    'topicName': topic.topicName,
                    'sectionName': topic.sectionName,
                    'sectionId': topic.sectionId,
                  }),
                  style: const TextStyle(
                    fontFamily: 'Courier',
                  ),
                ),
              )
            ],
          ),
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

    if (_topics.isEmpty) {
      return Center(
        child: Text(
          style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
          'No topics found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: getTheme(isDarkMode).getLoadingColor(context),
            onRefresh: _refresh,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                separatorBuilder: (context, index) => getTheme(isDarkMode).separator ?? const SizedBox(),
                itemCount: _itemCount,
                itemBuilder: (BuildContext context, int index) {
                  return CourierPreferencesListItem(
                    theme: getTheme(isDarkMode),
                    topic: _topics[index],
                    onTopicClick: (topic) => _showTopicSheet(context, topic),
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
      child: CourierInboxBuilder(builder: (context, constraints, isDarkMode) {
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

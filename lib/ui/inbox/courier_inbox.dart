import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'courier_inbox_list_item.dart';

class CourierInbox extends StatefulWidget {

  // Useful if you are placing your Inbox in a TabView or another widget that will recycle
  final bool keepAlive;

  // The theming for your Inbox
  final CourierInboxTheme _lightTheme;
  final CourierInboxTheme _darkTheme;

  // Actions
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxAction, InboxMessage, int)? onActionClick;

  // Scroll handling
  final ScrollController? scrollController;

  CourierInbox({
    super.key,
    this.keepAlive = false,
    CourierInboxTheme? lightTheme,
    CourierInboxTheme? darkTheme,
    this.scrollController,
    this.onMessageClick,
    this.onActionClick,
  })  : _lightTheme = lightTheme ?? CourierInboxTheme(),
        _darkTheme = darkTheme ?? CourierInboxTheme();

  @override
  CourierInboxState createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();
  CourierInboxListener? _inboxListener;

  bool _isLoading = true;
  String? _error;
  List<InboxMessage> _messages = [];
  bool _canPaginate = false;

  double _triggerPoint = 0;

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

  void _scrollListener() {
    // Trigger the pagination
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - _triggerPoint) {
      Courier.shared.fetchNextPageOfMessages();
    }
  }

  Future _start() async {

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Attach scroll listener
    _scrollController.addListener(_scrollListener);

    // Get the brand if needed
    final brand = await _refreshBrand();

    // Attach inbox message listener
    _inboxListener = await Courier.shared.addInboxListener(
      onInitialLoad: () async {
        final userId = await Courier.shared.userId;
        setState(() {
          _userId = userId;
          _brand = brand;
          _isLoading = true;
          _error = null;
        });
      },
      onError: (error) async {
        final userId = await Courier.shared.userId;
        setState(() {
          _userId = userId;
          _brand = brand;
          _isLoading = false;
          _error = error;
        });
      },
      onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) async {
        final userId = await Courier.shared.userId;
        setState(() {
          _userId = userId;
          _brand = brand;
          _messages = messages;
          _isLoading = false;
          _error = null;
          _canPaginate = canPaginate;
        });
      },
    );
  }

  Future<CourierBrand?> _refreshBrand() async {

    if (!mounted) return null;

    try {

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

    } catch (error) {

      Courier.log(error.toString());

      widget._lightTheme.brand = null;
      widget._darkTheme.brand = null;
      return null;

    }

  }

  Future<void> _refresh() async {
    await _refreshBrand();
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

  int get _itemCount => _messages.length + (_canPaginate ? 1 : 0);

  CourierInboxTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
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

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
          'No message found',
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
                  if (index <= _messages.length - 1) {
                    final message = _messages[index];
                    return CourierInboxListItem(
                      theme: getTheme(isDarkMode),
                      message: message,
                      onMessageClick: (message) {
                        message.markAsClicked();
                        widget.onMessageClick != null ? widget.onMessageClick!(message, index) : null;
                      },
                      onActionClick: (action) => widget.onActionClick != null ? widget.onActionClick!(action, message, index) : null,
                    );
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 24, bottom: _triggerPoint),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(getTheme(isDarkMode).getLoadingColor(context)),
                          ),
                        ),
                      ),
                    );
                  }
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
        _triggerPoint = constraints.maxHeight / 2;
        return _buildContent(context, isDarkMode);
      }),
    );
  }

  @override
  void dispose() {

    // Remove the listeners
    _inboxListener?.remove();
    _scrollController.removeListener(_scrollListener);

    // Dispose the default controller
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();

  }
}

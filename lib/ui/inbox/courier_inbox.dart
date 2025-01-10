import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_pagination_item.dart';
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
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;

  // Scroll handling
  final ScrollController feedScrollController;
  final ScrollController archivedScrollController;

  // Swipe behavior
  final bool canSwipePages;

  CourierInbox({
    super.key,
    this.keepAlive = false,
    CourierInboxTheme? lightTheme,
    CourierInboxTheme? darkTheme,
    ScrollController? feedScrollController,
    ScrollController? archivedScrollController,
    this.onMessageClick,
    this.onMessageLongPress,
    this.onActionClick,
    this.canSwipePages = false,
  })  : _lightTheme = lightTheme ?? CourierInboxTheme(),
        _darkTheme = darkTheme ?? CourierInboxTheme(),
        feedScrollController = feedScrollController ?? ScrollController(),
        archivedScrollController = archivedScrollController ?? ScrollController();

  @override
  State<CourierInbox> createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  CourierInboxListener? _inboxListener;
  List<InboxMessage> _feedMessages = [];
  List<InboxMessage> _archivedMessages = [];
  bool _canPaginateFeed = false;
  bool _canPaginateArchived = false;
  bool _isFeedPaginating = false;
  bool _isArchivedPaginating = false;
  bool _isLoading = true;
  String? _error;
  CourierBrand? _brand;
  late TabController _tabController;
  late PageController _pageController;
  int _lastSelectedTab = 0;
  
  // Map to store list item states at the top level
  final Map<InboxFeed, GlobalKey<_CourierMessageListState>> _listKeys = {
    InboxFeed.feed: GlobalKey<_CourierMessageListState>(),
    InboxFeed.archived: GlobalKey<_CourierMessageListState>(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _start();
  }

  Future _start() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final brand = await _refreshBrand();

    _inboxListener = await Courier.shared.addInboxListener(
      onLoading: (isRefresh) {
        if (mounted) {
          setState(() {
            _brand = brand;
            if (!isRefresh) {
              _isLoading = true;
            }
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _brand = brand;
            _isLoading = false;
            _error = error;
          });
        }
      },
      onFeedChanged: (messageSet) async {
        if (mounted) {
          setState(() {
            _feedMessages = messageSet.messages;
            _canPaginateFeed = messageSet.canPaginate;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onArchiveChanged: (messageSet) {
        if (mounted) {
          setState(() {
            _archivedMessages = messageSet.messages;
            _canPaginateArchived = messageSet.canPaginate;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onPageAdded: (feed, messageSet) async {
        if (mounted) {
          setState(() {
            if (feed == InboxFeed.feed) {
              _isFeedPaginating = false;
              _canPaginateFeed = messageSet.canPaginate;
              _feedMessages.addAll(messageSet.messages);
            } else {
              _isArchivedPaginating = false; 
              _canPaginateArchived = messageSet.canPaginate;
              _archivedMessages.addAll(messageSet.messages);
            }
          });
        }
      },
      onMessageChanged: (feed, index, message) async {
        if (mounted) {
          await _listKeys[feed]?.currentState?.reloadMessageAtIndex(message, index);
        }
      },
      onMessageAdded: (feed, index, message) async {
        if (mounted) {
          await _listKeys[feed]?.currentState?.addMessageAtIndex(message, index);
        }
      }, 
      onMessageRemoved: (feed, index, message) async {
        if (mounted) {
          await _listKeys[feed]?.currentState?.removeMessageAtIndex(index);
        }
      },
    );
  }

  Future<CourierBrand?> _refreshBrand() async {
    if (!mounted) return null;

    try {
      Brightness currentBrightness = PlatformDispatcher.instance.platformBrightness;
      final brandId = currentBrightness == Brightness.dark
          ? widget._darkTheme.brandId
          : widget._lightTheme.brandId;

      if (brandId == null) {
        widget._lightTheme.brand = null;
        widget._darkTheme.brand = null;
        return null;
      }

      final client = await Courier.shared.client;
      final res = await client?.brands.getBrand(brandId: brandId);
      final brand = res?.data?.brand;
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

  Future<void> _fetchNextPage(InboxFeed feed) async {
    // Check if already paginating for this feed
    if ((feed == InboxFeed.feed && _isFeedPaginating) || 
        (feed == InboxFeed.archived && _isArchivedPaginating)) {
      return;
    }

    setState(() {
      if (feed == InboxFeed.feed) {
        _isFeedPaginating = true;
      } else {
        _isArchivedPaginating = true;
      }
    });

    try {
      final messageSet = await Courier.shared.fetchNextInboxPage(feed: feed);
      Courier.log('New Messages Fetched. Count: ${messageSet?.messages.length ?? 0}');
    } catch (error) {
      Courier.log('Failed to fetch next page: $error');
    }
  }

  void _disposeScrollControllers() {
    if (widget.feedScrollController.hasClients) {
      widget.feedScrollController.dispose();
    }
    if (widget.archivedScrollController.hasClients) {
      widget.archivedScrollController.dispose();
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

  CourierInboxTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  List<Widget> _buildTabViews(bool isDarkMode, double triggerPoint) {
    return [
      CourierMessageList(
        key: _listKeys[InboxFeed.feed],
        triggerPoint: triggerPoint,
        messages: _feedMessages,
        theme: getTheme(isDarkMode),
        canPaginate: _canPaginateFeed,
        scrollController: widget.feedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: _refresh,
        feed: InboxFeed.feed,
        canPerformGestures: !widget.canSwipePages,
        isPaginating: _isFeedPaginating,
        onPaginationTriggered: () => _fetchNextPage(InboxFeed.feed),
      ),
      CourierMessageList(
        key: _listKeys[InboxFeed.archived],
        triggerPoint: triggerPoint,
        messages: _archivedMessages,
        theme: getTheme(isDarkMode),
        canPaginate: _canPaginateArchived,
        scrollController: widget.archivedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: _refresh,
        feed: InboxFeed.archived,
        canPerformGestures: false,
        isPaginating: _isArchivedPaginating,
        onPaginationTriggered: () => _fetchNextPage(InboxFeed.archived),
      ),
    ];
  }

  Widget _buildContent(BuildContext context, bool isDarkMode, double triggerPoint) {
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
              _error!,
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

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inbox'),
            Tab(text: 'Archive'),
          ],
          onTap: (index) {
            if (index == _lastSelectedTab) {
              final controller = index == 0 ? widget.feedScrollController : widget.archivedScrollController;
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              return;
            }
            _lastSelectedTab = index;
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: widget.canSwipePages ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            children: _buildTabViews(isDarkMode, triggerPoint),
          ),
        ),
        CourierFooter(
          shouldShow: _brand?.settings?.inapp?.showCourierFooter ?? true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRect(
      child: CourierThemeBuilder(builder: (context, constraints, isDarkMode) {
        final triggerPoint = constraints.maxHeight / 2;
        return _buildContent(context, isDarkMode, triggerPoint);
      }),
    );
  }

  void _removeInboxListener() {
    if (_inboxListener != null) {
      _inboxListener!.remove().then((_) {
        _inboxListener = null;
      }).catchError((error) {
        Courier.log('Failed to remove inbox listener: $error');
      });
    }
  }

  @override
  void dispose() {
    _disposeScrollControllers();
    _removeInboxListener();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class CourierMessageList extends StatefulWidget {
  final List<InboxMessage> messages;
  final CourierInboxTheme theme;
  final bool canPaginate;
  final double triggerPoint;
  final ScrollController scrollController;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final Future<void> Function() onRefresh;
  final InboxFeed feed;
  final bool canPerformGestures;
  final bool isPaginating;
  final Function() onPaginationTriggered;

  const CourierMessageList({
    super.key,
    required this.messages,
    required this.theme,
    required this.canPaginate,
    required this.triggerPoint,
    required this.scrollController,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.onRefresh,
    required this.feed,
    required this.canPerformGestures,
    required this.isPaginating,
    required this.onPaginationTriggered,
  });

  @override
  State<CourierMessageList> createState() => _CourierMessageListState();
}

class _CourierMessageListState extends State<CourierMessageList> with AutomaticKeepAliveClientMixin {
  final Map<String, GlobalKey<CourierInboxListItemState>> _listItemKeys = {};
  int? _newMessageIndex;
  String? _dismissedMessageId;

  @override
  bool get wantKeepAlive => true;

  Future<void> addMessageAtIndex(InboxMessage message, int index) async {
    setState(() {
      _newMessageIndex = index;
      widget.messages.insert(index, message);
      _listItemKeys[message.messageId] = GlobalKey<CourierInboxListItemState>();
    });
  }

  Future<void> removeMessageAtIndex(int index) async {
    final message = widget.messages[index];
    await _listItemKeys[message.messageId]?.currentState?.remove(shouldFadeOut: _dismissedMessageId != message.messageId);
    setState(() {
      widget.messages.removeAt(index);
      _listItemKeys.remove(message.messageId);
      _dismissedMessageId = null;
    });
  }

  Future<void> reloadMessageAtIndex(InboxMessage message, int index) async {
    setState(() {
      widget.messages[index] = message;
    });
  }

  Widget _buildMessageItem(BuildContext context, InboxMessage message, int index) {
    _listItemKeys.putIfAbsent(message.messageId, () => GlobalKey<CourierInboxListItemState>());
    return Column(
      children: [
        if (index > 0) widget.theme.separator ?? const SizedBox(),
        CourierInboxListItem(
          key: _listItemKeys[message.messageId],
          theme: widget.theme,
          message: message,
          canPerformGestures: widget.canPerformGestures,
          shouldPerformEnterAnimationOnCreate: _newMessageIndex == index,
          onEnterAnimationFinished: () {
            setState(() {
              _newMessageIndex = null;
            });
          },
          onMessageIsVisible: () {
            message.markAsOpened().then((value) {
              Courier.log('Message opened: ${message.messageId}');
            });
          },
          onMessageClick: (message) {
            message.markAsClicked();
            widget.onMessageClick?.call(message, index);
          },
          onMessageLongPress: widget.onMessageLongPress != null ? (message) => widget.onMessageLongPress?.call(message, index) : null,
          onActionClick: (action) => widget.onActionClick?.call(action, message, index),
          onReadGesture: (message) {
            message.isRead ? message.markAsUnread() : message.markAsRead();
          },
          onArchiveGesture: (message) {
            _listItemKeys[message.messageId]?.currentState?.exitStageLeft();
            _dismissedMessageId = message.messageId;
            message.markAsArchived();
          },
        )
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index < widget.messages.length) {
      return _buildMessageItem(context, widget.messages[index], index);
    } else if (index == widget.messages.length && widget.canPaginate) {
      return CourierInboxPaginationItem(
        isPaginating: widget.isPaginating,
        canPaginate: widget.canPaginate,
        onPaginationTriggered: widget.onPaginationTriggered,
        triggerPoint: widget.triggerPoint,
        loadingColor: widget.theme.getLoadingColor(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        RefreshIndicator(
          color: widget.theme.getLoadingColor(context),
          onRefresh: widget.onRefresh,
          child: Scrollbar(
            controller: widget.scrollController,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: widget.scrollController,
              itemCount: widget.messages.length + (widget.canPaginate ? 1 : 0),
              itemBuilder: (context, index) => _buildListItem(context, index),
            ),
          ),
        ),
        if (widget.messages.isEmpty)
          Center(
            child: Text(
              style: widget.theme.getInfoViewTitleStyle(context),
              'No messages found',
            ),
          ),
      ],
    );
  }
}

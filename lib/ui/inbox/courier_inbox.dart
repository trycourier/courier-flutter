import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  final ScrollController? scrollController;

  // Swipe behavior
  final bool canSwipePages;

  CourierInbox({
    super.key,
    this.keepAlive = false,
    CourierInboxTheme? lightTheme,
    CourierInboxTheme? darkTheme,
    this.scrollController,
    this.onMessageClick,
    this.onMessageLongPress,
    this.onActionClick,
    this.canSwipePages = false,
  })  : _lightTheme = lightTheme ?? CourierInboxTheme(),
        _darkTheme = darkTheme ?? CourierInboxTheme();

  @override
  State<CourierInbox> createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  CourierInboxListener? _inboxListener;
  List<InboxMessage> _feedMessages = [];
  List<InboxMessage> _archivedMessages = [];
  bool _isLoading = true;
  String? _error;
  CourierBrand? _brand;
  String? _userId;
  String? _dismissingMessageId;

  @override
  void initState() {
    super.initState();
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
      onLoading: () async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _isLoading = true;
            _error = null;
          });
        }
      },
      onError: (error) async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _isLoading = false;
            _error = error;
          });
        }
      },
      onFeedChanged: (messageSet) async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _feedMessages = messageSet.messages;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onArchiveChanged: (messageSet) {
        if (mounted) {
          setState(() {
            _archivedMessages = messageSet.messages;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onMessageChanged: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          setState(() {
            if (feed == InboxFeed.feed) {
              if (index >= 0 && index < _feedMessages.length) {
                _feedMessages[index] = message;
              }
            } else {
              if (index >= 0 && index < _archivedMessages.length) {
                _archivedMessages[index] = message;
              }
            }
          });
        }
      },
      onMessageAdded: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          setState(() {
            if (feed == InboxFeed.feed) {
              if (index >= 0 && index <= _feedMessages.length) {
                _feedMessages = List.from(_feedMessages)..insert(index, message);
              } else {
                _feedMessages = List.from(_feedMessages)..insert(0, message);
              }
            } else {
              if (index >= 0 && index <= _archivedMessages.length) {
                _archivedMessages = List.from(_archivedMessages)..insert(index, message);
              } else {
                _archivedMessages = List.from(_archivedMessages)..insert(0, message);
              }
            }
          });
        }
      },
      onMessageRemoved: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          setState(() {
            if (feed == InboxFeed.feed) {
              if (index >= 0 && index < _feedMessages.length) {
                _feedMessages = List.from(_feedMessages)..removeAt(index);
              }
            } else {
              if (index >= 0 && index < _archivedMessages.length) {
                _archivedMessages = List.from(_archivedMessages)..removeAt(index);
              }
            }
          });
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

    return Column(
      children: [
        Expanded(
          child: CourierInboxPage(
            feedMessages: _feedMessages,
            archivedMessages: _archivedMessages,
            theme: getTheme(isDarkMode),
            scrollController: widget.scrollController,
            onMessageClick: widget.onMessageClick,
            onMessageLongPress: widget.onMessageLongPress,
            onActionClick: widget.onActionClick,
            onRefresh: _refresh,
            canSwipePages: widget.canSwipePages,
            onArchive: (message, index) async {
              _dismissingMessageId = message.messageId;
              
              // Store original state
              final originalFeedMessages = List<InboxMessage>.from(_feedMessages);
              final originalArchivedMessages = List<InboxMessage>.from(_archivedMessages);
              
              setState(() {
                // Find index to insert archived message based on timestamp
                if (message.createdAt == null) {
                  // If message has no timestamp, insert at beginning
                  _archivedMessages.insert(0, message);
                } else {
                  int insertIndex = _archivedMessages.indexWhere(
                    (m) => m.createdAt?.isBefore(message.createdAt!) ?? false
                  );
                  if (insertIndex == -1) {
                    // If no earlier messages found, add to end
                    _archivedMessages.add(message);
                  } else {
                    // Insert at correct position
                    _archivedMessages.insert(insertIndex, message);
                  }
                }
                _feedMessages.removeAt(index);
              });

              try {
                await message.markAsArchived();
              } catch (error) {
                Courier.log('Failed to archive message: $error');
                // Reset to original state on error
                setState(() {
                  _feedMessages = originalFeedMessages;
                  _archivedMessages = originalArchivedMessages;
                });
              }
              
              _dismissingMessageId = null;
            },
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
        return _buildContent(context, isDarkMode);
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
    _removeInboxListener();
    super.dispose();
  }
}

class CourierInboxPage extends StatefulWidget {
  final List<InboxMessage> feedMessages;
  final List<InboxMessage> archivedMessages;
  final CourierInboxTheme theme;
  final ScrollController? scrollController;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final Future<void> Function() onRefresh;
  final bool canSwipePages;
  final Function(InboxMessage, int)? onArchive;

  const CourierInboxPage({
    super.key,
    required this.feedMessages,
    required this.archivedMessages,
    required this.theme,
    required this.scrollController,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.onRefresh,
    required this.canSwipePages,
    required this.onArchive,
  });

  @override
  State<CourierInboxPage> createState() => _CourierInboxPageState();
}

class _CourierInboxPageState extends State<CourierInboxPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inbox'),
            Tab(text: 'Archive'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: widget.canSwipePages ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabViews() {
    return [
      CourierMessageList(
        messages: widget.feedMessages,
        theme: widget.theme,
        scrollController: widget.scrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: widget.onRefresh,
        feed: InboxFeed.feed,
        canSwipeItems: !widget.canSwipePages,
        onArchive: widget.onArchive,
      ),
      CourierMessageList(
        messages: widget.archivedMessages,
        theme: widget.theme,
        scrollController: widget.scrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: widget.onRefresh,
        feed: InboxFeed.archived,
        canSwipeItems: !widget.canSwipePages,
        onArchive: widget.onArchive,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class CourierMessageList extends StatefulWidget {
  final List<InboxMessage> messages;
  final CourierInboxTheme theme;
  final ScrollController? scrollController;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final Future<void> Function() onRefresh;
  final InboxFeed feed;
  final bool canSwipeItems;
  final Function(InboxMessage, int)? onArchive;

  const CourierMessageList({
    super.key,
    required this.messages,
    required this.theme,
    required this.scrollController,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.onRefresh,
    required this.feed,
    required this.canSwipeItems,
    required this.onArchive,
  });

  @override
  State<CourierMessageList> createState() => _CourierMessageListState();
}

class _CourierMessageListState extends State<CourierMessageList> with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();
  bool _canPaginate = false;
  double _triggerPoint = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Pagination logic here if needed
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index <= widget.messages.length - 1) {
      final message = widget.messages[index];
      Widget listItem = Column(
        children: [
          if (index > 0) widget.theme.separator ?? const SizedBox(),
          VisibilityDetector(
            key: Key(message.messageId),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction > 0 && !message.isOpened) {
                message.markAsOpened().then((value) {
                  Courier.log('Message opened: ${message.messageId}');
                });
              }
            },
            child: CourierInboxListItem(
              theme: widget.theme,
              message: message,
              onMessageClick: (message) {
                message.markAsClicked();
                widget.onMessageClick?.call(message, index);
              },
              onMessageLongPress: (message) {
                widget.onMessageLongPress?.call(message, index);
              },
              onActionClick: (action) => widget.onActionClick?.call(action, message, index),
            ),
          ),
        ],
      );

      if (widget.canSwipeItems && widget.feed == InboxFeed.feed) {
        listItem = Dismissible(
          key: Key(message.messageId),
          direction: DismissDirection.horizontal,
          movementDuration: const Duration(milliseconds: 150),
          confirmDismiss: (direction) async {
            HapticFeedback.mediumImpact();
            if (direction == DismissDirection.startToEnd) {
              // Left to right swipe - toggle read status
              if (message.isRead) {
                message.markAsUnread();
              } else {
                message.markAsRead();
              }
              return false; // Don't dismiss
            }
            return true; // Allow dismiss for right to left (archive)
          },
          background: Container( // Left to right background
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24.0),
            child: Icon(
              message.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
              color: Colors.white
            ),
          ),
          secondaryBackground: Container( // Right to left background
            color: Colors.red,
            alignment: Alignment.centerRight, 
            padding: const EdgeInsets.only(right: 24.0),
            child: const Icon(Icons.archive, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              widget.onArchive?.call(message, index);
            }
          },
          child: listItem,
        );
      }

      return listItem;
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
              valueColor: AlwaysStoppedAnimation<Color>(
                  widget.theme.getLoadingColor(context)),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.messages.isEmpty) {
      return Center(
        child: Text(
          style: widget.theme.getInfoViewTitleStyle(context),
          'No messages found',
        ),
      );
    }

    return RefreshIndicator(
      color: widget.theme.getLoadingColor(context),
      onRefresh: widget.onRefresh,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: widget.messages.length + (_canPaginate ? 1 : 0),
          itemBuilder: (context, index) {
            return _buildListItem(context, index);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}

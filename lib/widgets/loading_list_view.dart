import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swipe_refresh/swipe_refresh.dart';

class LoadingListView<T> extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder emptyItemBuilder;
  final bool initialIsLoading;
  final int itemCount;
  final Stream<SwipeRefreshState> stateStream; //Used when triggering a reload of the items on the Cubit
  final Stream<bool>? overlayLoadingStream; //Used to show overlay of "Refresh" when app opens from background
  final VoidCallback onRefresh;
  final ScrollController? scrollController;

  const LoadingListView({
    Key? key,
    this.initialIsLoading = true,
    required this.itemBuilder,
    required this.emptyItemBuilder,
    required this.itemCount,
    required this.stateStream,
    required this.onRefresh,
    this.overlayLoadingStream,
    this.scrollController,
  }) : super(key: key);

  @override
  State<LoadingListView> createState() => LoadingListViewState();
}

enum LoadingState { initial, reloading, loaded }

class LoadingListViewState<T> extends State<LoadingListView> {
  final ValueNotifier<LoadingState> _valueNotifier = ValueNotifier<LoadingState>(LoadingState.initial);

  StreamSubscription<SwipeRefreshState>? _subscription;
  @override
  void initState() {
    super.initState();
    if (widget.initialIsLoading) {
      _valueNotifier.value = LoadingState.initial;
    } else {
      _valueNotifier.value = LoadingState.loaded;
    }

    _subscription = widget.stateStream.listen((event) {
      if (event == SwipeRefreshState.hidden) {
        _valueNotifier.value = LoadingState.loaded;
      } else {
        _valueNotifier.value = LoadingState.reloading;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadingState>(
        valueListenable: _valueNotifier,
        builder: (context, value, child) {
          if (value == LoadingState.initial) {
            return const Align(
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (widget.itemCount == 0) ...[
                Builder(
                  builder: widget.emptyItemBuilder,
                ),
              ] else ...[
                Column(
                  children: [
                    Expanded(
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          // Prevent top and bottom glow
                          notification.disallowIndicator();
                          return false;
                        },
                        child: SwipeRefresh.builder(
                          stateStream: widget.stateStream,
                          onRefresh: widget.onRefresh,
                          shrinkWrap: true,
                          itemCount: widget.itemCount,
                          itemBuilder: widget.itemBuilder,
                          scrollController: widget.scrollController,
                        ),
                      ),
                    ),
                  ],
                ),

                //When the user comes back into the app we can trigger this to show as if
                //the swipe down refresh was triggered on the SwipeRefresh.builder
                StreamBuilder<bool>(
                  stream: widget.overlayLoadingStream,
                  builder: (context, snapshot) {
                    return snapshot.hasData && snapshot.data == true
                        ? Positioned(
                            top: 46,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                ),
              ],
            ],
          );
        });
  }
}

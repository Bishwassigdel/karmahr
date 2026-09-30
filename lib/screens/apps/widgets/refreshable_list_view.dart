// A drop-in replacement for ListView / ListView.builder that adds
// iOS-style pull-to-refresh. Same parameters plus onRefresh, so
// converting a screen is a one-word change:
//
//   ListView(padding:, children:)          → RefreshableListView(onRefresh:, ...)
//   ListView.builder(itemCount:, itemBuilder:) → RefreshableListView.builder(onRefresh:, ...)
//
// onRefresh is exactly the seam a backend plugs into later: today it
// re-runs a screen's demo fetch (or stands in for one on static data);
// tomorrow it's the real API call, and no layout changes.

import 'package:flutter/cupertino.dart';

/// Stand-in for a network round-trip on screens whose data is still
/// static — same 600ms latency the demo fetch functions use, so pulling
/// to refresh feels consistent everywhere. Replace the call site with a
/// real fetch once a backend exists.
Future<void> simulatedRefresh() =>
    Future<void>.delayed(const Duration(milliseconds: 600));

class RefreshableListView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry padding;
  final SliverChildDelegate _delegate;

  RefreshableListView({
    super.key,
    required this.onRefresh,
    this.padding = EdgeInsets.zero,
    required List<Widget> children,
  }) : _delegate = SliverChildListDelegate(children);

  RefreshableListView.builder({
    super.key,
    required this.onRefresh,
    this.padding = EdgeInsets.zero,
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
  }) : _delegate = SliverChildBuilderDelegate(
         itemBuilder,
         childCount: itemCount,
       );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Bouncing physics explicitly, not the platform default: Android's
      // default (clamping) never overscrolls, so the refresh control
      // could never be pulled down there. AlwaysScrollable so it still
      // works when the content is shorter than the screen.
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        SliverPadding(
          padding: padding,
          sliver: SliverList(delegate: _delegate),
        ),
      ],
    );
  }
}

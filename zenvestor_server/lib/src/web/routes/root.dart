import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_server/src/web/widgets/built_with_serverpod_page.dart';

/// Root route handler for the web server.
///
/// Displays the default Serverpod landing page at the root URL.
class RouteRoot extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    return BuiltWithServerpodPage();
  }
}

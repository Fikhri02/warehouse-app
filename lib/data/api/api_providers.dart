import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Overridden in main.dart when the app is built with WARETRACK_API.
final apiClientProvider = Provider<ApiClient>((_) => throw UnimplementedError('apiClientProvider needs WARETRACK_API'));

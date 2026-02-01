// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FakeAssetBundle extends CachingAssetBundle {
//   static final Uint8List _transparentImage = Uint8List.fromList(<int>[
//     0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
//     0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
//     0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
//     0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
//     0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
//     0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
//     0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
//     0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
//     0x42, 0x60, 0x82,
//   ]);

//   @override
//   Future<ByteData> load(String key) async {
//     return ByteData.view(_transparentImage.buffer);
//   }

//   @override
//   Future<String> loadString(String key, {bool cache = true}) async {
//     if (key == 'AssetManifest.json') {
//       return '{}';
//     }
//     return '';
//   }

//   @override
//   Future<T> loadStructuredBinaryData<T>(
//     String key,
//     FutureOr<T> Function(ByteData data) parser,
//   ) async {
//     if (key == 'AssetManifest.bin') {
//       return _EmptyAssetManifest() as T;
//     }
//     return parser(await load(key));
//   }
// }

// class _EmptyAssetManifest implements AssetManifest {
//   @override
//   List<String> listAssets() => const [];

//   @override
//   List<AssetMetadata>? getAssetVariants(String key) => null;
// }

// Widget wrapWithApp(Widget child, {List<Override> overrides = const []}) {
//   return ProviderScope(
//     overrides: overrides,
//     child: DefaultAssetBundle(
//       bundle: FakeAssetBundle(),
//       child: MaterialApp(home: child),
//     ),
//   );
// }


import 'dart:io';
import 'dart:typed_data';

abstract base class Asset {
  const Asset();

  String get id;
  String get type;
  int get byteSize;

  @override
  bool operator ==(covariant TextAsset other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class TextAsset extends Asset {
  const TextAsset(this._text);

  final String _text;

  @override
  String get id => throw UnimplementedError();

  @override
  String get type => 'byte';

  @override
  int get byteSize => _text.codeUnits.length;
}

final class FileAsset extends Asset {
  FileAsset._({required this.bytes, required this.path});

  factory FileAsset.fromPath(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      return FileAsset._(bytes: bytes, path: path);
    } on FileSystemException {
      rethrow;
    }
  }

  late Uint8List bytes;
  final String path;

  @override
  String get id => throw UnimplementedError();

  @override
  String get type => 'file';

  @override
  int get byteSize => bytes.length;
}

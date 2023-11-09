import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poc/src/nearby/application/nearby_communication.dart';

void main() {
  group(
    'Payload():',
    () {
      test(
        'bytes, filePath 두 값 모두 없으면 Assertion 처리 되어야함.',
        () async {
          // arrange

          // act
          assertCondition() => Payload(id: 0);

          // assert
          expect(assertCondition, throwsA(const TypeMatcher<AssertionError>()));
        },
      );

      test(
        'bytes, filePath 두 값 모두 있으면 Assertion 처리 되어야함.',
        () async {
          // arrange

          // act
          assertCondition() => Payload(
                id: 0,
                filePath: '/path/to/file',
                bytes: Uint8List(0),
              );

          // assert
          expect(assertCondition, throwsA(const TypeMatcher<AssertionError>()));
        },
      );

      test(
        'bytes 값만 있을 때는 인스턴스 생성해야 함.',
        () async {
          final payload = Payload(
            id: 0,
            bytes: Uint8List(0),
          );

          expect(payload, isA<Payload>());
        },
      );

      test(
        'filePath 값만 있을 때는 인스턴스 생성해야 함.',
        () async {
          const payload = Payload(id: 0, filePath: '/path/to/file');

          expect(payload, isA<Payload>());
        },
      );
    },
  );
}

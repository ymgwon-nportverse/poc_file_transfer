import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  /// size 라고 이름을 명명하고 싶었지만, size는 이미 예약되어 있어서 sizeOf 로 명명함
  Size get sizeOf {
    return MediaQuery.sizeOf(this);
  }

  NavigatorState get navigator {
    return Navigator.of(this);
  }

  FocusScopeNode get focus {
    return FocusScope.of(this);
  }

  /// 사용할 수 있는 화면에서, 1/3 크기의 ModalBottomSheet 생성
  ///
  /// [SizedBox]의 height 가 ` / 3` 인지 확인
  Future<bool?> showOneThirdBottomSheet({required WidgetBuilder builder}) {
    return showModalBottomSheet(
      context: this,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: context.sizeOf.height / 3,
          child: Material(
            color: context.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              alignment: Alignment.center,
              child: builder(context),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> showCustomDialog({required WidgetBuilder builder}) {
    return showAdaptiveDialog(
      context: this,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: context.sizeOf.height / 3,
              width: context.sizeOf.width - 24,
              child: Material(
                elevation: 10,
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  alignment: Alignment.center,
                  child: builder(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

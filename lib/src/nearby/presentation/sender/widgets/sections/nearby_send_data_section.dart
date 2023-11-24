import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/ui_state/ui_send_property.dart';

class NearbySendDataSection extends ConsumerStatefulWidget {
  const NearbySendDataSection({super.key});

  @override
  ConsumerState<NearbySendDataSection> createState() =>
      _NearbySendDataSectionState();
}

class _NearbySendDataSectionState extends ConsumerState<NearbySendDataSection> {
  int _toggleIndex = 0;
  final _sections = const [
    NearbyTextAssetsList(),
    NearbyFileAssetsList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '보내는 데이터',
              style: context.textTheme.headlineSmall,
            ),
            const Spacer(),
            SizedBox(
              height: 40,
              child: SendTypeToggleWidget(
                onToggle: _onToggle,
                initialIndex: _toggleIndex,
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: _sections[_toggleIndex],
        ),
        const Divider(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                context.navigator.pushNamed('/nearby/send/remote');
              },
              child: const Text('서버 데이터 업데이트'),
            ),
            TextButton(
              onPressed: ref.watch(uiSendPropertyProvider).selectedData != null
                  ? () => ref.read(uiSendPropertyProvider).setData(null)
                  : null,
              child: const Text('선택 취소'),
            ),
          ],
        ),
      ],
    );
  }

  void _onToggle(int index) {
    setState(() {
      _toggleIndex = index;
    });
  }
}

class NearbyTextAssetsList extends ConsumerWidget {
  const NearbyTextAssetsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future: Future.value(ref.read(myAssetsRepositoryProvider).getAssets()),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _AssetItem(name: snapshot.data![index]);
              },
              itemCount: snapshot.data!.length,
            );
          default:
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
        }
      },
    );
  }
}

class _AssetItem extends ConsumerWidget {
  const _AssetItem({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSelected =
        ref.watch(uiSendPropertyProvider).selectedData == name;
    return GestureDetector(
      onTap: () => ref.read(uiSendPropertyProvider).setData(name),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: context.theme.colorScheme.surfaceVariant.withOpacity(.4),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          name,
          style: context.textTheme.labelLarge?.copyWith(
            fontSize: 20,
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class NearbyFileAssetsList extends StatelessWidget {
  const NearbyFileAssetsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: _onTap,
          child: const Text('파일 불러오기'),
        ),
      ],
    );
  }

  Future<void> _onTap() async {}
}

class SendTypeToggleWidget extends StatefulWidget {
  const SendTypeToggleWidget(
      {super.key, required this.onToggle, this.initialIndex = 0})
      : assert(initialIndex <= 1);

  final int initialIndex;
  final ValueChanged<int> onToggle;

  @override
  State<SendTypeToggleWidget> createState() => _SendTypeToggleWidgetState();
}

class _SendTypeToggleWidgetState extends State<SendTypeToggleWidget> {
  final icons = [Icons.text_format, Icons.file_present];
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            if (details.localPosition.dx > constraints.maxHeight * 1.3) {
              if (_index == 1) {
                return;
              }
              setState(() {
                _index = 1;
                widget.onToggle.call(_index);
              });
            } else {
              if (_index == 0) {
                return;
              }
              setState(() {
                _index = 0;
                widget.onToggle.call(_index);
              });
            }
          },
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * 2.5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.theme.colorScheme.onInverseSurface,
                  ),
                  child: Row(
                    children:
                        icons.map((e) => Expanded(child: Icon(e))).toList(),
                  ),
                ),
                AnimatedAlign(
                  alignment: _index == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: constraints.maxHeight,
                    width: constraints.maxHeight * 1.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.theme.colorScheme.primary,
                    ),
                    child: Center(
                        child: Icon(
                      icons[_index],
                      color: Colors.white,
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

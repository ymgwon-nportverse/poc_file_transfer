import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/state/ui_send_property.dart';

class NearbySendDataSection extends ConsumerWidget {
  const NearbySendDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '보내는 데이터',
          style: context.textTheme.headlineSmall,
        ),
        const Divider(),
        const Expanded(
          child: NearbyAssetsList(),
        ),
        const Divider(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                // TODO: 진짜 데이터 받아오는 로직 추가하기
                context.showCustomDialog(
                  builder: (context) {
                    return Column(
                      children: [
                        Text(
                          '구현 중',
                          style: context.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '아직까지 구현되지 않았습니다.',
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: context.navigator.pop,
                            child: const Text('닫기'),
                          ),
                        )
                      ],
                    );
                  },
                );
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
}

class NearbyAssetsList extends ConsumerWidget {
  const NearbyAssetsList({super.key});

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

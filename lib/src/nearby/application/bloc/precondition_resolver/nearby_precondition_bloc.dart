import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/precondition_resolver/nearby_precondition_event.dart';
import 'package:poc/src/nearby/application/bloc/precondition_resolver/nearby_precondition_state.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';

class NearbyPreconditionBloc extends StateNotifier<NearbyPreconditionState> {
  NearbyPreconditionBloc(
    this._checker,
  ) : super(const NearbyPreconditionState.none());

  final NearbyPreconditionResolver _checker;

  void mapEventToState(NearbyPreconditionEvent event) {
    event.handle(this);
  }

  Future<void> checkPrecondition() async {
    final isSatisfied = await _checker.isSatisfied();

    if (isSatisfied) {
      state = const NearbyPreconditionState.satisfied();
    } else {
      state = const NearbyPreconditionState.unsatisfied();
    }
  }

  Future<void> resolve() async {
    await _checker.resolve();

    final isSatisfied = await _checker.isSatisfied();

    if (isSatisfied) {
      state = const NearbyPreconditionState.satisfied();
    } else {
      state = const NearbyPreconditionState.unsatisfied();
    }
  }
}

abstract interface class NearbyPreconditionChecker {
  Future<bool> isSatisfied();
  Future<void> satisfy();
}

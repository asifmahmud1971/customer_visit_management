enum VisitStatus {
  pending,
  visited,
  notAvailable;

  String get name {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.visited:
        return 'Visited';
      case VisitStatus.notAvailable:
        return 'Not Available';
    }
  }

  static VisitStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'visited':
        return VisitStatus.visited;
      case 'not available':
      case 'not_available':
        return VisitStatus.notAvailable;
      default:
        return VisitStatus.pending;
    }
  }
}

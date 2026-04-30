/// Centralized string constants for the entire application.
/// No UI widget should use a hardcoded String literal.
abstract class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────
  static const String appTitle = 'VisitSync';

  // ── Customer List Screen ─────────────────────────
  static const String customerVisits = 'Customer Visits';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String searchHint = 'Search by name or phone…';
  static const String filterAll = 'All';
  static const String pendingSyncTitle = 'pending sync';
  static const String pendingSyncSubtitle = 'Will sync when connection is restored';
  static const String loadingCustomers = 'Loading customers…';
  static const String noCustomersFound = 'No customers found';
  static const String noCustomersSubtitle = 'Try adjusting your search or filter';
  static const String syncNow = 'Sync Now';
  static const String syncing = 'Syncing…';
  static const String noVisitYet = '· No visit yet';
  static const String unknownInitial = '?';
  static const String customersTotal = 'customers total';

  // ── Filter Tab Labels ─────────────────────────────
  static const String filterVisited = 'Visited';
  static const String filterNotAvailable = 'N/A';
  static const String filterPending = 'Pending';

  // ── Customer Detail Screen ────────────────────────
  static const String customerDetails = 'Customer Details';
  static const String synced = 'Synced';
  static const String pendingSync = 'Pending Sync';

  // Section titles
  static const String sectionContactInfo = 'Contact Information';
  static const String sectionVisitStatus = 'Visit Status';
  static const String sectionVisitNotes = 'Visit Notes';

  // Info row labels
  static const String labelPhone = 'Phone';
  static const String labelEmail = 'Email';
  static const String labelAddress = 'Address';
  static const String labelLastVisit = 'Last Visit';
  static const String labelNotes = 'Notes';
  static const String labelSyncStatus = 'Sync Status';

  // Status chip labels
  static const String statusVisited = 'Visited';
  static const String statusNotAvailable = 'Not\nAvailable';
  static const String statusPending = 'Pending';

  // Buttons
  static const String btnLogVisit = 'Log Visit';
  static const String btnSaveChanges = 'Save Changes';

  // Notes hint
  static const String notesHint = 'Add notes about this visit…';

  // Snackbars
  static const String snackSavedLocally = 'Saved locally · queued for sync';
  static const String snackVisitLogged = 'New visit logged · queued for sync';
}

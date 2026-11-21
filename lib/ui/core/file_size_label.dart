import 'package:fusionreflow/l10n/app_localizations.dart';

const double _bytesInMb = 1048576;

/// File size for display in megabytes with one decimal, e.g. "1.8 MB".
String fileSizeLabel(AppLocalizations l10n, int bytes) =>
    l10n.fileSizeMb(bytes / _bytesInMb);

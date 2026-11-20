import 'package:fusionreflow/l10n/app_localizations.dart';

const double _bytesInMb = 1048576;

/// Размер файла для показа: «1,8 МБ» (мегабайты с одним знаком).
String fileSizeLabel(AppLocalizations l10n, int bytes) =>
    l10n.fileSizeMb(bytes / _bytesInMb);

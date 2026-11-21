# Удаление и детали книги: спека

**Задача плана:** 3.3 «Удаление и детали книги» (план 2)
**Стек:** оба (Rust: описание в формате и мосте; Flutter: меню, удаление, карточка)
**Ветка:** `feat/book-actions` — одна ветка и один PR; сначала работает `rust-developer`, затем `flutter-developer`
в той же ветке (решение человека 2026-11-20). Ревьюеры смотрят свою часть диффа.
**Статус:** утверждена человеком 2026-11-20.

## Цель

Долгое нажатие на книгу в библиотеке открывает меню «Информация о книге» / «Удалить книгу». Первый пункт открывает
карточку книги с описанием, размером файла, языком и датой добавления, второй удаляет книгу после подтверждения.
Для карточки импорт начинает сохранять описание из метаданных EPUB и размер исходного файла.

## Решения человека (2026-11-20)

1. **Описание — в `Meta`, без смены версии формата.** `Meta.description: Option<String>` с
   `#[serde(default, skip_serializing_if = "Option::is_none")]`. Старые книги читаются (поле отсутствует → `None`),
   эталон `book_v1.cbor` не меняется, `FORMAT_VERSION` остаётся `1`. Поле идёт в `BookMeta` (мост
   перегенерируется) и в колонку Drift `description`.
2. **Размер — из системного выбора файла**, а не из Rust: `ImportSource.sizeBytes` (уже есть) передаётся в
   `BookRepository.add` и ложится в колонку Drift `sourceSize`. Rust и формат для размера не меняются. Провайдер
   не сообщил размер — строка «Размер файла» скрыта.
3. **Книги, добавленные до 3.3**, показываются как «нет данных»: «В файле нет описания.», размер скрыт. Удалить и
   добавить заново — данные появятся (возврат удалённой книги перезаписывает метаданные). Приложение не выпущено,
   такие книги есть только на тестовых установках.
4. **SnackBar после удаления — «Книга удалена», без «Вернуть».** Подтверждение уже есть, а `delete` сразу стирает
   файл книги. Ошибка удаления — SnackBar «Не удалось удалить книгу».
5. **Название языка — пакет `flutter_localized_locales` 2.0.5** (MIT, зависит только от `intl`; данные CLDR через
   umpirsky/locale-list, MIT). Человек выбрал новую зависимость вместо своего списка в ARB.
6. **Задача не делится**: одна ветка, Rust первым.

Предложение тимлида принято целиком: из карточки убраны оглавление, закладки, страницы и главы, «Источник»,
«С начала» и ⋮; «Продолжить / Начать чтение» ведёт в заглушку читалки `/reader/:bookId`.

## Границы

В задаче:
- Rust: `Meta.description`, чтение `dc:description` в EPUB-конвертере с очисткой HTML, `BookMeta.description`,
  перегенерация моста;
- Drift: схема v2 (`description`, `sourceSize`) с миграцией с v1;
- `BookEntry.description`, `BookEntry.sourceSize`, `BookRepository.add(..., sourceSize:)`, `BookRepository.watch(id)`;
- долгое нажатие на `BookCard` и `ContinueReadingCard` → диалог действий (`book-details`);
- подтверждение удаления (`book-delete-confirm`), удаление, SnackBar;
- экран карточки книги (`book-card`, `book-card-empty`) и лист полного описания (`book-description`), светлая и
  тёмная темы, телефон и планшет;
- строки ru/en, юнит-, виджет- и golden-тесты, лицензия пакета в README.

Не в задаче (и где это делается):
- оглавление, закладки, страницы и главы, «Источник», «С начала», ⋮ на карточке — свои задачи (оглавление и
  закладки — 5.x, источник — задача импорта папки);
- удаление из карточки книги — нет пункта в макете;
- «Вернуть» после удаления — не делается (решение человека 4);
- описание FB2 (`annotation`) — задача 4.2 заполнит то же поле `Meta.description`;
- настоящие обложки — отдельная задача;
- обновление метаданных при повторном импорте живой книги — не делается (решение человека 3);
- множественный выбор и удаление нескольких книг — не делается (*решение аналитика*: нет в макетах).

## Интерфейсы

### Rust — `rust/flow-core`

`src/model/book.rs`:
```rust
pub struct Meta {
    pub title: String,
    pub authors: Vec<String>,
    pub language: Option<String>,
    pub cover: Option<ResourceId>,
    /// Plain-text annotation from the source metadata; paragraphs separated by "\n\n".
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}
```
В doc-комментарии `src/model/mod.rs` уточнить правило: новое необязательное поле — `#[serde(default)]` и
`skip_serializing_if`, тогда кодировка книг без поля не меняется и эталон остаётся прежним.
Все места, где собирается `Meta` (EPUB-конвертер, `StubConverter`, тесты `flow-core` и `bridge`,
`rust/bridge/tests/book_meta_large.rs`, тест-хелперы в `rust/bridge/src/api/import.rs`), получают поле.

EPUB (`src/import/epub/`), *решение аналитика*:
- `package.rs`: первый `dc:description` в OPF захватывается так же, как `title` (`Capture::Description`);
  `Package.description: Option<String>`.
- Новый модуль `src/import/epub/description.rs`: `pub(super) fn plain_description(raw: &str) -> Option<String>`.
  Описание в EPUB часто — экранированный HTML (`&lt;p&gt;…`), и после разбора XML в тексте остаются теги. Правила:
  1. теги `<p>`, `<div>`, `<br>`, `<li>`, `<h1>`…`<h6>` (открывающие и закрывающие, без учёта регистра) — граница
     абзаца; остальные теги выбрасываются вместе с атрибутами; незакрытый `<` до конца строки — выбрасывается;
  2. HTML-сущности (`&amp;`, `&nbsp;`, `&#8212;`, `&#x2014;` и именованные) раскрываются через существующий
     `entities::named` и разбор числовых; неизвестная сущность остаётся текстом;
  3. внутри абзаца пробельные символы схлопываются в один пробел, края обрезаются; пустые абзацы выбрасываются;
     абзацы соединяются `"\n\n"`;
  4. итог длиннее `MAX_DESCRIPTION_CHARS = 10_000` символов (`char`) обрезается по границе символа и получает `…`;
  5. пустой итог → `None`.
- `mod.rs`: `Meta { description: pkg.description, .. }`. Версию конвертера (`EPUB_CONVERTER_VERSION`) поднять на
  минорную: книга из того же файла теперь другая.

### Rust — `rust/bridge`

`src/api/book.rs`: `BookMeta` получает `pub description: Option<String>`, `book_meta` копирует
`book.meta.description`. После правки — `flutter_rust_bridge_codegen generate`, сгенерированное коммитится;
перед QA — `flutter clean` (AGENTS.md, раздел 8). `import_book` и `ImportEvent` не меняются.

### Flutter — данные

`lib/data/services/database/books_table.dart` — две колонки:
```dart
/// Plain-text annotation from the book; null — none or added before schema v2.
TextColumn get description => text().nullable()();
/// Size of the source file in bytes as reported by the file picker; null — unknown.
IntColumn get sourceSize => integer().nullable()();
```
`app_database.dart`: `schemaVersion => 2`,
`MigrationStrategy(onUpgrade: (m, from, to) async { if (from < 2) { await m.addColumn(books, books.description); await m.addColumn(books, books.sourceSize); } })`.
Шаги миграций drift (`make-migrations`) не вводятся (*решение аналитика*: одна миграция, проверяется тестом ниже).

`lib/domain/models/book_entry.dart` — два поля: `String? description`, `int? sourceSize`.

`lib/data/repositories/book_repository.dart`:
```dart
/// Stores a CBOR-encoded book. [sourceSize] is the source file size, if known.
/// The same live book (by source hash) is returned unchanged; a deleted one is revived
/// with the same id and fresh metadata (title, description, sourceSize …) and progress.
Future<BookEntry> add(Uint8List bytes, BookFormat format, {int? sourceSize});

/// Live book [id]; emits null when it is missing or deleted.
Stream<BookEntry?> watch(String id);
```
`watch` — запрос по `id` среди живых (`_live()..where(id)`) с `watchSingleOrNull`. `readerPlaceholderViewModel`
переходит с фильтра `watchAll()` на `watch(id)` (*решение аналитика*: одно место для «книга по id», DRY).
`delete` не меняется. `sourceSize < 0` пишется как `null` (кривой ответ провайдера).
`ImportViewModel._add` передаёт `source.sizeBytes`. `FakeBookRepository` получает `watch`, журнал `add` хранит
`sourceSize`, журнал `delete` и настраиваемую ошибку `delete`.

### Flutter — ViewModel

`LibraryViewModel` — новый метод:
```dart
/// Deletes book [id]. Returns false if the repository failed; the error is not rethrown,
/// the View shows `bookDeleteFailed`. The book leaves the grid through watchAll.
Future<bool> deleteBook(String id);
```

`lib/ui/book_details/view_models/book_details_view_model.dart`:
```dart
/// Книга [bookId] для карточки; null — книги нет или она удалена.
@riverpod
Stream<BookEntry?> bookDetailsViewModel(Ref ref, String bookId) =>
    ref.watch(bookRepositoryProvider).watch(bookId);
```

### Flutter — маршрут

`AppRoutes.bookDetails = '/book/:bookId'`, `static String bookDetailsOf(String bookId)` (с `Uri.encodeComponent`,
как `readerOf`). Маршрут верхнего уровня вне `StatefulShellRoute`, как читалка; открывается `context.push`.
«Назад» возвращает в библиотеку. Кнопка чтения на карточке делает `context.push(AppRoutes.readerOf(id))`
(«Назад» из читалки — снова карточка).

### Flutter — View (один виджет — один файл)

`lib/ui/library/widgets/`:

| Файл | Что | Детали |
|---|---|---|
| `book_card.dart` | `BookCard` | + `onLongPress` у `InkWell`; тап по-прежнему открывает читалку |
| `continue_reading_card.dart` | `ContinueReadingCard` | + то же долгое нажатие |
| `book_actions_dialog.dart` | `BookActionsDialog` | по `book-details`: ключ `book_actions`, радиус `AppRadius.dialog`, отступ 20; шапка — обложка 48 (`BookCover`) + название 17/w650 + авторы 13.5 `mu`; кнопки высотой 48, радиус 8, во всю ширину, зазор 8: `book_action_details` (иконка «i», фон `at`, текст `ac`), `book_action_delete` (иконка корзины, фон `error`, текст `onError`), `book_action_close` (текстовая). Возвращает `BookAction?` (`enum BookAction { details, delete }` в этом же файле) через `Navigator.pop` |
| `delete_book_dialog.dart` | `DeleteBookDialog` | `AlertDialog` по `book-delete-confirm` и `kit`: «Удалить книгу?», текст `bookDeleteMessage(title)`; кнопки `delete_cancel` «Отмена» и `delete_confirm` «Удалить» цвета `error`. Возвращает `bool` |
| `book_actions_flow.dart` | функция `Future<void> showBookActions(BuildContext context, WidgetRef ref, BookEntry book)` | не виджет: диалог действий → `details`: `push(bookDetailsOf)`; `delete`: `DeleteBookDialog` → `true`: `deleteBook` → SnackBar `bookDeleted` или `bookDeleteFailed`. Вызывают `BookGrid` и `LibraryContent` |

Затемнение под диалогами — тема (`rgba(0,0,0,.55)` в макете; берётся `barrierColor` темы, как у листа импорта).
Долгое нажатие на `ImportingBookCard` ничего не делает.

`lib/ui/book_details/widgets/`:

| Файл | Что | Детали |
|---|---|---|
| `book_details_screen.dart` | `BookDetailsScreen` | ключ `book_details`; по `AsyncValue`: загрузка, ошибка (`libraryLoadError`), `null` → `readerBookNotFound` (ключ `book_not_found`); кнопка «Назад» 44 в шапке; тело прокручивается (`ListView`); на medium/expanded колонка не шире `AppSizes.detailsMaxWidth = 600` по центру |
| `book_details_header.dart` | `BookDetailsHeader` | обложка 104 (`BookCover`) с тенью, название 24/30 w650, авторы 15 `mu` или курсивом «Автор не указан»; строка 13 `mu` из непустых частей через « · »: формат, размер, язык |
| `book_progress_section.dart` | `BookProgressSection` | подпись 13/w600: «Не начата» (fresh) / «Прочитано {N}%» (reading) / «Прочитана» (finished); полоса 4 (`AppSizes.trackHeight`); кнопка 48 во всю ширину `book_read`: fresh → «Начать чтение», иначе «Продолжить чтение» |
| `book_about_section.dart` | `BookAboutSection` | «Об этой книге» w600; текст 14/22 `mu`, не больше 2 строк с «…»; «Читать полностью» (`book_read_more`, 13 w600 `ac`) — только если текст не влез в 2 строки (`TextPainter.didExceedMaxLines` в `LayoutBuilder`); без описания — «В файле нет описания.» без ссылки |
| `book_description_sheet.dart` | `BookDescriptionSheet` | модальный лист `useRootNavigator`, ключ `book_description`, радиус `AppRadius.sheet`, ручка из темы; заголовок 18/w650 и кнопка закрытия `book_description_close`; абзацы (`description.split('\n\n')`) 15.5/25, зазор 12, прокрутка; снизу над разделителем — сноска 12.5 `mu` `bookDescriptionNote`. Высота — до 90% экрана (`isScrollControlled`) |
| `book_details_table.dart` | `BookDetailsTable` | «Детали» w600; строки 14, разделитель `ln`: «Формат», «Размер файла» (скрыта при `sourceSize == null`), «Язык» (название или «Не определён» `mu`), «Добавлена» (`DateFormat.yMMMd(locale)`) |

Общие хелперы `lib/ui/core/` (*решение аналитика*, DRY):
- `file_size_label.dart`: `String fileSizeLabel(AppLocalizations l10n, int bytes)` — перенос формулы из
  `ImportMessageDialog` (`bytes / 1 048 576` → `fileSizeMb`); диалог импорта переходит на хелпер.
- `language_label.dart`: `String? languageLabel(BuildContext context, String? tag)` — `null`/пустой тег → `null`;
  тег нормализуется (обрезка пробелов, `-` → `_`, язык — строчными, регион — заглавными: `EN-us` → `en_US`), ищется `LocaleNames.of(context)?.nameOf(tag)`, затем по основной части тега
  (`en_US` → `en`), иначе — сам тег; первая буква заглавная (в CLDR «русский» строчными). Без `!`.
- `LocaleNamesLocalizationsDelegate()` добавляется в `localizationsDelegates` приложения и `pumpApp`.

### ARB (`lib/l10n/app_ru.arb`, `app_en.arb`)

| Ключ | ru | en |
|---|---|---|
| `bookActionsTitle` (семантика диалога) | Действия с книгой | Book actions |
| `bookActionDetails` / `bookActionDelete` / `bookActionClose` | Информация о книге / Удалить книгу / Закрыть | Book info / Delete book / Close |
| `bookDeleteTitle` | Удалить книгу? | Delete the book? |
| `bookDeleteMessage` | `«{title}» исчезнет из библиотеки вместе с прогрессом чтения. Исходный файл на телефоне не изменится.` | `“{title}” will be removed from the library along with reading progress. The original file on your phone stays unchanged.` |
| `bookDeleteCancel` / `bookDeleteConfirm` | Отмена / Удалить | Cancel / Delete |
| `bookDeleted` / `bookDeleteFailed` | Книга удалена / Не удалось удалить книгу | Book deleted / Couldn’t delete the book |
| `bookBack` (семантика) | Назад | Back |
| `bookNoAuthor` | Автор не указан | Author unknown |
| `bookNotStarted` / `bookReadPercent` / `bookFinished` | Не начата / `Прочитано {percent}%` / Прочитана | Not started / `{percent}% read` / Finished |
| `bookStartReading` / `bookContinueReading` | Начать чтение / Продолжить чтение | Start reading / Continue reading |
| `bookAbout` / `bookReadMore` / `bookNoDescription` | Об этой книге / Читать полностью / В файле нет описания. | About this book / Read more / The file has no description. |
| `bookDescriptionNote` / `bookDescriptionClose` | Текст взят из метаданных файла и показан как есть. / Закрыть | Taken from the file’s metadata and shown as is. / Close |
| `bookDetailsTitle` | Детали | Details |
| `bookDetailFormat` / `bookDetailSize` / `bookDetailLanguage` / `bookDetailAdded` | Формат / Размер файла / Язык / Добавлена | Format / File size / Language / Added |
| `bookLanguageUnknown` | Не определён | Unknown |

Название в `bookDeleteMessage` — `displayTitle` («Без названия» для пустого).

## Тесты

Порядок TDD: Rust (модель → описание → пакет → мост) → Drift и репозиторий → ViewModel → виджеты → golden.
Каждый новый тест сначала падает (RED).

Rust:

| Тест | Что проверяет | Вход → ожидаемый результат |
|---|---|---|
| `model.rs`: `golden_fixture_matches` (существующий) | совместимость | эталон без изменений; `decode` даёт `description: None` |
| `model.rs`: `description_roundtrips` | новое поле | `sample_book()` с `Some("A\n\nB")` → `decode(encode(b)) == b` |
| `model.rs`: `absent_description_is_not_encoded` | `skip_serializing_if` | книга с `None` → в CBOR нет ключа `description` (байты равны эталону) |
| `epub/description.rs`: `strips_tags_into_paragraphs` | HTML | `<p>Один</p><p>Два <b>три</b></p>` → `"Один\n\nДва три"` |
| `…`: `br_and_div_split_paragraphs` | HTML | `a<br/>b<div>c</div>` → `"a\n\nb\n\nc"` |
| `…`: `decodes_entities` | сущности | `A&amp;B&nbsp;C &#8212; &#x2014; &foo;` → `"A&B C — — &foo;"` |
| `…`: `plain_text_is_kept` | без HTML | `"  Просто   текст \n"` → `"Просто текст"` |
| `…`: `empty_becomes_none` | края | `""`, `"<p> </p>"` → `None` |
| `…`: `unclosed_tag_is_dropped` | битый вход | `"текст <b"` → `"текст"` |
| `…`: `long_text_is_truncated` | огромный вход | 20 000 символов `я` → 10 000 символов + `…`, без паники на многобайтовых символах |
| `epub_package.rs`: `reads_description` | OPF | фикстура OPF с `<dc:description>&lt;p&gt;X&lt;/p&gt;</dc:description>` → `meta.description == Some("X")` |
| `epub_package.rs`: `first_description_wins` / `no_description_is_none` | OPF | два `dc:description` → первый; нет → `None` |
| `bridge/src/api/book.rs`: `book_meta_reads_fixture` (существующий) | мост | + `meta.description == None` |
| `bridge/src/api/book.rs`: `book_meta_reads_description` | мост | `encode` книги с `Some("D")` → `book_meta(..).description == Some("D")` |

Фикстуры EPUB собираются в тесте из строк, как в существующих `epub_package.rs` (в репозиторий не кладутся
материалы корпуса).

Flutter:

| Тест | Что проверяет | Вход → ожидаемый результат |
|---|---|---|
| `app_database_test`: `migrates v1 to v2` | миграция | файл БД v1 (таблица `books` по схеме v1 через `NativeDatabase(file, setup:)`, `PRAGMA user_version = 1`, одна строка) → `AppDatabase` открывается, строка читается, `description` и `sourceSize` — null, `schemaVersion` 2 |
| `book_repository_test`: `add stores description and size` | запись | `bookMeta` фейка с `description: 'D'`, `add(..., sourceSize: 42)` → `BookEntry.description == 'D'`, `sourceSize == 42` |
| `book_repository_test`: `add without size stores null` / `negative size stores null` | края | без `sourceSize` / `-1` → `null` |
| `book_repository_test`: `revived book gets fresh metadata` | возврат | add (desc A, size 1) → delete → add (desc B, size 2) → тот же id, B, 2 |
| `book_repository_test`: `live duplicate is returned unchanged` | решение 3 | add (A) → add того же хеша с B → A |
| `book_repository_test`: `watch emits book then null after delete` | watch | `watch(id)` → книга; `delete(id)` → `null`; неизвестный id → `null` |
| `import_view_model_test`: `passes source size to add` | импорт | `ImportSource(sizeBytes: 1234)` → журнал `add` фейка с `sourceSize: 1234` |
| `library_view_model_test`: `deleteBook deletes and returns true` | удаление | → `delete(id)` 1 раз, `true`; после выдачи нового списка книги нет в state |
| `library_view_model_test`: `deleteBook returns false on error` | ошибка | фейк `delete` бросает → `false`, state не в `AsyncError` |
| `book_details_view_model_test`: `follows the book and becomes null on delete` | VM | книга → `AsyncData(book)`; удалили → `AsyncData(null)` |
| `reader_placeholder_view_model_test` (существующий) | переход на `watch` | поведение прежнее |
| `language_label_test`: `names known tags` | язык | локаль ru: `ru` → «Русский», `en` → «Английский», `EN` → «Английский»; локаль en: `ru` → «Russian»; `qq-ZZ` (нет в данных) → `qq-ZZ`; `null` и `''` → null |
| `file_size_label_test`: `formats megabytes` | размер | 1 887 437 → «1,8 МБ» (ru), «1.8 MB» (en) |
| `book_actions_dialog_test`: `long press opens actions` | меню | долгое нажатие на `BookCard` → `book_actions` с названием и автором; то же для `ContinueReadingCard` |
| `book_actions_dialog_test`: `tap still opens reader` | регресс | тап по `BookCard` → `reader_placeholder` |
| `book_actions_dialog_test`: `close does nothing` | меню | `book_action_close` → диалог закрыт, `delete` не вызывался, маршрут прежний |
| `book_actions_dialog_test`: `details opens book card` | навигация | `book_action_details` → `book_details`; «Назад» → `library_screen` |
| `delete_book_dialog_test`: `cancel keeps the book` | подтверждение | `book_action_delete` → текст с названием → `delete_cancel` → `delete` не вызывался |
| `delete_book_dialog_test`: `confirm deletes and shows snackbar` | удаление | `delete_confirm` → `delete(id)` 1 раз, SnackBar «Книга удалена», карточки книги нет в сетке |
| `delete_book_dialog_test`: `delete failure shows snackbar` | ошибка | фейк бросает → SnackBar «Не удалось удалить книгу», книга на месте |
| `delete_book_dialog_test`: `untitled book in message` | края | title '' → «Без названия» в тексте |
| `library_screen_test`: `delete during import keeps import card` | импорт | `running` + удаление другой книги → `importing_book` на месте, импорт не отменён |
| `book_details_screen_test`: `shows full card` | макет `book-card` | книга 34%, описание, размер 1 887 437, `ru`, дата → название, авторы, «EPUB · 1,8 МБ · Русский», «Прочитано 34%», «Продолжить чтение», 4 строки деталей, дата `DateFormat.yMMMd('ru')` |
| `book_details_screen_test`: `shows empty card` | макет `book-card-empty` | авторов нет, описания нет, языка нет, fresh → «Автор не указан», «В файле нет описания.» без `book_read_more`, «Не определён», «Не начата», «Начать чтение» |
| `book_details_screen_test`: `hides size when unknown` | решение 2, 3 | `sourceSize: null` → нет строки «Размер файла», в подписи нет размера |
| `book_details_screen_test`: `finished book` | статус | progress 1 → «Прочитана», «Продолжить чтение» |
| `book_details_screen_test`: `read more only when text overflows` | ссылка | короткое описание → нет `book_read_more`; 600 символов → есть |
| `book_details_screen_test`: `read more opens description sheet` | лист | `book_read_more` → `book_description` с абзацами и сноской; `book_description_close` → лист закрыт |
| `book_details_screen_test`: `read button opens reader` | навигация | `book_read` → `reader_placeholder`; «Назад» → `book_details` |
| `book_details_screen_test`: `deleted book shows not found` | Review Focus | книга исчезла из потока → `book_not_found` без исключения |
| `book_details_screen_test`: `unknown id shows not found` | края | `/book/x` → `book_not_found` |
| `book_details_screen_test`: `tablet centers content` | планшет | 820×1180 → ширина колонки ≤ 600, по центру |
| `book_details_screen_test`: `text scale 2 does not overflow` | шрифт 200% | `TextScaler.linear(2)`, 390×844: карточка, диалог действий, подтверждение, лист описания — без `FlutterError` переполнения |
| `app_router_test`: `book details route is outside the shell` | маршрут | `/book/x` → нет `NavigationBar` / `NavigationRail` |
| `import_message_dialog_test` (существующий) | DRY-перенос | «PDF · 18,4 МБ …» прежнее |
| `book_actions_golden_test` (тег `golden`) | вид | `book_actions_phone_light`, `book_actions_phone_dark`, `book_delete_phone_light`, `book_delete_phone_dark`, `book_card_phone_light`, `book_card_phone_dark`, `book_card_empty_phone_light`, `book_description_phone_dark`, `book_card_tablet_light` |

Golden — как в библиотеке: тег `golden`, эталоны в `test/ui/book_details/goldens/` и `test/ui/library/goldens/`,
встроенные шрифты, CI пропускает. Тестовые названия и авторы — выдуманные («Пример книги», «А. Автор»), не из
корпуса и не из макета.

## Критерии приёмки

- Из `rust/`: `cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test` — зелёные;
  `git diff main...HEAD -- rust/flow-core/tests/fixtures/book_v1.cbor` пустой; `FORMAT_VERSION == 1`.
- `flutter_rust_bridge_codegen generate` и `dart run build_runner build -d` после коммита не дают изменений.
- `dart format --set-exit-if-changed lib test integration_test test_driver tool && dart analyze --fatal-infos &&
  flutter test` — зелёные; `flutter test --tags golden` проходит локально.
- Покрытие `rust/flow-core`, `rust/bridge`, `lib/domain`, `lib/data`, `lib/ui/**/view_models`, `lib/utils` ≥ 85%,
  нового кода ≥ 85%.
- Архитектурный тест проходит; `flutter_localized_locales` есть в `pubspec.yaml` и в разделе лицензий README.
- `flutter build apk --flavor store --release` собирается (после `flutter clean`).
- QA на Pixel 7, скриншоты в PR (светлая и тёмная темы):
  1. обновление поверх сборки 3.2 с книгами: приложение стартует, книги на месте; карточка старой книги —
     «В файле нет описания.», без размера;
  2. EPUB с описанием → долгое нажатие → меню → «Информация о книге» → карточка: описание в 2 строки,
     «Читать полностью» → лист с полным текстом без HTML-тегов; размер совпадает с размером файла в «Файлах»;
     язык названием;
  3. «Начать / Продолжить чтение» → заглушка читалки; «Назад» → карточка → «Назад» → библиотека;
  4. долгое нажатие → «Удалить книгу» → «Отмена» → книга на месте; снова → «Удалить» → SnackBar «Книга
     удалена», книги нет, исходный файл в «Файлах» на месте;
  5. удалить книгу из «Продолжить чтение» — блок переходит к следующей читаемой книге или исчезает;
  6. удалить и добавить тот же файл заново → книга с прогрессом 0;
  7. во время импорта удалить другую книгу → импорт продолжается и завершается;
  8. системный шрифт 200%: меню, подтверждение, карточка и лист читаются без обрезки;
  9. планшет или широкое окно (эмулятор, если нет устройства): карточка по центру, не шире 600.

## Review Focus

- Совместимость формата: книга без `description` кодируется байт в байт как раньше; старая сборка (без поля)
  читает новую книгу (serde игнорирует неизвестные поля — проверить, что `deny_unknown_fields` нигде нет).
- Очистка описания: битый HTML, вложенные теги, `<script>`/`<style>` (содержимое остаётся текстом — допустимо,
  разметка не исполняется: Flutter `Text`), CDATA, огромное описание, многобайтовые символы на границе обрезки.
- Миграция: открытие v1 → v2 не теряет строки и прогресс; повторное открытие v2 не повторяет `addColumn`.
- Удаление: двойной тап «Удалить» (диалог закрывается первым тапом), удаление книги, открытой в карточке
  (поток даёт `null` → «Книга не найдена»), удаление во время импорта того же файла (после `converted` книга
  возвращается с тем же id и прогрессом 0 — ожидаемо), ошибка `delete` не роняет экран.
- `BuildContext` после `await` в `showBookActions`: проверка `context.mounted` перед навигацией и SnackBar.
- SnackBar показывается через `ScaffoldMessenger` библиотеки и не теряется при закрытии диалога.
- Нет `!` при `LocaleNames.of(context)`; неизвестный тег не роняет экран.
- Шрифт 200% и планшет; все строки из ARB, в том числе семантика кнопок.

## Решения, принятые на гриллинге

Решения человека — раздел выше. Решения аналитика:

| Вопрос | Решение | Почему |
|---|---|---|
| Где чистить HTML описания | `import/epub/description.rs` | у FB2 аннотация — структурный XML, общий код не нужен |
| Лимит описания | 10 000 символов + `…` | защита от огромных метаданных; лист всё равно прокручивается |
| Версия EPUB-конвертера | минорное повышение | книга из того же файла изменилась |
| Книга по id | `BookRepository.watch(id)`, заглушка читалки переходит на него | одно место вместо двух фильтров `watchAll` |
| Где вызывается удаление | `LibraryViewModel.deleteBook` → `bool` | View ↔ ViewModel один к одному; ошибка показывается, а не глотается |
| Поток диалогов | функция `showBookActions` в `book_actions_flow.dart` | это навигация, а не логика; вызывается из сетки и «Продолжить чтение» |
| Долгое нажатие на «Продолжить чтение» | то же меню | книга та же, пользователь ожидает одинакового поведения |
| Маршрут карточки | `/book/:bookId` вне оболочки | в макете нет нижней панели, как у читалки |
| Кнопка чтения у прочитанной книги | «Продолжить чтение» | в макетах только два варианта; «С начала» убрано тимлидом |
| «Читать полностью» | только если текст не влез в 2 строки | короткому описанию ссылка не нужна |
| Формат даты | `DateFormat.yMMMd(locale)` | готовый формат `intl`, близкий к макету |
| Размер файла | общий `fileSizeLabel`, перенос из диалога импорта | DRY |
| Ширина карточки на планшете | не шире 600 по центру | в макетах планшета нет; длинные строки деталей плохо читаются |
| Отрицательный размер от провайдера | `null` | кривой внешний вход |
| Миграции drift | один `onUpgrade` без `make-migrations` | одна миграция, проверяется тестом |

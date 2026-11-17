# Тесты хранилища на Windows: спека

**Задача плана:** 3.4 «Тесты хранилища на Windows» (fix, план 2, блок «Библиотека»; найдено в QA PR #11)
**Стек:** Flutter
**Ветка:** `fix/windows-storage-tests`
**Статус:** черновик, ждёт подтверждения человеком

## Цель

`flutter test` проходит на Windows 11 (машина разработки), локальный pre-commit снова пропускает Dart-коммиты.
Заодно на Windows начинает работать уборка «сирот» в `LocalBookRepository`: сейчас она там, по гипотезе, тихо
ничего не удаляет.

## Гипотеза (не проверена: вывода упавших тестов с Windows нет)

На Windows падают 7 тестов из `test/data/services/book_file_service_test.dart` и
`test/data/repositories/book_repository_test.dart`; в CI на Linux они зелёные. Ниже — разбор по коду, без
прогона на Windows.

**Причина.** `BookFileService` собирает путь каталога как `'${root.path}/books'`. На Windows
`Directory.list()` приклеивает к этому пути имя через `\`: `C:\…\Temp\book_files_x/books\a.cbor`.
`BookFileService._name` (`lib/data/services/book_file_service.dart`) ищет последний `/` и отдаёт `books\a`
вместо `a`. Отсюда:

- `ids()` возвращает `books\<id>` вместо `<id>`;
- уборка «сирот» в `LocalBookRepository._removeOrphans` считает все файлы чужими и вызывает
  `delete('books\<id>')` — путь не существует, `PathNotFoundException` глотается, файлы остаются. Живые книги
  при этом не удаляются (поэтому вреда данным нет), но и настоящие сироты не убираются.

**Ожидаемые 7 падений:**

| Файл | Тест | Почему падает |
|---|---|---|
| `book_file_service_test` | `write then read returns same bytes` | **тест** делит путь `split('/')` и получает `books\a.cbor` |
| `book_file_service_test` | `ids lists only cbor files` | `ids()` → `['books\a']` |
| `book_file_service_test` | `deleteTemp removes tmp files and keeps cbor` | то же, через `ids()` |
| `book_repository_test` | `add stores entry and file` | `files.ids()` → `['books\<id>']` |
| `book_repository_test` | `concurrent add of the same bytes yields one book` | то же |
| `book_repository_test` | `orphans are removed on first call` | сирота `y.cbor` не удалена (`delete('books\y')` промахивается) |
| `book_repository_test` | `orphans are swept once, before the first operation` | `files.ids()` с префиксом `books\` |

Проверено по коду и, по разбору, на Windows не мешает: `File.rename` поверх существующего `<id>.cbor`
(Dart заменяет файл), `\r\n` (текстовых файлов нет), регистр имён (uuid в нижнем регистре), удаление временного
каталога в `tearDown` (база закрывается раньше `deleteSync`), смешанные `/` и `\` в путях, которые мы сами
собираем (Windows их принимает).

## Границы

В задаче:
- разбор имени файла в `BookFileService` без зависимости от разделителя пути;
- правка теста `write then read returns same bytes` (сам делит путь по `/`);
- фактический список падений на Windows до и после правки — в описании PR.

Не в задаче:
- Windows-раннер в CI — решение человека 2026-11-17: не добавляем (см. «Решения»);
- `package:path` как прямая зависимость, фейковая файловая система — не нужны;
- переделка сборки путей (`'${dir.path}/books'`, `'${dir.path}/$id$ext'`) на `\` — Windows принимает смешанные
  разделители, это не причина падений;
- остальные тесты, падающие на Windows по другим причинам, если найдутся, — не чинятся наугад, см. шаг 1.

## Интерфейсы

Публичный API не меняется: `BookFileService.write / read / delete / ids / deleteTemp`, `BookRepository` —
как в спеке 3.1 (`docs/specs/2026-11-12-book-storage.md`).

Меняется только приватный разбор имени (решение аналитика): имя файла берётся из `entity.uri.pathSegments.last`
(стандартная библиотека; `Uri` файла разбирает и `/`, и `\` на Windows), затем отрезается расширение.
`lastIndexOf('/')` по пути в `lib/data/services/book_file_service.dart` не остаётся. В тесте
`write then read returns same bytes` имя файла — тоже через `e.uri.pathSegments.last`, а не `split('/')`.

## Порядок работы разработчика (на Windows-машине)

1. **До правки** — `flutter test test/data`. Список упавших тестов и их сообщения — в описание PR (раздел
   «До правки»). Это и есть RED для баг-фикса (AGENTS.md, раздел 6).
   - Падения совпадают с таблицей гипотезы — дальше по шагам.
   - Падений больше, меньше или другие причины — **остановиться и идти к человеку** за уточнением спеки,
     не чинить наугад.
2. Правка теста `write then read returns same bytes` и `_name` в `BookFileService` — по «Интерфейсам».
3. **После правки** — `flutter test` целиком на Windows; вывод (итоговая строка `All tests passed!` и список
   файлов) — в описание PR (раздел «После правки»).
4. Pre-commit на Windows проходит без обхода; CI на Linux зелёный.

## Тесты

Новых тестов нет: RED воспроизводят существующие 7 тестов на Windows (решение человека — без имитации Windows
на Linux).

| Тест | Что проверяет | Вход → ожидаемый результат |
|---|---|---|
| `write then read returns same bytes` (правка) | файл лежит под именем `<id>.cbor` | `write('a', [1,2,3])` → имена в `books/` по `uri.pathSegments.last` = `['a.cbor']` |
| `ids lists only cbor files` | `ids()` отдаёт голые id | `a.cbor`, `b.cbor.tmp` → `['a']` на Windows и Linux |
| `deleteTemp removes tmp files and keeps cbor` | уборка `.tmp` | → `ids() == ['a']`, в каталоге 1 файл |
| `orphans are removed on first call` | сироты удаляются на Windows | `x.cbor.tmp`, `y.cbor` без строки в базе → каталог пуст |
| остальные 3 из таблицы гипотезы | `ids()` без префикса каталога | как в спеке 3.1 |

Проверка «тест падает без правки» — шаг 1 на Windows (те же тесты красные до правки).

## Критерии приёмки

- На Windows 11 до правки: список упавших тестов и сообщения — в PR; совпадает с таблицей гипотезы (иначе —
  к человеку, см. шаг 1).
- На Windows 11 после правки: `flutter test` → `All tests passed!`, вывод в PR. Проверяет разработчик/человек
  на Windows-машине.
- CI (Linux): все job зелёные, включая `dart format --set-exit-if-changed …`, `dart analyze --fatal-infos`,
  `flutter test --coverage`, порог покрытия 85%.
- Pre-commit на Windows пропускает коммит с правкой без `--no-verify`.
- В `lib/data/services/book_file_service.dart` нет разбора пути по `'/'`.

QA на Pixel 7 не нужен: поведение на Android (разделитель `/`) не меняется.

## Review Focus

- Регресс под Windows CI не ловит (Windows-раннера нет, решение человека). Ревьюер смотрит, что разбор имени
  не зависит от разделителя ни в коде, ни в тестах `test/data/**` (нет `split('/')`, `lastIndexOf('/')`,
  `endsWith('/…')` по путям из листинга).
- Имя файла с несколькими точками (`b.cbor.tmp`): `ids()` его не берёт, `deleteTemp` удаляет — поведение 3.1
  не меняется.
- `uri.pathSegments` декодирует `%xx`: id у нас — uuid, но ревьюер проверяет, что id из `ids()` совпадает с id
  при `write` на Linux (существующие тесты).

## Решения, принятые на гриллинге

| Вопрос | Решение | Почему |
|---|---|---|
| Есть ли вывод упавших тестов с Windows? | Нет; спека по гипотезе, первый шаг разработчика — снять фактический список | Решение человека 2026-11-17 |
| Как CI ловит Windows-регресс: Windows-job / чистая функция с `package:path` / фейковая ФС? | Никак: Windows-job не добавляем, зависимостей нет; проверка вручную на Windows до и после правки | Решение человека 2026-11-17 («проверим просто на windows»). Риск: регресс под Windows CI не ловит |
| Чем разбирать имя файла? | `entity.uri.pathSegments.last` | Решение аналитика: стандартная библиотека, без новой зависимости, разбирает оба разделителя |
| Чинить код или тесты? | Оба: код (`_name`) — баг и в приложении (сироты не убираются); тест `write then read` — сам делит по `/` | Решение аналитика по разбору кода |

# Импорт EPUB (`flow-core`): спека

**Задача плана:** 4.1 «Импорт EPUB (`flow-core`)» (план 2, блок «Импорт и прогресс конвертации»)
**Стек:** Rust (`flow-core`; в `bridge` — одна строка выбора конвертера)
**Ветка:** `feat/epub-import`
**Статус:** черновик, ждёт валидации человеком (открытые вопросы — раздел «Вопросы человеку»)

## Цель

Файл EPUB 2 или EPUB 3 импортируется через существующий `import_book` и превращается в `Book` (блоки v1):
метаданные, оглавление, главы с абзацами, заголовками, списками, цитатами, картинками, сносками и мягкими
переносами. Кривой файл даёт понятную ошибку, а не падение. Это первый настоящий конвертер: на нём задача
3.2 + 4.3 впервые положит в библиотеку реальную книгу.

## Границы

В задаче:
- модуль `rust/flow-core/src/import/epub/` и тип `EpubConverter`, реализующий трейт `Converter`;
- чтение zip, `META-INF/container.xml`, OPF (метаданные, manifest, spine, обложка), оглавления
  (EPUB 3 `nav`, EPUB 2 `toc.ncx`), глав XHTML → блоки;
- картинки → `Resource`, сноски → `Block::Footnote` + `Inline::NoteRef`, внутренние ссылки → `LinkTarget::Internal`;
- переносы через `text::Hyphenator`; SHA-256 исходника в `Book::source_hash`;
- прогресс по главам spine, отмена между главами;
- пределы на размер распакованных данных и глубину вложенности (Review Focus 1);
- синтетические фикстуры и тесты; выбор конвертера в мосте (`converter_for`).

Не в задаче (и где это делается):
- FB2 / `.fb2.zip` — 4.2;
- экран импорта, выбор файла, запись в библиотеку — 3.2 + 4.3 (они потребляют `ImportEvent::Done` как есть);
- EPUB с фиксированной вёрсткой (`rendition:layout="pre-paginated"`) как картинки страниц (`Block::FixedPage`) —
  требует рендера XHTML в картинку, в `flow-core` его нет; такие книги в 4.1 импортируются как обычные
  (страницы из одной картинки естественно становятся `Figure`). Полноценная поддержка — план 3 или позже;
- CSS (центр, отступ, `font-weight` из стилей): в модели v1 нет полей выравнивания/отступа, а поднимать
  `FORMAT_VERSION` ради этого — не цель 4.1. Стиль символов берётся только из тегов;
- MathML как картинка, `colspan` / `rowspan` — упрощённо (см. «Правила преобразования»);
- DRM (Adobe ADEPT, LCP) — не снимаем, такие книги отклоняются ошибкой;
- границы глав в модели (для `ReadingPosition` «индекс главы») — решает спека 5.2 (из `toc` / заголовков);
- отдельные варианты ошибок «слишком большой файл», «DRM» — задача 7, если человек не решит иначе (вопрос 3).

## Вопросы человеку (до старта разработки)

### Вопрос 1. Новые зависимости `flow-core`

Нужны: zip, XML-парсер, SHA-256. Все кандидаты — чистый Rust (без C-библиотек), собираются cargokit под
Android (`aarch64-linux-android`, `armv7`, `x86_64`) без дополнительной настройки; лицензии совместимы с
GPL-3.0-only (их надо дописать в NOTICE/README).

| Назначение | Кандидат | Лицензия | За | Против |
|---|---|---|---|---|
| zip | **`zip`** (`default-features = false`, `features = ["deflate"]` с чистым Rust-бэкендом) | MIT | стандарт де-факто, `Read + Seek`, читает размеры записей до распаковки (защита от zip-бомб) | дефолтные фичи тянут C (`bzip2-sys`, `zstd-sys`) — **их выключаем**; частые мажорные версии |
| zip (альт.) | `rc-zip` / `rc-zip-sync` | MIT / Apache-2.0 | sans-io, аккуратный разбор битых архивов | меньше пользователей, нет записи (для фикстур всё равно нужен `zip` в dev) |
| XML / XHTML | **`quick-xml`** | MIT | один быстрый потоковый парсер на всё (container, OPF, NCX, nav, главы); маленький; EPUB по стандарту — XHTML, т. е. XML | HTML-сущности (`&nbsp;`, `&mdash;`) без DTD не знает — нужна своя таблица сущностей HTML4 (253 штуки, константа); на сильно битом XHTML останавливается (обрабатываем: см. «Ошибки») |
| HTML (альт.) | `html5ever` + `markup5ever_rcdom` (или `scraper`) | MIT / Apache-2.0 (`scraper` — ISC) | так записано в спеке MVP; разбирает любой битый HTML как браузер, знает все сущности | заметно тяжелее (`string_cache`, `phf`, `tendril`, ~+0,5–1 МБ в `.so`), `rcdom` помечен «не для продакшена»; для OPF/NCX всё равно нужен XML-парсер — два парсера |
| XML (альт.) | `roxmltree` | MIT / Apache-2.0 | удобное DOM-дерево для OPF/NCX/nav | только чтение целиком; главы им разбирать хуже; ещё одна зависимость, если брать вместе с html5ever |
| готовый EPUB | `epub` (epub-rs) | GPL-3.0 | открывает EPUB, отдаёт spine/метаданные | тянет `xml-rs` и свой zip, не даёт контроля пределов и ошибок, главы всё равно разбираем сами — экономии почти нет |
| SHA-256 | **`sha2`** (RustCrypto) | MIT / Apache-2.0 | стандарт, чистый Rust, потоковый хеш | — (альтернатива — писать хеш самим, нельзя) |
| dev: фикстуры | `zip` с фичей записи в `[dev-dependencies]` | MIT | пакуем фикстуры из папок прямо в тестах | — |

**Рекомендация аналитика:** `zip` (без дефолтных фич) + `quick-xml` + `sha2`; в dev — `zip` с записью.
Почему: три небольших крейта, один парсер на всё, предсказуемые ошибки. `html5ever` берём, только если человек
считает главным «открыть любой битый EPUB любой ценой». Версии — последние стабильные на момент работы
разработчика.

### Вопрос 2. Модель CBOR и API моста — не меняются

Спека укладывается в блоки v1 и текущий `import_book` без изменений: `FORMAT_VERSION` остаётся 1,
`ImportEvent` / `ImportError` / `SourceKind` не трогаем. В мосте меняется только тело `pub(crate) fn converter_for`
(не API), но по правилу AGENTS.md (раздел 8) любая правка в `rust/bridge/src/api/` меняет отпечаток —
разработчик перегенерирует мост и коммитит результат. Два места, где 4.1 опирается на договорённость, а не на поле
модели, — подтвердите:
- **`<br>` → `\n` внутри `Inline::Text`.** Иначе стихи и адреса склеиваются в одну строку. Это требование к
  разрыву строк 5.1: `\n` — принудительный перенос. Альтернатива — разбивать абзац на несколько
  `Paragraph` (теряется «одна строфа = один абзац»). **Рекомендация: `\n`.**
- **Нет названия в OPF → `Meta.title = ""`**, экран библиотеки (3.2) показывает свою заглушку из ARB.
  Альтернатива — имя файла, но конвертер получает только байты, без имени. **Рекомендация: пустая строка.**

### Вопрос 3. Ошибки «слишком большой» и «DRM» — без новых вариантов `ImportError`

Новый вариант `ImportError` — изменение API импорта и моста (зеркало в `bridge`, Dart-код 4.3).
**Рекомендация:** в 4.1 оба случая — `ImportError::Corrupted(<сообщение>)` с фиксированными текстами (ниже),
отдельные варианты — в задаче 7 «Ошибки и пустые состояния», когда будет ясно, что показывать пользователю.
Альтернатива — сразу добавить `TooLarge` и `Encrypted` (тогда правится мост и Dart-зеркало в этой задаче).

## Интерфейсы

### Производит

```rust
// rust/flow-core/src/import/mod.rs — добавить:
mod epub;
pub use epub::EpubConverter;

// rust/flow-core/src/import/epub/mod.rs
/// Imports EPUB 2 / EPUB 3 into blocks v1.
pub struct EpubConverter;

impl Converter for EpubConverter {
    fn convert(
        &self,
        src: &mut dyn ReadSeek,
        kind: SourceKind,
        progress: &mut dyn FnMut(Progress),
        cancel: &CancelToken,
    ) -> Result<Book, ImportError>;
}
```

- `kind != SourceKind::Epub` → `Err(ImportError::Unsupported(kind))` сразу, без чтения `src` и без событий.
- `Book::format_version = FORMAT_VERSION`; `Book::converter_version = EPUB_CONVERTER_VERSION`, константа
  `pub const EPUB_CONVERTER_VERSION: &str = concat!("epub/", env!("CARGO_PKG_VERSION"));` (реэкспорт из `import`)
  — *решение аналитика*: по ней библиотека позже поймёт, какие книги переконвертировать;
- `Book::source_hash` — SHA-256 всех байтов `src` (с начала, независимо от текущей позиции), 64 символа hex в
  нижнем регистре; после хеша `src` перематывается в начало;
- `BlockNode::src = None` для всех блоков (привязка к странице — только для PDF).

Мост, `rust/bridge/src/api/import.rs`:
```rust
pub(crate) fn converter_for(kind: SourceKind) -> Box<dyn Converter> {
    match kind {
        SourceKind::Epub => Box::new(EpubConverter),
        _ => Box::new(StubConverter),
    }
}
```
Комментарий у функции обновить (FB2 подключит 4.2, PDF — план 3).

### Потребляет
- `flow_core::import::{Converter, ReadSeek, Progress, Stage, CancelToken, ImportError, SourceKind}` — как есть;
- `flow_core::model::*` — как есть;
- `flow_core::text::Hyphenator` — один экземпляр на вызов `convert` (`Hyphenator::new()` дорогой; ошибка словаря
  → `ImportError::Corrupted("hyphenation dictionary: …")`, на деле не возникает).

### Раскладка модуля (*решение аналитика*, файлы ≤ ~400 строк)

```
import/epub/
├── mod.rs        EpubConverter::convert: порядок шагов, прогресс, отмена, сборка Book
├── archive.rs    обёртка над zip: поиск записи по пути, чтение с пределами
├── path.rs       разрешение href относительно файла, %-декодирование, отсечение #фрагмента
├── package.rs    container.xml + OPF: метаданные, manifest, spine, обложка
├── toc.rs        nav (EPUB 3) и NCX (EPUB 2) → черновое оглавление с href
├── xhtml.rs      глава XHTML → черновые блоки (ссылки ещё как href)
├── entities.rs   таблица HTML4-сущностей (если выбран quick-xml)
└── resolve.rs    второй проход: href → индекс блока, сноски, ресурсы, оглавление
```

### Порядок работы `convert`

1. `kind` ≠ `Epub` → `Unsupported`.
2. SHA-256 источника, перемотка в начало.
3. Открыть zip; найти `META-INF/container.xml` → путь первого `rootfile` с `media-type="application/oebps-package+xml"`
   (или первого `rootfile`, если `media-type` нет).
4. Разобрать OPF: метаданные, manifest (id → href, media-type, properties), spine (`itemref idref`, все
   элементы, включая `linear="no"`, в порядке spine), обложка.
5. Проверить `META-INF/encryption.xml`: если зашифрован хотя бы один документ spine → ошибка DRM. Записи с
   обфускацией шрифтов (`http://www.idpf.org/2008/embedding`, `http://ns.adobe.com/pdf/enc#RC`) не мешают — шрифты
   мы не читаем.
6. Для каждой главы spine (`total` = число элементов spine): проверить `cancel` → разобрать главу →
   `progress(Progress { stage: Stage::Pages, done: i, total })` (`i` с 1).
7. Проверить `cancel`; второй проход (ссылки, сноски, оглавление, ресурсы); переносы.
8. Вернуть `Book`.

Других событий прогресса нет (`Sampling` / `Assembling` EPUB не использует — *решение аналитика*: второй проход
быстрый, отдельная стадия только добавит шагов экрану 4.3).

## Правила преобразования

### Метаданные (`Meta`)
- `title` — текст первого `dc:title`, пробелы схлопнуты и обрезаны; нет → `""` (вопрос 2).
- `authors` — все `dc:creator` по порядку, кроме тех, у которых роль явно задана и не `aut`
  (EPUB 2: атрибут `opf:role`; EPUB 3: `<meta refines="#id" property="role">`). Пустые строки отбрасываются,
  повторы — тоже (первое вхождение остаётся).
- `language` — первый непустой `dc:language` (обрезанный), иначе `None`.
- `cover` — картинка из manifest с `properties` содержащим `cover-image` (EPUB 3), иначе
  `<meta name="cover" content="<id>">` (EPUB 2), если этот id в manifest и это картинка. Иначе `None`.
  Обложка — первый ресурс (`ResourceId(0)`), даже если в тексте не встречается.

### Пути и ссылки
- href разрешается относительно файла, где он записан (OPF — относительно OPF; глава — относительно главы),
  с `.` и `..`; выход выше корня архива → ссылка считается битой.
- %-кодирование декодируется (`chapter%201.xhtml`); `#фрагмент` отделяется.
- Поиск записи в zip: сначала точное имя, затем без учёта регистра (*решение аналитика*: частая ошибка
  сборщиков EPUB на Windows).
- Схемы `http:`, `https:`, `mailto:` → `LinkTarget::External(href как в файле)`. Прочие схемы
  (`javascript:`, `file:` и т. п.) → ссылка снимается, текст остаётся.

### Главы: теги → блоки
- Кодировка: UTF-8 (BOM отбрасывается); невалидные байты → U+FFFD, глава не отбрасывается. UTF-16 — тоже
  допустим по стандарту EPUB, распознаётся по BOM и декодируется `String::from_utf16_lossy` (без новых зависимостей).
- Пробелы: последовательности XML-пробелов (пробел, `\t`, `\r`, `\n`) → один пробел; по краям блока обрезаются.
  NBSP (U+00A0) и прочие пробелы Unicode сохраняются. Внутри `<pre>` пробелы и переводы строк не трогаются.
- Пропускаются целиком: `head`, `script`, `style`, `template`, `rt`, `rp`, `svg` (кроме `<image>` внутри — см.
  картинки). У `math` берётся текст (известная потеря из спеки MVP).
- `h1`…`h6` → `Heading { level: min(n, 4) }`.
- `p`, а также текст, лежащий прямо в `body` / `div` / `section` и т. п. → `Paragraph`. Пустые (после обрезки)
  абзацы не создаются.
- `blockquote` → `Quote { blocks }` с вложенными блоками.
- `ul` / `ol` / `li` → `ListItem { marker, depth, inlines }`: `ul` → `Bullet`, `ol` → `Number(n)` (с `start`,
  если число; шаг 1). `depth` — вложенность списков от 0, не больше 255. Блоки внутри `li` (`p`, `div`)
  склеиваются в его `inlines` через пробел; вложенный список идёт следующими `ListItem` с `depth + 1`.
- `pre` → `Code { lines }` (текст, разбитый по `\n`, без завершающих пустых строк).
- `hr` → `Separator`.
- `table` → `Table { rows }`: строки `tr` (из `thead` / `tbody` / `tfoot` по порядку), ячейки `td` / `th`,
  содержимое ячейки — inlines (блоки внутри склеиваются через пробел). `colspan` / `rowspan` игнорируются
  (известная потеря из спеки MVP).
- `aside` / `div` / `section` / `li` / `p` с `epub:type` (или `role`), содержащим `footnote`, `endnote`,
  `rearnote`, `doc-footnote`, `doc-endnote` → `Footnote { id, blocks }`, где
  `id = "<путь главы в архиве>#<id элемента>"`; без `id` у элемента — обычные блоки.
- `br` → `\n` в тексте (вопрос 2).
- Прочие элементы (`div`, `section`, `span`, `body`, неизвестные) прозрачны: их содержимое разбирается как
  есть. Блочный элемент внутри строчного (`<span><p>…`) закрывает текущий абзац и начинает блок.

### Внутри строки
- `b`, `strong` → `bold`; `i`, `em`, `cite`, `dfn`, `var` → `italic`; `code`, `tt`, `kbd`, `samp` → `code`;
  `sup` → `Script::Sup`; `sub` → `Script::Sub`. Вложенные стили складываются.
- Соседние `Inline::Text` с одинаковым стилем склеиваются.
- `a href` → `Inline::Link` (разрешается во втором проходе):
  - ссылка помечена `epub:type="noteref"` или `role="doc-noteref"` и цель — `Footnote` →
    `Inline::NoteRef { id, label }`, `label` — текст ссылки (обрезанный);
  - внутренняя ссылка с найденной целью → `Link { Internal(индекс блока) }`;
  - битая (нет файла, нет якоря, нет блока) → ссылка снимается, её inlines остаются в тексте (Review Focus 1).
  - `a` без `href` — прозрачен.
- Якорь (`id` на любом элементе, в т. ч. строчном) указывает на блок, который его содержит; якорь на
  элементе без блоков (пустой `div id`) → на первый блок после него; после него блоков нет → ссылка битая.
  Ссылка на файл без фрагмента → первый блок главы.

### Картинки
- Источники картинок: `img src` и `svg > image` (`xlink:href` или `href`). `object` / `embed` снимаются целиком.
- Картинка вне текста (единственное содержимое абзаца/блока, кроме пробелов) → `Figure { image, caption: [] }`;
  внутри `figure` подпись — inlines из `figcaption`.
- Картинка среди текста → `Inline::Image { res, height_em: 1.0 }` (*решение аналитика*).
- MIME — `media-type` из manifest, если запись там есть, иначе по расширению (`png`, `jpg`/`jpeg`, `gif`, `webp`,
  `svg`). Не `image/*`, записи нет в архиве или она за пределом → картинка снимается (alt не выводится).
- Одна и та же запись архива → один `Resource`; `ResourceId` по порядку первой встречи, с 0 (обложка — первой).
  Байты копируются как есть (декодирование — дело читалки).

### Оглавление (`toc`)
- Источник: EPUB 3 — документ manifest с `properties` содержащим `nav`, элемент `nav` с `epub:type="toc"`,
  вложенные `ol > li > a`; если его нет или он пуст — NCX из `spine toc="<id>"` (или первый manifest-элемент
  `application/x-dtbncx+xml`), `navMap > navPoint` (вложенные), `navLabel/text` и `content src`.
  Если нет ни того, ни другого — `toc` пустой.
- `level` — глубина вложенности, с 1; глубже 255 → 255.
- `title` — текст пункта, пробелы схлопнуты; пустой → пункт пропускается, его дети остаются на своём уровне.
- `block` — индекс блока по правилам якорей выше; цель не найдена → пункт пропускается (дети остаются).
- Порядок — как в документе оглавления.

### Переносы
- `Hyphenator::hyphenate` применяется к `Inline::Text` во всех блоках, кроме `Code` и текста со `style.code`;
  `label` у `NoteRef` и `toc.title` не трогаются.
- Только если `Meta.language` — `None` или начинается с `ru` / `en` (без учёта регистра) — *решение аналитика*:
  словари только для русского и английского, а `Hyphenator` выбирает словарь по алфавиту, и немецкий текст
  получил бы английские переносы.

### Пределы (Review Focus 1, «огромный файл»)
Константы в `import/epub/mod.rs` (или `archive.rs`), *решение аналитика*:

| Константа | Значение | Превышение |
|---|---|---|
| `MAX_ENTRIES` | 10 000 записей в архиве | `Corrupted("epub: too many entries")` |
| `MAX_ENTRY_BYTES` | 64 МиБ распакованных на запись | глава/OPF/NCX/nav → `Corrupted("epub: entry too large")`; картинка → снимается |
| `MAX_TOTAL_BYTES` | 512 МиБ распакованных за импорт | `Corrupted("epub: too large")` |
| `MAX_DEPTH` | 256 уровней вложенности XML | глубже — элементы прозрачны (текст сохраняется), рекурсии нет |

Размер берётся из заголовка записи, но чтение тоже ограничено (`take`), т. к. заголовок может врать.

### Ошибки
Все — `ImportError::Corrupted(String)` с префиксом `epub:` (тексты фиксированы, тесты сверяют вариант и префикс):

| Случай | Результат |
|---|---|
| не zip / обрезанный zip / битая запись | `Corrupted("epub: not a zip archive …")` / `Corrupted("epub: damaged entry …")` |
| нет `META-INF/container.xml` | `Corrupted("epub: missing META-INF/container.xml")` |
| в container нет `rootfile`, OPF нет в архиве | `Corrupted("epub: missing package document")` |
| OPF не разбирается как XML | `Corrupted("epub: invalid package document …")` |
| spine пустой или все его элементы битые (нет в manifest / в архиве) | `Corrupted("epub: no readable chapters")` |
| отдельный элемент spine битый | глава пропускается, событие прогресса всё равно идёт |
| глава — битый XML на середине | блоки до места ошибки сохраняются, глава закрывается, импорт продолжается |
| в книге ни одного блока (после всех глав) | `Corrupted("epub: no content")` |
| битый nav / NCX | `toc` пустой (или NCX вместо nav), не ошибка |
| зашифрованные документы spine | `Corrupted("epub: encrypted (DRM)")` (вопрос 3) |
| пределы | см. таблицу пределов (вопрос 3) |
| отмена | `ImportError::Cancelled` |

Паники нет нигде (линты workspace); на мосту `run_job` и так ловит панику, но тесты не должны на это полагаться.

## Фикстуры

Только синтетика, написанная разработчиком (никакого текста чужих книг, AGENTS.md раздел 7). Хранятся
**распакованными папками** в `rust/flow-core/tests/fixtures/epub/<имя>/` (читаемый диф), в zip их собирает
хелпер `rust/flow-core/tests/common/epub.rs` (*решение аналитика*):
`pub fn pack(dir: &str) -> Vec<u8>` — `mimetype` первым без сжатия, остальное deflate, порядок записей
по имени; `pub fn pack_files(files: &[(&str, &[u8])]) -> Vec<u8>` — для случаев, собранных прямо в тесте.
Картинка — `fixtures/epub/pixel.png`, PNG 1×1, сгенерированная, общая для фикстур (хелпер подкладывает её по
пути, указанному в фикстуре).

| Фикстура | Что внутри |
|---|---|
| `epub2-minimal/` | EPUB 2: OPF (title, 2 creator, language `ru`), NCX на 2 пункта, 2 главы с `h1` и `p` |
| `epub3-nav/` | EPUB 3: `nav` с вложенным оглавлением 3 уровней, якоря на `h2` внутри главы, NCX с *другим* текстом (проверка приоритета nav) |
| `epub3-content/` | одна глава со всеми конструкциями: `h1`–`h6`, `p` с `b/i/code/sup/sub/br`, вложенные `ul/ol` (`start="3"`), `blockquote` с `p`, `pre`, `hr`, `table`, `figure+figcaption`, `img` в тексте, ссылки внешние/внутренние/битые, `noteref` + `aside epub:type="footnote"`, `span id` в абзаце, `&nbsp;` `&mdash;`, `script`/`style` |
| `epub3-images/` | обложка `cover-image`, та же картинка дважды в тексте, `svg><image>`, ссылка на отсутствующую картинку, картинка с `media-type="text/plain"` |
| `epub2-cover-meta/` | обложка через `<meta name="cover">`, роли `opf:role="aut"` и `opf:role="trl"` |
| `edge-paths/` | файл с пробелом в имени (`%20` в href), `../` в путях, регистр имени в href не совпадает с архивом, spine-элемент на несуществующий файл, глава с битым XML в середине |

Случаи без папок (собираются в тесте через `pack_files` или байтами): мусор вместо zip, обрезанный zip,
zip без `container.xml`, container без rootfile, пустой spine, книга без текста, `encryption.xml` на главу,
запись больше предела (подменённый размер — генерируется в тесте), 300 уровней вложенности `div`.

## Тесты

Интеграционные — `rust/flow-core/tests/epub.rs` (+ при надобности `epub_errors.rs`); юнит-тесты `path.rs`,
`entities.rs` — в `#[cfg(test)]` модулях. Каждый тест сначала падает (RED) на `EpubConverter`, которого нет /
который возвращает `Unsupported`.

| Тест | Что проверяет | Вход → ожидаемый результат |
|---|---|---|
| `non_epub_kind_is_unsupported` | чужой `kind` | `SourceKind::Fb2`, пустой `Cursor` → `Err(Unsupported(Fb2))`, 0 событий |
| `epub2_minimal_metadata` | OPF EPUB 2 | `epub2-minimal` → title, authors `["A1","A2"]`, language `Some("ru")`, cover `None` |
| `epub2_minimal_chapters_in_spine_order` | главы по spine | блоки: `Heading(1)`, `Paragraph`, `Heading(1)`, `Paragraph` в порядке spine |
| `epub2_ncx_toc` | NCX | `toc` = 2 пункта level 1 с индексами первых блоков глав |
| `epub3_nav_toc_nested` | nav, вложенность, якоря | `epub3-nav` → уровни 1/2/3, `block` указывает на `h2` по якорю |
| `epub3_nav_preferred_over_ncx` | приоритет | titles из nav, не из NCX |
| `toc_entry_with_missing_target_dropped` | битый пункт | пункт на `nope.xhtml#x` отсутствует, его дети на месте |
| `headings_levels_clamped` | `h5`, `h6` | → `Heading { level: 4 }` |
| `inline_styles_nested_and_merged` | стили | `<b>a<i>b</i></b>c` → 3 run'а с верными `Style`; соседние одинаковые склеены |
| `br_becomes_newline` | `br` | `a<br/>b` → один `Paragraph`, текст `"a\nb"` |
| `whitespace_collapsed_nbsp_kept` | пробелы | `"  a \n b "` → `"a b"`; `&nbsp;` → U+00A0 |
| `html_entities_resolved` | сущности | `&mdash;&laquo;` → `—«` |
| `lists_nested_with_start` | списки | `ol start=3` → `Number(3), Number(4)`; вложенный `ul` → `Bullet`, `depth 1` |
| `blockquote_becomes_quote` | цитата | `Quote { blocks: [Paragraph] }` |
| `pre_becomes_code_lines` | `pre` | отступы и строки сохранены, без переносов |
| `hr_and_table` | `hr`, `table` | `Separator`; `Table` 2×2 с текстом ячеек |
| `script_and_style_skipped` | мусор | их текста нет в блоках |
| `figure_with_caption` | `figure` | `Figure { image: id, caption: [Text "Подпись"] }` |
| `inline_image_in_text` | `img` в тексте | `Inline::Image { height_em: 1.0 }` внутри `Paragraph` |
| `same_image_one_resource` | дедуп | две ссылки → один `Resource`, одинаковый `ResourceId` |
| `cover_image_epub3_is_first_resource` | обложка EPUB 3 | `cover == Some(ResourceId(0))`, `resources[0].mime == "image/png"`, байты = `pixel.png` |
| `cover_meta_epub2` | обложка EPUB 2 | `epub2-cover-meta` → cover задан |
| `creator_roles_filtered` | роли | автор с `trl` исключён, с `aut` остался |
| `svg_image_becomes_figure` | `svg image` | `Figure` |
| `missing_or_non_image_resource_dropped` | битая картинка | блока/инлайна нет, ошибки нет, лишних `Resource` нет |
| `external_link` | внешняя | `Link { External("https://example.org") }` |
| `internal_link_to_anchor_in_other_chapter` | внутренняя | `Internal(i)`, `i` = блок со `span id` |
| `broken_link_unwrapped` | Review Focus 1 | ссылка на несуществующий файл/якорь → текст без `Link` |
| `javascript_link_unwrapped` | опасная схема | текст без `Link` |
| `noteref_and_footnote` | сноски | `NoteRef { id: "<путь>#n1", label: "1" }` и `Footnote { id: тот же }` |
| `noteref_without_footnote_is_link` | цель не сноска | обычный `Link Internal` |
| `percent_encoded_and_dotdot_paths` | пути | `edge-paths` → глава с `%20` и `../` найдена |
| `case_insensitive_entry_fallback` | регистр | глава найдена |
| `missing_spine_item_skipped` | битый spine | остальные главы есть, прогресс `total` = длина spine |
| `malformed_chapter_keeps_prefix` | битый XML | блоки до ошибки есть, следующая глава импортирована |
| `hyphenation_applied_ru` | переносы | длинное русское слово содержит U+00AD; текст в `Code` и `code` — без U+00AD |
| `hyphenation_skipped_for_other_language` | язык `de` | U+00AD нет |
| `source_hash_is_sha256_of_bytes` | хеш | совпадает с SHA-256 упакованных байтов (считается в тесте), 64 hex; не зависит от начальной позиции `src` |
| `converter_version_and_format` | версии | `format_version == 1`, `converter_version == EPUB_CONVERTER_VERSION` |
| `progress_per_spine_item` | прогресс | spine из 3 → события `Pages 1/3, 2/3, 3/3`, других нет |
| `cancel_between_chapters` | отмена | отмена в колбэке после 1-го события → `Err(Cancelled)`, событий ровно 1 |
| `cancel_before_start` | отмена | токен отменён до вызова → `Err(Cancelled)`, 0 событий |
| `encoded_book_roundtrips` | совместимость с кодеком | `decode(encode(book)) == book` |
| `garbage_is_corrupted` | Review Focus 1 | случайные байты, пустой вход → `Corrupted` с префиксом `epub:` |
| `truncated_zip_is_corrupted` | Review Focus 1 | первые 60% байтов `epub2-minimal` → `Corrupted` |
| `missing_container_is_corrupted` | Review Focus 1 | zip без `container.xml` → `Corrupted("epub: missing META-INF/container.xml")` |
| `missing_package_is_corrupted` | нет OPF | → `Corrupted("epub: missing package document")` |
| `empty_spine_is_corrupted` | пустой spine | → `Corrupted("epub: no readable chapters")` |
| `no_content_is_corrupted` | только пустые главы | → `Corrupted("epub: no content")` |
| `encrypted_chapter_rejected` | DRM | → `Corrupted("epub: encrypted (DRM)")` |
| `font_obfuscation_allowed` | шрифты в `encryption.xml` | импорт успешен |
| `oversized_entry_rejected` | предел | глава > `MAX_ENTRY_BYTES` → `Corrupted("epub: entry too large")` |
| `deep_nesting_no_stack_overflow` | `MAX_DEPTH` | 300 `div` вокруг `p` → абзац на месте, без паники |

Юнит: `path::resolve` (`a/b.xhtml` + `../c.xhtml` → `c.xhtml`; выход за корень → `None`; `%20`; фрагмент),
`entities` (несколько известных, неизвестная `&foo;` → остаётся как текст).

Мост, `rust/bridge/src/api/import.rs` (`#[cfg(test)]`):

| Тест | Вход → результат |
|---|---|
| `epub_kind_uses_epub_converter` | `converter_for(Epub)` на мусорных байтах → `Corrupted` с префиксом `epub:` (а не `Unsupported`) |
| `other_kinds_still_use_stub` | существующий тест для `Pdf` остаётся зелёным |

## Критерии приёмки

- Из `rust/`: `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test` — зелёные.
- Покрытие: `cargo llvm-cov --workspace … --fail-under-lines 85` проходит; `import/epub/` — ≥ 85% строк.
- Мост перегенерирован (`flutter_rust_bridge_codegen generate`), сгенерированное закоммичено;
  `dart analyze --fatal-infos`, `flutter test` и `integration_test/import_stub_test.dart` (PDF через заглушку) зелёные.
- Новые зависимости — только утверждённые (вопрос 1), без дефолтных фич с C-кодом; лицензии дописаны в NOTICE.
- `flutter build apk --flavor store --release` собирается (проверка, что зависимости собираются под Android).
- QA на Pixel 7: интерфейса в задаче нет. Ручная проверка на устройстве — в 3.2 + 4.3 (импорт синтетического
  EPUB из фикстур через экран). В PR 4.1 — отчёт о прогоне `cargo test` и сборке APK.
- В репозитории нет чужих книг и их текста; фикстуры — синтетические.

## Review Focus

- **Кривой вход:** zip-бомба (маленький архив, огромные распакованные размеры, в т. ч. врущий заголовок) —
  чтение всегда через `take`, суммарный счётчик; зацикленные/самоссылочные href; пути с `..`, абсолютные пути
  (`/OEBPS/…`), обратные слэши в href; OPF, где manifest-id повторяется; spine с `idref` на не-XHTML (картинку).
- **Огромный вход:** книга на тысячи глав и десятки тысяч блоков — второй проход без квадратичных поисков
  (карта якорей — `HashMap`), память — книга целиком в RAM один раз плюс CBOR в мосте.
- **Отмена:** проверяется до каждой главы и перед вторым проходом; после `Cancelled` нет событий прогресса.
- **Паники:** индексация, `unwrap`, переполнения `u32` / `u8` (`total`, `depth`, `level`) — насыщающие
  преобразования, без `as`.
- **Повтор:** одинаковые байты дают одинаковый `Book` (детерминированный порядок ресурсов и записей —
  не зависит от порядка `HashMap`), одинаковый `source_hash` (на нём держится защита от дублей в 3.1).

## Решения, принятые на гриллинге

Гриллинга с человеком ещё не было: вопросы 1–3 выше — открытые. Решения аналитика (помечены в тексте):

| Вопрос | Решение | Почему |
|---|---|---|
| Новый API моста? | Нет, только `converter_for` | задача требует встать на место заглушки через `import_book` |
| Fixed-layout | импортируем как обычную книгу | рендера XHTML в картинку в `flow-core` нет |
| CSS | не разбираем | в модели v1 нет полей выравнивания; стиль символов — из тегов |
| Битая глава / ссылка / картинка | пропуск, а не ошибка | одна плохая глава не должна ломать книгу; ошибка — только если читать нечего |
| `linear="no"` | импортируем по порядку spine | там обычно сноски; без них `NoteRef` повиснут |
| Стадии прогресса | только `Pages` по главам | второй проход быстрый |
| Переносы | только для `ru` / `en` / неизвестного языка | словари только эти два |
| Фикстуры | папки + упаковка в тесте | читаемый диф, нет бинарников кроме PNG 1×1 |
| Регистр имён в zip | точное имя, потом без учёта регистра | частая ошибка сборщиков |
| `converter_version` | `epub/<версия flow-core>` | понять, какие книги переконвертировать |
| Картинка в тексте | `Inline::Image`, `height_em: 1.0` | иначе ломается строка; один кегль — нейтральное значение |

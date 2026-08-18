# FAQ Dynamic Content (MySQL)

> Worked example of a completed checkpoint. Note the concrete file paths, the
> `TEST: none` escape hatch on the docs item, and the final rename that moved this
> file from `checkpoint-faq-dynamic-content.md` to `checkpoint-complete-faq-dynamic-content.md`.

## Feature summary (high-level, 5–10 lines)
- Goal: Load FAQ topics/questions/answers from MySQL instead of hardcoded arrays.
- User-facing behavior: FAQ page renders topics and accordion items from DB; "Last update" label is sourced from DB (fallback if empty).
- Scope (in): New FAQ tables, seed SQL, data-access layer to fetch topics/items, route/handler wiring, template binding for dynamic data.
- Scope (out): Admin UI, CMS workflows, permissioning, and WYSIWYG editing.
- Assumptions: Manual SQL execution is acceptable; `is_active` uses `y/n`; FAQ answers may include HTML.
- Risks / edge cases: Empty FAQ tables, HTML injection risk if answers are not sanitized upstream, sort order gaps, missing last-updated timestamps.

## Checklist (TDD-first, actionable)
- [x] Define FAQ tables + seed SQL
  - Files: `db/migrations/2026_01_28_create_faq_tables.sql`, `tests/Schema/FaqSchemaTest.php`
  - TEST: Add `tests/Schema/FaqSchemaTest.php` asserting `db/migrations/2026_01_28_create_faq_tables.sql` exists and contains `CREATE TABLE faq_topics` and `CREATE TABLE faq_items` with columns `faqtopicid`, `faqitemid`, `title`, `question`, `answer`, `answer_html`, `sort_order`, `is_active`, `created_at`, `updated_at`, and item flags `is_open`, `is_static`, `hide_caret`, `no_bottom_border`.
  - IMPLEMENT: Add `db/migrations/2026_01_28_create_faq_tables.sql` with DDL for:
    - `faq_topics` (PK `faqtopicid`, `title`, optional `slug`, `sort_order`, `is_active` CHAR(1) default 'y', `created_at`, `updated_at`).
    - `faq_items` (PK `faqitemid`, FK `faqtopicid`, `question`, `answer` TEXT, `answer_html` LONGTEXT NULL, `sort_order`, `is_active` CHAR(1) default 'y', flags `is_open`, `is_static`, `hide_caret`, `no_bottom_border` TINYINT(1) default 0, timestamps).
    - Index on `faq_items.faqtopicid` and `faq_items.sort_order`.
    - Seed inserts for current topics + a "Questions?" row (lipsum ok).
  - VERIFY: `vendor/bin/phpunit tests/Schema/FaqSchemaTest.php` — expect 1 test, 0 failures.

- [x] Add FAQ data builder
  - Files: `src/Data/FaqDataBuilder.php`, `tests/Data/FaqDataBuilderTest.php`
  - TEST: Add `tests/Data/FaqDataBuilderTest.php` with a stub PDO adapter asserting `buildFaqData()` returns `faqSections` grouped by topic in `sort_order` order, that inactive rows are excluded, and that `faqLastUpdatedLabel` is `''` when `MAX(updated_at)` is NULL.
  - IMPLEMENT: Create `src/Data/FaqDataBuilder.php` (DB adapter injected) with `buildFaqData(): array` that:
    - Queries active topics ordered by `sort_order ASC, title ASC`.
    - Queries active items ordered by `sort_order ASC, faqitemid ASC`.
    - Groups items under topics to return `faqSections` shaped like the view (`title`, `items[]` with `question`, `answer`, `answer_html`, `is_open`, `is_static`, `hide_caret`, `no_bottom_border`).
    - Computes `faqLastUpdatedLabel` from `MAX(updated_at)` across topics/items; format as `M, d, Y` to match UI (e.g., "Jan, 28, 2026"); fallback to `''` if null.
  - VERIFY: `vendor/bin/phpunit tests/Data/FaqDataBuilderTest.php` — expect 4 tests, 0 failures.

- [x] Wire handler + template to dynamic FAQ data
  - Files: `src/Http/FaqHandler.php`, `templates/faq.php`, `tests/Http/FaqPageTest.php`
  - TEST: Add `tests/Http/FaqPageTest.php` asserting `FaqHandler` passes `faqSections` and `faqLastUpdatedLabel` to the view, that an empty DB result falls back to the static `faqSections`, and that the rendered page contains a seeded question string.
  - IMPLEMENT:
    - Update `src/Http/FaqHandler.php` to call `FaqDataBuilder::buildFaqData()` and pass `faqSections` + `faqLastUpdatedLabel` to the template.
    - Keep a fallback to the existing static `faqSections` if the DB returns no topics.
    - Update `templates/faq.php` to render the button text from `faqLastUpdatedLabel`, falling back to the current static text when empty.
  - VERIFY: `vendor/bin/phpunit tests/Http/FaqPageTest.php` — expect 3 tests, 0 failures. Then load `http://localhost:8080/faq` and confirm topics render from DB.

- [x] Document the FAQ content workflow
  - Files: `docs/faq-content.md`
  - TEST: none — docs-only change, no runtime behavior
  - IMPLEMENT: Add `docs/faq-content.md` describing how to add a topic, add an item, and the `is_active = 'n'` soft-delete convention.
  - VERIFY: Open `docs/faq-content.md` and confirm it names both tables, all item flags, and the soft-delete convention.

- [x] Finalize checkpoint
  - Files: `plan/checkpoint-faq-dynamic-content.md`
  - TEST: none — bookkeeping step
  - IMPLEMENT: Append the completion entry to the Progress log.
  - VERIFY: `vendor/bin/phpunit` passes full suite, every item above is `[x]`, then rename to `plan/checkpoint-complete-faq-dynamic-content.md` and confirm the new path exists.

## Progress log (append-only)
- 2026-01-28T09:14:02-0800 - Initialized plan for MySQL-backed FAQ content (schema, data builder, handler/template wiring).
- 2026-01-28T10:41:37-0800 - Added faq_topics/faq_items DDL + seed; FaqSchemaTest green (1 test).
- 2026-01-28T12:08:55-0800 - Added FaqDataBuilder with grouping + last-updated label; FaqDataBuilderTest green (4 tests).
- 2026-01-28T14:22:19-0800 - Wired FaqHandler and templates/faq.php with static fallback; FaqPageTest green (3 tests); verified /faq renders seeded content.
- 2026-01-28T14:51:06-0800 - Added docs/faq-content.md covering topic/item authoring and soft deletes.
- 2026-01-28T15:03:44-0800 - Completed: full suite green (8 tests, 0 failures); renamed plan to checkpoint-complete-faq-dynamic-content.md.

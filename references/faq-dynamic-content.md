# FAQ Dynamic Content (MySQL)

## Feature summary (high-level, 5–10 lines)
- Goal: Load FAQ topics/questions/answers from MySQL instead of hardcoded arrays.
- User-facing behavior: FAQ page renders topics and accordion items from DB; "Last update" label is sourced from DB (fallback if empty).
- Scope (in): New FAQ tables, seed SQL, data-access layer to fetch topics/items, route/handler wiring, template binding for dynamic data.
- Scope (out): Admin UI, CMS workflows, permissioning, and WYSIWYG editing.
- Assumptions: Manual SQL execution is acceptable; `is_active` uses `y/n`; FAQ answers may include HTML.
- Risks / edge cases: Empty FAQ tables, HTML injection risk if answers are not sanitized upstream, sort order gaps, missing last-updated timestamps.

## Checklist (TDD-first, actionable)
- [ ] Define FAQ tables + seed SQL
  - Files: `<db-schema-file>`, `<schema-test-file>`
  - TEST: Create `<schema-test-file>` to assert `<db-schema-file>` exists and includes `CREATE TABLE faq_topics`, `CREATE TABLE faq_items`, required columns (`faqtopicid`, `faqitemid`, `title`, `question`, `answer`, `answer_html`, `sort_order`, `is_active`, `created_at`, `updated_at`, and item flags `is_open`, `is_static`, `hide_caret`, `no_bottom_border`).
  - IMPLEMENT: Add `<db-schema-file>` with DDL for:
    - `faq_topics` (PK `faqtopicid`, `title`, optional `slug`, `sort_order`, `is_active` CHAR(1) default 'y', `created_at`, `updated_at`).
    - `faq_items` (PK `faqitemid`, FK `faqtopicid`, `question`, `answer` TEXT, `answer_html` LONGTEXT NULL, `sort_order`, `is_active` CHAR(1) default 'y', flags `is_open`, `is_static`, `hide_caret`, `no_bottom_border` TINYINT(1) default 0, timestamps).
    - Index on `faq_items.faqtopicid` and `faq_items.sort_order`.
    - Seed inserts for current topics + a "Questions?" row (lipsum ok).
  - VERIFY: Run the schema test and expect PASS/green status.

- [ ] Add FAQ data builder
  - Files: `<faq-data-builder-file>`, `<data-builder-test-file>`
  - TEST: Create `<data-builder-test-file>` to assert `<faq-data-builder-file>` exists, the FAQ data builder is defined, and method `buildFaqData()` is present. Also assert SQL strings reference `faq_topics` and `faq_items`.
  - IMPLEMENT:
    - Create a FAQ data builder (DB adapter injected) with `buildFaqData(): array` that:
      - Queries active topics ordered by `sort_order ASC, title ASC`.
      - Queries active items ordered by `sort_order ASC, faqitemid ASC`.
      - Groups items under topics to return `faqSections` shaped like the view (`title`, `items[]` with `question`, `answer`, `answer_html`, `is_open`, `is_static`, `hide_caret`, `no_bottom_border`).
      - Computes `faqLastUpdatedLabel` from `MAX(updated_at)` across topics/items; format as `M, d, Y` to match UI (e.g., "Jan, 28, 2026"); fallback to empty if null.
  - VERIFY: Run the data builder contract test and expect PASS/green status.

- [ ] Wire handler + template to dynamic FAQ data
  - Files: `<faq-handler-file>`, `<faq-template-file>`, `<handler-template-test-file>`
  - TEST: Create `<handler-template-test-file>` to assert the FAQ handler calls the data builder and the template reads `faqSections` and `faqLastUpdatedLabel` (or uses fallback).
  - IMPLEMENT:
    - Update the FAQ handler to call the data builder and pass `faqSections` + `faqLastUpdatedLabel` to the template.
    - Keep a fallback to existing static `faqSections` if DB returns no topics.
    - Update the FAQ template to render the button text from `faqLastUpdatedLabel` (fallback to current static text if empty).
  - VERIFY: Run the handler/template test and load the FAQ page locally to confirm topics/questions render from DB.

## Progress log (append-only)
- 2026-01-28T00:00:00 - Drafted plan for MySQL-backed FAQ content (schema, data builder, handler/template wiring).

# INDEX.md — карта проекта

## Сначала читать
1. `AGENT.md` — правила и критерий готовности.
2. `STATUS.md` — где работа сейчас.
3. `TASK_ONE_SHOT.md` — задача текущего автономного запуска.
4. `memory/L1.md`, затем `memory/L2.md` при необходимости.

## Исходные данные и инструкции
- `data/input/Lunar_Dust_Data_Collection_By_Research_Blocks.xlsx` — будущая матрица сбора параметров (readonly).
- `project_context/questions_literature_lunar_dust.pdf` — исследовательские вопросы.
- `project_context/parameters_and_inputs_lunar_dust.docx` — методика параметров.
- `project_context/proposed_multiphysics_model.docx` — расчётная архитектура.

## Литература
- `library/local/` — PDF пользователя, readonly.
- `library/local_manifest.csv` — контрольные суммы локальных PDF.
- `library/text/` — извлечённый текст PDF.
- `library/chunks.jsonl` — page-aware локальный контекст.
- `library/seed/sources_seed.csv` — локальные источники + внешние кандидаты.
- `queries/literature_search_queries.md` — запросы для OpenAlex/web.

## Работа агента
- `notes/concepts/`, `notes/sources/`, `notes/claims/` — граф/заметки.
- `ontology.yaml` — онтология.
- `graph_view.md` — Mermaid-проекция графа.
- `results/` — проверяемые таблицы и примеры локального поиска.
- `report/` — итог ДЗ 1.
- `checks/` — неизменяемая проверка готовности.
- `diary.md` — append-only журнал.

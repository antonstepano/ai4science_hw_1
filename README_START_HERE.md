# AI4Science HW1 — Lunar Dust: запуск за один проход

Этот пакет подготовлен под ДЗ 1 «Среда и контекст» из переданного курса и под дальнейший сбор параметров проекта лунной пыли.

## Что уже внутри
- `AGENT.md` — заполненный договор с агентом;
- локальная библиотека из 8 переданных научных PDF + page-aware текстовый индекс;
- 24 внешних источника-кандидата (статьи, NASA reports/standard, монография, каталоги), которые агент обязан верифицировать;
- `ontology.yaml`, Obsidian vault и стартовый граф понятий;
- исходная Excel-матрица параметров проекта;
- запросы для локального поиска и OpenAlex;
- детерминированный `checks/check_hw1.py`;
- один сценарий запуска для Windows и Linux/macOS.

## 0. Один раз установить AI4Science
По материалам курса:

**Windows**
```powershell
git clone https://github.com/andkhalov/AI4Science.git
cd AI4Science
setup.bat
```

**Linux/macOS**
```bash
git clone https://github.com/andkhalov/AI4Science.git && cd AI4Science && ./setup.sh
```

Проверка:
```bash
ai4science doctor
```

## 1. Рекомендуется подключить Research MCP
В папке `optional_research_mcp/` лежат файлы из недели 5 курса и `CONNECT.md` с инструкцией. После подключения агент получает `openalex_search`, `openalex_work`, `openalex_links`, `wikidata_search`, `wikidata_sparql`.

OpenAlex API key хранить только в `.env` агента, не в этом проекте.

## 2. Инициализировать git
Из корня этого пакета:
```bash
git init
git add -A
git commit -m "HW1: стартовая среда и локальная библиотека"
```

## 3. Проверить локальный контекст до агента
```bash
python scripts/preflight.py
python scripts/local_search.py "электростатическая пыль ультрафиолет терминатор" --top 5
```

## 4. Один запуск ДЗ
**Windows:** двойной запуск `run_hw1.bat` или PowerShell:
```powershell
.\run_hw1.ps1
```

**Linux/macOS:**
```bash
./run_hw1.sh
```

Скрипт делает ровно один вызов `ai4science run`, а затем независимую проверку.

## 5. Что должно появиться
- `report/HW1_environment_context.md`;
- `results/sources.csv`;
- `results/local_context_examples.md`;
- `results/parameter_evidence.csv`;
- обновлённый граф/заметки, `STATUS.md`, `diary.md`;
- в `logs/final_check.log` строка `HW1 CHECK: PASS`.

## Важное ограничение
Пакет не притворяется, что внешние seed-ссылки уже научно верифицированы. Строки `seed_unverified` — кандидаты для агента. Научные численные выводы делаются только после проверки полного текста/локатора, а не только title/abstract.

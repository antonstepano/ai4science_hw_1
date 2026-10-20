# Форматы результатов

## `sources.csv`
`source_id,origin,type,title,authors,year,doi,url,local_path,blocks,keywords,verification_status,access_notes`

## `parameter_evidence.csv`
Одна строка = одно наблюдение/значение/диапазон/закон при одних условиях.

Обязательные столбцы:
`evidence_id,model_block,parameter_name,symbol,value_nominal,value_min,value_max,uncertainty,unit_si,distribution_or_law,conditions,particle_or_material,scenario,evidence_type,source_id,locator,verification_status,notes`

`value_*` можно оставить пустыми, если источник даёт только закон/кривую: тогда заполнить `distribution_or_law`. Не придумывать числовое значение.

## `local_context_examples.md`
Для каждого примера:
- запрос;
- команда локального поиска;
- краткий ответ;
- локальные `source_id` и страницы;
- что проверено независимо;
- ограничения/противоречия.

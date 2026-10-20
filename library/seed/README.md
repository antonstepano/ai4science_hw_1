# Seed literature registry
`sources_seed.csv` содержит:
- локальные источники пользователя (`local_file_present`);
- внешние кандидаты (`seed_unverified`), найденные при подготовке среды.

Seed — не доказательство. Агент обязан проверять metadata через DOI/OpenAlex/официальную страницу и отмечать финальный статус в `results/sources.csv`. Для числового evidence нужен доступный полный текст и locator.

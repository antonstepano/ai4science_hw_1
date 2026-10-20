---
type: Источник
source_id: SRC-L003
origin: local
year: 2026
doi: 10.1007/s11431-025-3246-9
status: verified_metadata
---
# A multi-force microscale model for lunar dust detachment and dispersion induced by rover mobility

- authors: Yanrong Ye; Pengcheng Zhao; Ruotong Wang; Zhiyong Shu; Hua Qian
- file: [[library/local/SRC-L003_ye_2026_rover_dust.pdf]]
- model_blocks: 1;3;5;6;7;15
- concepts: [[Роверный выброс]] [[Адгезия]] [[Электризация]] [[Транспорт пыли]] [[JKR-DMT]]
- note: Model + Apollo-image validation

## Проверенные утверждения
- Модель учитывает три неконтактные силы: электрическую `Fe = Eq`, гравитацию и электростатическую (Кулоновское притяжение к колесу) (p.4).
- Плотность частиц пыли принята 2900 кг/м³; контактная разность потенциалов `Ue = 0.4 В` (p.4, ASSUMED).
- Объёмная доля частиц в пылевом шлейфе ~10⁻⁶–10⁻⁸ (разреженный режим) (p.4).
- JKR модель принята для адгезии (p.2, PE-063).
- Радиус частиц модели 18–45 мкм (p.2, PE-017, ASSUMED).
- При фиксированном slip ratio 0.2 увеличение скорости ровера уменьшает минимальный радиус отрыва (центробежная сила ~ квадрат скорости) (p.10).
- Малые частицы радиусом <20 мкм доминируют в верхней части пылевого шлейфа (p.1, PE-061, SIMULATED).
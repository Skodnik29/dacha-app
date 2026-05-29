"""
Сидер: системный справочник культур для РФ.
Запуск: python -m app.seeds.plant_catalog
"""
import asyncio
from sqlalchemy import text
from app.core.database import AsyncSessionLocal


async def seed():
    async with AsyncSessionLocal() as session:
        # Проверяем — уже есть данные?
        result = await session.execute(
            text("SELECT COUNT(*) FROM plant_catalog WHERE is_custom = false")
        )
        count = result.scalar()
        if count and count > 0:
            print(f"⚠️  Справочник уже заполнен ({count} культур). Пропускаем.")
            return

        print("🌱 Заполняем справочник культур...")

        plants = [
            # (name, name_latin, plant_type)
            ("Томат", "Solanum lycopersicum", "vegetable"),
            ("Огурец", "Cucumis sativus", "vegetable"),
            ("Картофель", "Solanum tuberosum", "vegetable"),
            ("Морковь", "Daucus carota", "vegetable"),
            ("Перец сладкий", "Capsicum annuum", "vegetable"),
            ("Кабачок", "Cucurbita pepo", "vegetable"),
            ("Баклажан", "Solanum melongena", "vegetable"),
            ("Капуста белокочанная", "Brassica oleracea", "vegetable"),
            ("Лук репчатый", "Allium cepa", "vegetable"),
            ("Чеснок", "Allium sativum", "vegetable"),
            ("Яблоня", "Malus domestica", "tree"),
            ("Груша", "Pyrus communis", "tree"),
            ("Слива", "Prunus domestica", "tree"),
            ("Вишня", "Prunus cerasus", "tree"),
            ("Черешня", "Prunus avium", "tree"),
            ("Клубника", "Fragaria × ananassa", "berry"),
            ("Смородина чёрная", "Ribes nigrum", "berry"),
            ("Смородина красная", "Ribes rubrum", "berry"),
            ("Крыжовник", "Ribes uva-crispa", "berry"),
            ("Малина", "Rubus idaeus", "berry"),
            ("Роза", "Rosa", "flower"),
            ("Пион", "Paeonia", "flower"),
            ("Георгин", "Dahlia", "flower"),
            ("Тюльпан", "Tulipa", "flower"),
            ("Укроп", "Anethum graveolens", "herb"),
            ("Петрушка", "Petroselinum crispum", "herb"),
            ("Базилик", "Ocimum basilicum", "herb"),
            ("Сирень", "Syringa vulgaris", "shrub"),
            ("Гортензия", "Hydrangea", "shrub"),
        ]

        for name, name_latin, plant_type in plants:
            await session.execute(
                text("""
                    INSERT INTO plant_catalog 
                        (id, name, name_latin, plant_type, is_custom, is_builtin, created_at)
                    VALUES 
                        (gen_random_uuid(), :name, :name_latin, :plant_type, 
                         false, true, now())
                    ON CONFLICT DO NOTHING
                """),
                {"name": name, "name_latin": name_latin, "plant_type": plant_type}
            )
            print(f"  ✓ {name}")

        await session.commit()
        print(f"\n✅ Добавлено {len(plants)} культур!")


if __name__ == "__main__":
    asyncio.run(seed())
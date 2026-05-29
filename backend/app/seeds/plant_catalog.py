"""
Запуск: python -m app.seeds.plant_catalog
Наполняет базу встроенным каталогом культур и сортов.
"""
import asyncio
from app.core.database import async_session

CATALOG = [
    # Овощи
    {"name": "Томат", "name_latin": "Solanum lycopersicum", "plant_type": "vegetable",
     "days_to_harvest": 110, "sowing_months": "2,3,4", "harvest_months": "7,8,9",
     "varieties": ["Черри", "Бычье сердце", "Сливовидный", "Чёрный принц", "Де Барао"]},
    {"name": "Огурец", "name_latin": "Cucumis sativus", "plant_type": "vegetable",
     "days_to_harvest": 55, "sowing_months": "4,5", "harvest_months": "7,8",
     "varieties": ["Зозуля", "Родничок", "Герман", "Феникс", "Кураж"]},
    {"name": "Картофель", "name_latin": "Solanum tuberosum", "plant_type": "vegetable",
     "days_to_harvest": 90, "sowing_months": "4,5", "harvest_months": "8,9",
     "varieties": ["Синеглазка", "Невский", "Ред Скарлетт", "Импала", "Ривьера"]},
    {"name": "Морковь", "name_latin": "Daucus carota", "plant_type": "vegetable",
     "days_to_harvest": 100, "sowing_months": "4,5", "harvest_months": "9,10",
     "varieties": ["Нантская", "Шантенэ", "Лосиноостровская"]},
    {"name": "Перец сладкий", "name_latin": "Capsicum annuum", "plant_type": "vegetable",
     "days_to_harvest": 130, "sowing_months": "2,3", "harvest_months": "8,9",
     "varieties": ["Богатырь", "Калифорнийское чудо", "Ласточка"]},
    {"name": "Кабачок", "name_latin": "Cucurbita pepo", "plant_type": "vegetable",
     "days_to_harvest": 60, "sowing_months": "5", "harvest_months": "7,8,9",
     "varieties": ["Цукеша", "Аэронавт", "Грибовские 37"]},

    # Плодовые деревья
    {"name": "Яблоня", "name_latin": "Malus domestica", "plant_type": "tree",
     "harvest_months": "8,9,10",
     "varieties": ["Антоновка", "Белый налив", "Голден", "Симиренко", "Гала", "Пепин шафранный"]},
    {"name": "Груша", "name_latin": "Pyrus communis", "plant_type": "tree",
     "harvest_months": "8,9",
     "varieties": ["Лада", "Чижовская", "Бере Боск", "Конференция", "Памяти Яковлева"]},
    {"name": "Слива", "name_latin": "Prunus domestica", "plant_type": "tree",
     "harvest_months": "8,9",
     "varieties": ["Венгерка", "Синяя птица", "Памяти Тимирязева", "Ренклод колхозный"]},
    {"name": "Вишня", "name_latin": "Prunus cerasus", "plant_type": "tree",
     "harvest_months": "7,8",
     "varieties": ["Владимирская", "Любская", "Молодёжная", "Шоколадница"]},
    {"name": "Черешня", "name_latin": "Prunus avium", "plant_type": "tree",
     "harvest_months": "6,7",
     "varieties": ["Ипуть", "Ревна", "Брянская розовая", "Тютчевка"]},

    # Ягоды
    {"name": "Клубника", "name_latin": "Fragaria × ananassa", "plant_type": "berry",
     "harvest_months": "6,7",
     "varieties": ["Клери", "Хоней", "Альба", "Виктория", "Мальвина", "Флоренс"]},
    {"name": "Смородина чёрная", "name_latin": "Ribes nigrum", "plant_type": "berry",
     "harvest_months": "7,8",
     "varieties": ["Багира", "Дача", "Добрыня", "Чёрный жемчуг"]},
    {"name": "Смородина красная", "name_latin": "Ribes rubrum", "plant_type": "berry",
     "harvest_months": "7,8",
     "varieties": ["Натали", "Ранняя сладкая", "Версальская белая"]},
    {"name": "Крыжовник", "name_latin": "Ribes uva-crispa", "plant_type": "berry",
     "harvest_months": "7,8",
     "varieties": ["Малахит", "Огник", "Русский жёлтый"]},
    {"name": "Малина", "name_latin": "Rubus idaeus", "plant_type": "berry",
     "harvest_months": "7,8,9",
     "varieties": ["Геракл", "Гусар", "Брянское диво", "Патриция"]},

    # Цветы
    {"name": "Роза", "name_latin": "Rosa", "plant_type": "flower",
     "varieties": ["Плетистая", "Чайно-гибридная", "Флорибунда", "Почвопокровная", "Парковая"]},
    {"name": "Пион", "name_latin": "Paeonia", "plant_type": "flower",
     "varieties": ["Сарах Бернар", "Феликс Крус", "Доктор Александр Флеминг"]},
    {"name": "Тюльпан", "name_latin": "Tulipa", "plant_type": "flower",
     "sowing_months": "9,10", "harvest_months": "4,5",
     "varieties": ["Дарвиновы гибриды", "Попугайные", "Махровые поздние"]},
    {"name": "Георгин", "name_latin": "Dahlia", "plant_type": "flower",
     "varieties": ["Кактусовый", "Помпонный", "Шаровидный", "Декоративный"]},

    # Кустарники
    {"name": "Сирень", "name_latin": "Syringa vulgaris", "plant_type": "shrub",
     "varieties": ["Обыкновенная", "Мечта", "Красавица Москвы"]},
    {"name": "Гортензия", "name_latin": "Hydrangea", "plant_type": "shrub",
     "varieties": ["Метельчатая", "Крупнолистная", "Древовидная", "Аннабель"]},

    # Травы
    {"name": "Укроп", "name_latin": "Anethum graveolens", "plant_type": "herb",
     "days_to_harvest": 40, "sowing_months": "4,5,6", "harvest_months": "6,7,8",
     "varieties": ["Грибовский", "Аллигатор", "Супердукат"]},
    {"name": "Петрушка", "name_latin": "Petroselinum crispum", "plant_type": "herb",
     "days_to_harvest": 60, "sowing_months": "4,5", "harvest_months": "6,7,8",
     "varieties": ["Обыкновенная листовая", "Кудрявая", "Корневая"]},
    {"name": "Базилик", "name_latin": "Ocimum basilicum", "plant_type": "herb",
     "days_to_harvest": 50, "sowing_months": "4,5", "harvest_months": "7,8",
     "varieties": ["Генуэзский", "Тёмно-фиолетовый", "Лимонный"]},
]


async def seed():
    from app.models.plant import PlantCatalog, PlantVariety
    from sqlalchemy import select

    async with async_session() as db:
        for item in CATALOG:
            # Проверяем, не добавлена ли уже культура
            existing = await db.execute(
                select(PlantCatalog).where(PlantCatalog.name == item["name"])
            )
            if existing.scalar_one_or_none():
                print(f"  ↩ уже есть: {item['name']}")
                continue

            plant = PlantCatalog(
                name=item["name"],
                name_latin=item.get("name_latin"),
                plant_type=item["plant_type"],
                days_to_harvest=item.get("days_to_harvest"),
                sowing_months=item.get("sowing_months"),
                harvest_months=item.get("harvest_months"),
                is_custom=False,
            )
            db.add(plant)
            await db.flush()

            for v_name in item.get("varieties", []):
                db.add(PlantVariety(
                    plant_id=plant.id,
                    name=v_name,
                    is_custom=False,
                ))

            print(f"  ✓ добавлена: {item['name']} ({len(item.get('varieties', []))} сортов)")

        await db.commit()
        print("\n✅ Справочник культур заполнен!")


if __name__ == "__main__":
    asyncio.run(seed())
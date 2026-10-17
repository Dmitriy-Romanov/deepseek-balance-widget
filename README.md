# DeepSeek Balance — виджет KDE Plasma 6

Показывает баланс аккаунта DeepSeek API на панели Plasma. Виджет запрашивает
`GET https://api.deepseek.com/user/balance` с ключом из настроек и обновляет
значение по таймеру.

## Поведение

- По умолчанию показывается баланс в CNY; если CNY в ответе нет — первая валюта из `balance_infos`.
- Пока идёт запрос: «Loading…» в раскрытом виде и «…» на панели.
- Ошибки (`No API key set`, `Error <код>`, `Bad response`) показываются текстом и
  иконкой `data-error`.
- Клик по компактному представлению открывает/закрывает раскрытое окно.
- В tooltip выводятся название «DeepSeek Balance» и баланс либо текст ошибки.

## Требования

- KDE Plasma 6 (Qt 6).
- Доступ в интернет к `api.deepseek.com`.

## Установка

Из корня проекта (каталог, где лежит `deepseek-balance-widget/`):

```bash
kpackagetool6 -t Plasma/Applet -i deepseek-balance-widget

# иконка для списка виджетов (необязательно, но иначе там будет заглушка)
install -Dm644 deepseek-balance-widget/contents/icons/deepseek.svg \
    ~/.local/share/icons/hicolor/scalable/apps/deepseek.svg

systemctl --user restart plasma-plasmashell.service
```

Затем: ПКМ по панели → Добавить виджеты → **DeepSeek Balance**.

Если пакет уже установлен, `-i` выдаст ошибку — используйте обновление (ниже).

### Ручная установка

Без `kpackagetool6` можно скопировать содержимое пакета, не создавая вложенную папку:

```bash
DEST=~/.local/share/plasma/plasmoids/org.kde.plasma.deepseekbalance
mkdir -p "$DEST"
rsync -a --delete --exclude=.git deepseek-balance-widget/ "$DEST"/
```

`cp -r deepseek-balance-widget "$DEST"` при существующем `$DEST` создаст
`$DEST/deepseek-balance-widget/` — так делать не нужно.

## Обновление после правок

```bash
cd ~/ZCode/Deepseek_check
kpackagetool6 -t Plasma/Applet -u deepseek-balance-widget
systemctl --user restart plasma-plasmashell.service
```

При изменении иконки повторите `install -Dm644 ...` из раздела установки.
Конфигурация виджета при обновлении пакета сохраняется.

## Настройка

ПКМ по виджету → Настроить → **General**:

- **API key** — ключ `sk-...` с platform.deepseek.com.
- **Refresh interval** — период обновления в минутах (по умолчанию 15).

Ключ хранится в открытом виде в
`~/.config/plasma-org.kde.plasma.desktop-appletsrc`; не публикуйте этот файл.

## Как это устроено

`contents/ui/main.qml`:

- `refresh()` делает `XMLHttpRequest` к API и разбирает `balance_infos`.
- `Timer` запускается при непустом `apiKey`, сразу делает первый запрос
  (`triggeredOnStart`) и повторяет его каждые `refreshInterval` минут.
- `Component.onCompleted` показывает «No API key set», если ключ не задан.
- Иконка DeepSeek подключается как файл пакета:
  `Qt.resolvedUrl("../icons/deepseek.svg")`, поэтому работает сразу после установки.
- `metadata.json` → `"Icon": "deepseek"` ищется в теме иконок; для списка виджетов
  нужна копия SVG в `~/.local/share/icons/hicolor/scalable/apps/`.

## Структура

- `metadata.json` — манифест пакета (Plasma 6); здесь Id, имя и иконка в списке виджетов.
- `contents/ui/main.qml` — запрос, таймер и оба представления (`PlasmoidItem`).
- `contents/ui/configGeneral.qml` — страница настроек General.
- `contents/icons/deepseek.svg` — иконка DeepSeek (Simple Icons, CC0; логотип — товарный знак DeepSeek).
- `contents/config/config.qml` — модель вкладок окна настроек.
- `contents/config/main.xml` — схема настроек (KConfigXT).

## Разработка и отладка

Отдельной сборки нет: Plasma загружает QML напрямую.

- После правок QML и `metadata.json`:
  `kpackagetool6 -t Plasma/Applet -u deepseek-balance-widget` + перезапуск plasmashell.
- Ошибки QML и запросов смотрите так:
  `journalctl --user -u plasma-plasmashell -f`
- Проверка манифеста: `python3 -m json.tool metadata.json`.
- При добавлении настройки обновляйте и `contents/config/main.xml`
  (`<entry name="..." ...>`), и алиас `cfg_...` в `configGeneral.qml`.
- Ключ API в коде не хранится: только в конфигурации Plasma.

Короткий чек-лист после изменений:

| Что меняли | Что сделать |
|---|---|
| `contents/ui/*.qml` | `kpackagetool6 -t Plasma/Applet -u deepseek-balance-widget` + перезапуск plasmashell |
| `metadata.json` | то же самое |
| настройки | синхронизировать `main.xml` и `configGeneral.qml`, затем обновить пакет |
| `contents/icons/deepseek.svg` | скопировать SVG в hicolor (см. установку), перезапустить plasmashell |

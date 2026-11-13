# puntoS-v

Исправляет выделенный текст, набранный не в той раскладке (`Ghbdtn` → `Привет`), и меняет его регистр.
Скрипт для [AutoHotkey v2](https://www.autohotkey.com/), Windows.

[English below](#english)

## Установка

1. Установите [AutoHotkey v2](https://www.autohotkey.com/).
2. Запустите `puntoS-v.ahk` — в трее появится значок.
3. Для автозапуска положите ярлык на `puntoS-v.ahk` в папку `shell:startup` (Win+R → `shell:startup`)
   или выполните в PowerShell из папки со скриптом:

   ```powershell
   $s = (New-Object -ComObject WScript.Shell).CreateShortcut("$([Environment]::GetFolderPath('Startup'))\puntoS-v.lnk")
   $s.TargetPath = "$PWD\puntoS-v.ahk"; $s.WorkingDirectory = "$PWD"; $s.Save()
   ```

## Горячие клавиши

Работают с выделенным текстом в любом приложении.

| Сочетание       | Действие                                                     |
|-----------------|--------------------------------------------------------------|
| `Alt+Ins`       | Раскладка RU ↔ EN, затем переключает раскладку окна          |
| `Alt+Shift+Ins` | Инвертировать регистр: `пРИВЕТ` → `Привет`                   |
| `Win+Alt+U`     | ВСЁ В ЗАГЛАВНЫЕ                                              |
| `Win+Alt+L`     | всё в строчные                                               |
| `Ctrl+Alt+Shift+Ins` | Транслитерация в латиницу: `Щука и ёжик` → `Shchuka i yozhik` |

Если выделить результат и нажать то же сочетание ещё раз, смена раскладки или инверсия регистра отменится.
Направление (RU → EN или EN → RU) определяется автоматически по преобладающим буквам.
Текст, набранный с включённым Caps Lock, тоже исправляется: `GHJLJK;FQ` → `ПРОДОЛЖАЙ`.

## Настройка

Сочетания задаются в блоке `НАСТРОЙКИ` в начале `puntoS-v.ahk`:

```ahk
global HK_LAYOUT := "!Ins"     ; Alt+Ins
global HK_INVERT := "!+Ins"    ; Alt+Shift+Ins
global HK_LOWER  := "#!vk4C"   ; Win+Alt+L
global HK_UPPER  := "#!vk55"   ; Win+Alt+U
global HK_TRANSLIT := "^!+Ins" ; Ctrl+Alt+Shift+Ins
```

- Модификаторы: `!` — Alt, `+` — Shift, `^` — Ctrl, `#` — Win.
- Буквы лучше задавать виртуальным кодом (`vk55` = U), тогда сочетание работает в любой раскладке.
- Пустая строка `""` отключает действие.
- `PASTE_THRESHOLD` — с какой длины текст вставляется через буфер обмена, а не печатается. Многострочный текст вставляется через буфер всегда.

После изменений выберите «Перезапустить» в меню значка в трее.

`Win+L` в Windows блокирует экран. Если на вашей системе `Win+Alt+L` тоже его блокирует, назначьте строчным другое сочетание.

## Буфер обмена

Короткий однострочный текст печатается напрямую, без буфера обмена. Длинный или многострочный вставляется через буфер (при печати перевод строки стал бы нажатием Enter, а в чатах Enter отправляет сообщение), после чего прежнее содержимое буфера восстанавливается. Временные данные помечаются так, чтобы не попадать в журнал Win+V и облачный буфер.

---

<a id="english"></a>

## English

Fixes selected text typed in the wrong keyboard layout (`Ghbdtn` → `Привет`, Russian ↔ English) and changes its case.
A script for [AutoHotkey v2](https://www.autohotkey.com/), Windows.

### Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Run `puntoS-v.ahk` — an icon appears in the system tray.
3. To start it with Windows, put a shortcut to `puntoS-v.ahk` into the `shell:startup` folder (Win+R → `shell:startup`),
   or run this in PowerShell from the script's folder:

   ```powershell
   $s = (New-Object -ComObject WScript.Shell).CreateShortcut("$([Environment]::GetFolderPath('Startup'))\puntoS-v.lnk")
   $s.TargetPath = "$PWD\puntoS-v.ahk"; $s.WorkingDirectory = "$PWD"; $s.Save()
   ```

### Hotkeys

They work on selected text in any application.

| Hotkey          | Action                                                       |
|-----------------|--------------------------------------------------------------|
| `Alt+Ins`       | Convert layout RU ↔ EN, then switch the window's layout      |
| `Alt+Shift+Ins` | Invert case: `hELLO` → `Hello`                               |
| `Win+Alt+U`     | ALL UPPERCASE                                                |
| `Win+Alt+L`     | all lowercase                                                |
| `Ctrl+Alt+Shift+Ins` | Transliterate Russian to Latin: `Щука и ёжик` → `Shchuka i yozhik` |

Select the result and press the same hotkey again to undo a layout conversion or case inversion.
The direction (RU → EN or EN → RU) is detected automatically from the prevailing letters.
Text typed with Caps Lock on is fixed too: `GHJLJK;FQ` → `ПРОДОЛЖАЙ`.

### Configuration

Hotkeys are set in the `НАСТРОЙКИ` (settings) block at the top of `puntoS-v.ahk`:

```ahk
global HK_LAYOUT := "!Ins"     ; Alt+Ins
global HK_INVERT := "!+Ins"    ; Alt+Shift+Ins
global HK_LOWER  := "#!vk4C"   ; Win+Alt+L
global HK_UPPER  := "#!vk55"   ; Win+Alt+U
global HK_TRANSLIT := "^!+Ins" ; Ctrl+Alt+Shift+Ins
```

- Modifiers: `!` Alt, `+` Shift, `^` Ctrl, `#` Win.
- Specify letters by virtual key code (`vk55` = U) so the hotkey works in any layout.
- An empty string `""` disables an action.
- `PASTE_THRESHOLD` — text longer than this is pasted via the clipboard instead of typed. Multi-line text is always pasted.

After editing, choose «Перезапустить» (Reload) in the tray icon menu.

`Win+L` locks the screen in Windows. If `Win+Alt+L` locks it on your system too, assign another hotkey to lowercase.

### Clipboard

Short single-line text is typed directly, without touching the clipboard. Longer or multi-line text is pasted via the clipboard (typing a line break would press Enter, which sends the message in chat inputs), and the previous clipboard contents are restored afterwards. Temporary data is flagged so it stays out of Win+V history and cloud clipboard.

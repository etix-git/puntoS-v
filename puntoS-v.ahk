; puntoS-v.ahk — раскладка и регистр выделенного текста
; AutoHotkey v2

#Requires AutoHotkey v2.0
#SingleInstance Force

; ===========================================================================
; НАСТРОЙКИ
; Синтаксис AHK: ! = Alt, + = Shift, ^ = Ctrl, # = Win.
; Пустая строка "" отключает действие.
; ===========================================================================
global HK_LAYOUT := "!Ins"     ; сменить раскладку RU <-> EN    (Alt+Ins)
global HK_INVERT := "!+Ins"    ; инвертировать регистр           (Alt+Shift+Ins)
; Буквы задаются виртуальным кодом (vkXX) — так хоткей работает в любой раскладке.
global HK_LOWER  := "#!vk4C"   ; всё в строчные                  (Win+Alt+L / Д)
global HK_UPPER  := "#!vk55"   ; всё в заглавные                 (Win+Alt+U / Г)

; Порог длины: короче — набираем через SendText (буфер не трогаем),
; длиннее — вставляем через буфер с резервированием (быстрее).
; Многострочный текст вставляется через буфер всегда, независимо от длины.
global PASTE_THRESHOLD := 2000
; ===========================================================================

; ---------------------------------------------------------------------------
; Таблица: одна и та же физическая клавиша в QWERTY и ЙЦУКЕН.
; ---------------------------------------------------------------------------
global En2Ru := Map()
global Ru2En := Map()

BuildTables()

BuildTables() {
    pairs := [
        ["``", "ё"], ["~", "Ё"],
        ["@", '"'],  ["#", "№"],  ["$", ";"],  ["^", ":"],  ["&", "?"],  ["|", "/"],
        ["[", "х"],  ["{", "Х"],  ["]", "ъ"],  ["}", "Ъ"],
        [";", "ж"],  [":", "Ж"],  ["'", "э"],  ['"', "Э"],
        [",", "б"],  ["<", "Б"],  [".", "ю"],  [">", "Ю"],
        ["/", "."],  ["?", ","]
    ]

    en := "qwertyuiopasdfghjklzxcvbnm"
    ru := "йцукенгшщзфывапролдячсмить"
    Loop StrLen(en) {
        e := SubStr(en, A_Index, 1)
        r := SubStr(ru, A_Index, 1)
        pairs.Push([e, r], [StrUpper(e), StrUpper(r)])
    }

    for p in pairs {
        if En2Ru.Has(p[1]) || Ru2En.Has(p[2]) {
            MsgBox "Повтор в таблице раскладок: " p[1] " <-> " p[2], "puntoS-v", "Iconx"
            ExitApp
        }
        En2Ru[p[1]] := p[2]
        Ru2En[p[2]] := p[1]
    }
}

; Все действия в одном месте: из этого списка строятся хоткеи, меню в трее и справка.
global Actions := [
    {hk: HK_LAYOUT, name: "Раскладка RU ↔ EN",      fn: (*) => ProcessSelection(LayoutAction, SwitchLayoutAfter)},
    {hk: HK_INVERT, name: "Инвертировать регистр",  fn: (*) => ProcessSelection(InvertCase)},
    {hk: HK_LOWER,  name: "Всё в строчные",         fn: (*) => ProcessSelection(StrLower)},
    {hk: HK_UPPER,  name: "Всё в заглавные",        fn: (*) => ProcessSelection(StrUpper)}
]

RegisterHotkeys()
BuildTrayMenu()

; ---------------------------------------------------------------------------
; Горячие клавиши
; ---------------------------------------------------------------------------
RegisterHotkeys() {
    for a in Actions {
        a.active := false
        if a.hk = ""
            continue
        try {
            Hotkey(a.hk, a.fn)
            a.active := true
        } catch as e {
            MsgBox "Не удалось назначить «" a.hk "» (" a.name "):`n" e.Message, "puntoS-v", "Icon!"
        }
    }
}

; "#!+Ins" -> "Win+Alt+Shift+Ins"
HotkeyToText(hk) {
    mods := Map("^", false, "#", false, "!", false, "+", false)
    while StrLen(hk) > 1 && InStr("^#!+<>*~$", SubStr(hk, 1, 1)) {
        c := SubStr(hk, 1, 1), hk := SubStr(hk, 2)
        if mods.Has(c)
            mods[c] := true
    }
    out := ""
    for pair in [["^", "Ctrl"], ["#", "Win"], ["!", "Alt"], ["+", "Shift"]]
        if mods[pair[1]]
            out .= pair[2] "+"
    ; "vk55" -> "U": у букв и цифр vk-код совпадает с ASCII, имя не зависит от раскладки.
    if RegExMatch(hk, "i)^vk([0-9a-f]{2})$", &m) {
        code := Integer("0x" m[1])
        hk := (code >= 0x30 && code <= 0x5A) ? Chr(code) : GetKeyName(hk)
    }
    return out hk
}

; ---------------------------------------------------------------------------
; Меню значка в трее
; ---------------------------------------------------------------------------
BuildTrayMenu() {
    tray := A_TrayMenu
    tray.Delete()            ; убрать стандартные пункты AHK (вернуть: tray.AddStandard())

    noop := (*) => 0
    tray.Add("puntoS-v — горячие клавиши", noop)
    tray.Disable("puntoS-v — горячие клавиши")
    tip := "puntoS-v"
    for a in Actions {
        if !a.active
            continue
        item := "    " a.name "`t" HotkeyToText(a.hk)
        tray.Add(item, noop)
        tray.Disable(item)
        tip .= "`n" HotkeyToText(a.hk)
    }
    tray.Add()
    tray.Add("Справка…", ShowHelp)
    tray.Add("Приостановить", ToggleSuspend)
    tray.Add("Редактировать скрипт", (*) => Edit())
    tray.Add("Перезапустить", (*) => Reload())
    tray.Add()
    tray.Add("Выход", (*) => ExitApp())
    tray.Default := "Справка…"   ; двойной щелчок по значку

    A_IconTip := SubStr(tip, 1, 127)
}

ShowHelp(*) {
    text := "Горячие клавиши (работают с выделенным текстом):`n`n"
    for a in Actions
        if a.active
            text .= HotkeyToText(a.hk) "  —  " a.name "`n"
    text .= "`nПовторное нажатие отменяет преобразование раскладки и инверсию регистра."
    text .= "`nСочетания меняются в блоке НАСТРОЙКИ в начале скрипта."
    MsgBox text, "puntoS-v — справка", "Iconi"
}

ToggleSuspend(itemName, *) {
    Suspend -1
    A_TrayMenu.ToggleCheck(itemName)
}

; Общий порядок: отпустить модификаторы -> прочитать выделение -> преобразовать -> вывести.
ProcessSelection(convertFn, after := "") {
    ReleaseModifiers()

    text := GetSelection()
    if text = ""
        return

    out := convertFn(text)
    if out == text
        return

    PutText(out)
    if after
        after()
}

ReleaseModifiers() {
    for k in ["Alt", "Shift", "Ctrl", "LWin", "RWin"]
        KeyWait k
}

; ---------------------------------------------------------------------------
; Действия
; ---------------------------------------------------------------------------
global PendingLayout := ""

LayoutAction(text) {
    global PendingLayout
    dir := ""
    out := Transform(text, &dir)
    PendingLayout := dir = "en2ru" ? "ru" : "en"
    return out
}

SwitchLayoutAfter() => SwitchLayout(PendingLayout)

InvertCase(text) {
    out := ""
    Loop Parse text {
        up := StrUpper(A_LoopField)
        out .= (A_LoopField !== up) ? up : StrLower(A_LoopField)
    }
    return out
}

; ---------------------------------------------------------------------------
; Преобразование
; ---------------------------------------------------------------------------
global LastOut := "", LastDir := ""

; Если выделен ровно предыдущий результат, разворачиваем направление:
; повторное нажатие всегда отменяет первое, даже для фрагмента из одних знаков (";:?).
Transform(text, &dir) {
    global LastOut, LastDir
    if (LastOut != "" && text == LastOut)
        dir := LastDir = "en2ru" ? "ru2en" : "en2ru"
    else
        dir := DetectDirection(text)
    out := Convert(text, dir = "en2ru" ? En2Ru : Ru2En)
    LastOut := out, LastDir := dir
    return out
}

Convert(text, table) {
    out := ""
    Loop Parse text
        out .= table.Has(A_LoopField) ? table[A_LoopField] : A_LoopField
    return out
}

; Направление выбирается один раз для всего фрагмента.
DetectDirection(text) {
    RegExReplace(text, "[а-яёА-ЯЁ]", "", &ru)
    RegExReplace(text, "[a-zA-Z]", "", &en)
    if ru > en
        return "ru2en"
    if en > ru
        return "en2ru"
    ; Букв нет или поровну — смотрим на знаки, которые есть только в одной раскладке.
    if RegExMatch(text, "[\[\]{}'<>``~@#$^&|]")
        return "en2ru"
    if InStr(text, "№")
        return "ru2en"
    return "en2ru"
}

; ---------------------------------------------------------------------------
; Чтение выделения: сначала без буфера, иначе через буфер с резервом.
; ---------------------------------------------------------------------------
GetSelection() {
    ; 1. Стандартный Edit-контрол: читаем напрямую, буфер не трогаем.
    try {
        ctrl := ControlGetFocus("A")
        if ctrl && RegExMatch(ControlGetClassNN(ctrl), "^Edit\d+$")
            return EditGetSelectedText(ctrl)
    }

    ; 2. Остальные окна: Ctrl+C с сохранением и восстановлением буфера.
    saved := ClipboardAll()
    try {
        A_Clipboard := ""
        Send "^c"
        if !ClipWait(0.5)
            return ""
        return A_Clipboard
    } finally {
        Sleep 50
        RestoreClipboard(saved)
    }
}

; ---------------------------------------------------------------------------
; Вывод результата: SendText (без буфера) или вставка с резервом для длинного текста.
; ---------------------------------------------------------------------------
PutText(out) {
    ; Перевод строки в SendText — это Enter, а в чатах (Cursor, VSCode) Enter отправляет сообщение.
    ; Поэтому многострочный текст всегда вставляем через буфер.
    multiline := InStr(out, "`n") || InStr(out, "`r")
    if !multiline && StrLen(out) <= PASTE_THRESHOLD {
        SendText out
        return
    }

    saved := ClipboardAll()
    try {
        if !SetClipboardTextNoHistory(out)
            return
        Send "^v"
        Sleep 150   ; даём приложению забрать данные до восстановления буфера
    } finally {
        RestoreClipboard(saved)
    }
}

; ---------------------------------------------------------------------------
; Запись в буфер через WinAPI с пометкой «не сохранять в журнал Win+V и облако».
; ---------------------------------------------------------------------------
OpenClip() {
    Loop 10 {
        if DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
            return true
        Sleep 20
    }
    return false
}

PutFormat(fmt, ptr, size) {
    h := DllCall("GlobalAlloc", "UInt", 0x0002, "UPtr", Max(size, 1), "Ptr")   ; GMEM_MOVEABLE
    if !h
        return false
    if size {
        p := DllCall("GlobalLock", "Ptr", h, "Ptr")
        DllCall("RtlMoveMemory", "Ptr", p, "Ptr", ptr, "UPtr", size)
        DllCall("GlobalUnlock", "Ptr", h)
    }
    if !DllCall("SetClipboardData", "UInt", fmt, "Ptr", h, "Ptr") {
        DllCall("GlobalFree", "Ptr", h)
        return false
    }
    return true
}

PutNoHistoryFlags() {
    static fmts := [
        DllCall("RegisterClipboardFormat", "Str", "ExcludeClipboardContentFromMonitorProcessing", "UInt"),
        DllCall("RegisterClipboardFormat", "Str", "CanIncludeInClipboardHistory", "UInt"),
        DllCall("RegisterClipboardFormat", "Str", "CanUploadToCloudClipboard", "UInt")
    ]
    zero := Buffer(4, 0)
    for f in fmts
        PutFormat(f, zero.Ptr, 4)
}

; Восстановить буфер из объекта ClipboardAll.
; Формат объекта: записи (UInt формат, UInt размер, данные), в конце UInt 0.
RestoreClipboard(saved) {
    if !OpenClip() {
        A_Clipboard := saved   ; запасной путь: данные важнее журнала
        return
    }
    try {
        DllCall("EmptyClipboard")
        p := saved.Ptr, end := p + saved.Size
        while p + 8 <= end {
            fmt := NumGet(p, "UInt")
            if !fmt
                break
            size := NumGet(p, 4, "UInt")
            PutFormat(fmt, p + 8, size)
            p += 8 + size
        }
        PutNoHistoryFlags()
    } finally {
        DllCall("CloseClipboard")
    }
}

SetClipboardTextNoHistory(text) {
    if !OpenClip()
        return false
    try {
        DllCall("EmptyClipboard")
        buf := Buffer(StrPut(text, "UTF-16"))
        StrPut(text, buf, "UTF-16")
        ok := PutFormat(13, buf.Ptr, buf.Size)   ; CF_UNICODETEXT
        PutNoHistoryFlags()
        return ok
    } finally {
        DllCall("CloseClipboard")
    }
}

; ---------------------------------------------------------------------------
; Переключение раскладки активного окна (WM_INPUTLANGCHANGEREQUEST).
; ---------------------------------------------------------------------------
SwitchLayout(lang) {
    hkl := lang = "ru" ? 0x04190419 : 0x04090409
    try {
        ctrl := ControlGetFocus("A")
        if ctrl
            PostMessage 0x50, 0, hkl, ctrl
        else
            PostMessage 0x50, 0, hkl, , "A"
    }
}

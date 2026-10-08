
Да. Для **Ubuntu + Hyprland (Wayland) внутри VMware** обычный `open-vm-tools` действительно является проблемой: его штатный clipboard backend рассчитан на X11, а для wlroots-композиторов вроде Hyprland сейчас есть отдельный community workaround **clipway**. Это прямо описано в актуальном issue VMware. ([GitHub][1])

Я бы сделал именно так.

## 1. Убедись, что у тебя установлены tools

В Ubuntu:

```bash
sudo apt update
sudo apt install open-vm-tools open-vm-tools-desktop wl-clipboard
```

Проверь:

```bash
systemctl status open-vm-tools
```

и:

```bash
which wl-copy
which wl-paste
```

Должно показать:

```text
/usr/bin/wl-copy
/usr/bin/wl-paste
```

---

## 2. Установи clipway

Это патч для `open-vm-tools`, который добавляет **нативный Wayland clipboard backend**. Он специально заявлен для:

> Sway, Hyprland, river, …

и использует `wl-copy`/`wl-paste` для доступа к Wayland clipboard. ([GitHub][2])

Клонируем:

```bash
cd ~/code
git clone https://github.com/vmware/open-vm-tools.git
git clone https://github.com/krisztianfekete/clipway.git
```

Теперь нужны зависимости для сборки:

```bash
sudo apt install \
    git patch build-essential autoconf automake libtool \
    libmspack-dev libpam0g-dev libssl-dev libxml2-dev \
    libxmlsec1-dev libx11-dev libxext-dev libxinerama-dev \
    libxi-dev libxrender-dev libxrandr-dev libxtst-dev \
    libgtk-3-dev libgtkmm-3.0-dev libtirpc-dev
```

---

## 3. Удали Ubuntu-версию open-vm-tools перед установкой своей

Это важно, чтобы у тебя одновременно не было `/usr` и `/usr/local` версий.

```bash
sudo apt remove open-vm-tools open-vm-tools-desktop
```

**Не перезагружайся пока.**

---

## 4. Применяем patch

```bash
cd ~/code/open-vm-tools/open-vm-tools
```

Проверь, что здесь действительно лежит исходный код.

Затем:

```bash
patch -p1 < ../../clipway/patches/0001-dndcp-wayland-clipboard-backend.patch
```

Если получишь:

```text
patching file ...
```

без `FAILED` — хорошо.

---

## 5. Собираем

```bash
autoreconf -i
./configure
make -j"$(nproc)"
```

Если сборка закончилась без ошибок:

```bash
sudo make install
sudo ldconfig
```

Проверим:

```bash
which vmtoolsd
```

Теперь должно быть:

```text
/usr/local/bin/vmtoolsd
```

И главное:

```bash
ls /usr/local/lib/open-vm-tools/plugins/vmusr/libdndcp.so
```

Файл должен существовать.

---

# 6. Самое важное для Hyprland

Теперь нам надо запустить **user `vmtoolsd` внутри Wayland-сессии**.

Сначала:

```bash
echo $WAYLAND_DISPLAY
```

Например:

```text
wayland-1
```

Запомни это значение.

Проверь также:

```bash
echo $XDG_RUNTIME_DIR
```

обычно будет:

```text
/run/user/1000
```

---

## 7. Создай systemd user service

```bash
mkdir -p ~/.config/systemd/user
```

Создай:

```bash
nano ~/.config/systemd/user/vmware-user.service
```

Вставь:

```ini
[Unit]
Description=VMware User Agent for Wayland

[Service]
Type=simple
Environment=XDG_SESSION_TYPE=wayland
Environment=WAYLAND_DISPLAY=wayland-1
ExecStartPre=/usr/bin/test -S %t/wayland-1
ExecStart=/usr/local/bin/vmtoolsd -n vmusr
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
```

**Но `wayland-1` замени на результат своего:**

```bash
echo $WAYLAND_DISPLAY
```

Например, если там:

```text
wayland-0
```

то в service должно быть:

```ini
Environment=WAYLAND_DISPLAY=wayland-0
ExecStartPre=/usr/bin/test -S %t/wayland-0
```

---

## 8. Запусти

```bash
systemctl --user daemon-reload
systemctl --user enable --now vmware-user.service
```

Проверь:

```bash
systemctl --user status vmware-user.service
```

Должно быть:

```text
Active: active (running)
```

И:

```bash
pgrep -a vmtoolsd
```

Ты должен увидеть **два разных процесса**, примерно:

```text
/usr/local/bin/vmtoolsd
/usr/local/bin/vmtoolsd -n vmusr
```

Первый — системный daemon, второй — твой Wayland user agent.

---

# 9. Проверяем сам Wayland clipboard

До VMware вообще проверим, что `wl-clipboard` работает:

```bash
echo 'HELLO-WAYLAND' | wl-copy
```

затем:

```bash
wl-paste
```

Должно вывести:

```text
HELLO-WAYLAND
```

Если это не работает — проблема пока не в VMware.

---

# 10. Проверяем Windows → Ubuntu

На Windows:

```text
hello from Windows
```

`Ctrl+C`

В Ubuntu открой, например, Firefox/kitty/текстовый редактор и:

```text
Ctrl+V
```

---

# 11. Проверяем Ubuntu → Windows

В Ubuntu:

```bash
echo 'HELLO FROM HYPRLAND' | wl-copy
```

Переходишь в Windows:

```text
Ctrl+V
```

Должно вставиться:

```text
HELLO FROM HYPRLAND
```

---

## Почему твой текущий `open-vm-tools` не помог

У тебя сейчас примерно такая цепочка:

```text
Windows clipboard
       ↕
   VMware RPC
       ↕
  vmtoolsd
       ↕
  dndcp plugin
       ↓
     X11
       X
   Wayland/Hyprland
```

Штатный `open-vm-tools` не имеет нормального Wayland backend для такого случая. Поэтому даже если:

* Guest Isolation → Copy/Paste включен
* `open-vm-tools` установлен
* `vmtoolsd` запущен
* XWayland работает

clipboard всё равно может не работать. Это известная проблема `open-vm-tools`; актуальный upstream issue #792 прямо описывает поломку clipboard в Wayland guests. ([GitHub][1])

`clipway` меняет схему на:

```text
Windows
   ↕
VMware
   ↕
vmtoolsd
   ↕
clipway dndcp backend
   ↕
wl-copy / wl-paste
   ↕
Hyprland Wayland clipboard
```

Именно это тебе нужно.

### Но есть нюанс

`clipway` — **неофициальный patch**, не входящий в штатный VMware/open-vm-tools, и его разработчики предупреждают об этом. ([GitHub][2])

Если тебе нужен **самый простой и стабильный вариант без патчинга VMware**, то второй вариант — запускать Ubuntu в **Xorg-сессии вместо Hyprland Wayland**. VMware сама указывает, что графические функции `open-vm-tools` в целом работают лучше на X11/Xorg, чем на Wayland. ([GitHub][3])

Но если ты хочешь **именно Hyprland**, я бы ставил `clipway`.

[1]: https://github.com/vmware/open-vm-tools/issues/792?utm_source=chatgpt.com "[Wayland] Broken clipboard and drag-and-drop in VMware guests using open-vm-tools · Issue #792 · vmware/open-vm-tools"
[2]: https://github.com/krisztianfekete/clipway?utm_source=chatgpt.com "GitHub - krisztianfekete/clipway: Host - Guest clipboard for wlroots Wayland compositors · GitHub"
[3]: https://github.com/vmware/open-vm-tools/blob/master/ReleaseNotes.md?utm_source=chatgpt.com "open-vm-tools/ReleaseNotes.md at master · vmware/open-vm-tools · GitHub"

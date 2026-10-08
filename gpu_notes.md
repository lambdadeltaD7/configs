Да. И в твоём случае 6 ядер + 16 ГБ RAM тут почти наверняка вообще не проблема. Для Hyprland критичнее GPU/3D-ускорение. Hyprland сам предупреждает, что в VM 3D acceleration может быть довольно медленным, а без 3D acceleration нормальная работа compositor'а невозможна/сильно страдает.

Если у тебя VMware Workstation на Windows, я бы проверил именно это.

1. Включи 3D acceleration в VMware

Полностью выключи Ubuntu VM:

VM → Settings → Hardware → Display

Должно быть включено:

☑ Accelerate 3D graphics

Если есть настройка видеопамяти — поставь Auto-detect либо хотя бы 16–32 MB. VMware сама рекомендует Auto-detect или 16/32 MB для проблем с видеопамятью.

VMware использует аппаратную GPU хоста для 3D-рендеринга гостя, когда включено 3D acceleration.

2. Проверь, что Ubuntu действительно использует VMware GPU

В Ubuntu:

lspci -k | grep -A 3 -E 'VGA|3D|Display'

Нужно увидеть что-то вроде:

00:0f.0 VGA compatible controller: VMware SVGA II Adapter
        Kernel driver in use: vmwgfx

Ключевое здесь:

Kernel driver in use: vmwgfx

Если вместо этого какой-нибудь:

llvmpipe

— вот это уже очень плохо.

3. Самая важная проверка — renderer

Установи:

sudo apt install mesa-utils

и:

glxinfo -B

Для Wayland также очень полезно:

sudo apt install vulkan-tools
vulkaninfo --summary

В glxinfo -B нас интересует:

OpenGL renderer string:
Плохой вариант

Например:

OpenGL renderer string: llvmpipe (LLVM ...)

Это означает:

Hyprland
   ↓
Mesa
   ↓
CPU
   ↓
рендеринг

И тогда неудивительно, что анимации тормозят.

Хороший вариант

Что-нибудь связанное с VMware:

OpenGL renderer string: SVGA3D

или VMware/vmwgfx renderer.

Тогда:

Hyprland
   ↓
Mesa
   ↓
vmwgfx
   ↓
VMware SVGA3D
   ↓
GPU Windows-хоста
4. Посмотри, что Hyprland видит как GPU

Внутри Hyprland:

hyprctl systeminfo

и:

ls -l /dev/dri/

Обычно должно быть что-то вроде:

card0
renderD128

А:

ls -l /dev/dri/renderD128

должен показывать устройство, которым может пользоваться твой пользователь.

Ещё:

dmesg | grep -i vmwgfx

Могут быть строки типа:

vmwgfx ...
[drm] ...
5. Проверь FPS самого Hyprland

Если у тебя, например, монитор VM настроен на 1920×1080@60:

hyprctl monitors

Посмотри:

1920x1080@60...

А затем временно отключи тяжёлые эффекты в Hyprland.

В hyprland.conf:

decoration {
    blur {
        enabled = false
    }
}

animations {
    enabled = false
}

Если после отключения всего этого интерфейс всё равно дёргается, почти наверняка проблема не в конфиге Hyprland, а в графическом стеке VM.

6. У тебя особенно подозрительна ситуация с Hyprland

Hyprland — не просто "оконный менеджер". Это compositor, который постоянно занимается GPU rendering:

перемещение окна
      ↓
Wayland surface
      ↓
Hyprland compositor
      ↓
OpenGL/Vulkan
      ↓
GPU
      ↓
экран VM

Поэтому виртуализация графики здесь гораздо заметнее, чем, например, при запуске обычного XFCE.

Даже официальный Hyprland Wiki отдельно предупреждает:

3D acceleration в VM может быть довольно медленным.

7. Ещё проверь VMware Tools

В Ubuntu:

dpkg -l | grep open-vm-tools

Желательно иметь:

open-vm-tools
open-vm-tools-desktop

Если нет:

sudo apt install open-vm-tools open-vm-tools-desktop

VMware прямо указывает, что без оптимизированного display driver VM может откатиться на полностью программно эмулируемую графику, что резко ухудшает производительность.

Что я бы сделал прямо сейчас

Не надо пока ничего менять в Hyprland. Выполни эти 5 команд и пришли вывод:

lspci -k | grep -A 3 -E 'VGA|3D|Display'
glxinfo -B
hyprctl monitors
ls -l /dev/dri/
dmesg | grep -i vmwgfx

По ним практически сразу будет видно, есть ли у тебя настоящее 3D-ускорение или Hyprland сейчас рендерит всё через CPU.

И если окажется llvmpipe, то это очень хорошо объясняет твои "дерганые" анимации — 16 ГБ RAM и 6 vCPU тут вообще ни при чём.

если я увижу llvmpipe то что делать

Если увидишь llvmpipe, это означает, что Ubuntu сейчас рендерит графику на CPU, а не через виртуальный 3D-GPU VMware. Для Hyprland это практически гарантированно будет причиной тормозов.

Делай по порядку.

1. Проверь VMware

Полностью выключи VM, не suspend.

В VMware:

VM → Settings → Display

включи:

☑ Accelerate 3D graphics

Если есть:

Graphics Memory: Auto

оставь Auto.

После этого запусти VM.

2. Проверь vmwgfx

В Ubuntu:

lspci -k | grep -A 3 -E 'VGA|3D|Display'

Нужно что-то примерно такое:

VGA compatible controller: VMware SVGA II Adapter
    Kernel driver in use: vmwgfx

Если есть vmwgfx — уже хорошо.

Проверь:

ls -l /dev/dri/

Желательно увидеть:

card0
renderD128
3. Установи нормальный Mesa/Vulkan стек
sudo apt update
sudo apt install mesa-utils mesa-vulkan-drivers vulkan-tools \
    libgl1-mesa-dri

Затем:

glxinfo -B

Смотри:

OpenGL renderer string:

Плохо:

llvmpipe (LLVM ...)

Хорошо: что-нибудь вроде:

SVGA3D

или другой renderer, связанный с VMware/vmwgfx.

4. Если всё ещё llvmpipe

Проверь логи:

dmesg | grep -Ei 'vmwgfx|drm|svga'

и:

lsmod | grep vmwgfx

Если vmwgfx вообще не загружен:

sudo modprobe vmwgfx

потом:

lsmod | grep vmwgfx

и снова:

glxinfo -B
5. Если vmwgfx есть, но glxinfo всё равно показывает llvmpipe

Тогда не надо начинать рандомно менять драйверы.

Пришли мне вывод этих команд:

lspci -k | grep -A 3 -E 'VGA|3D|Display'
glxinfo -B
ls -l /dev/dri/
lsmod | grep vmwgfx
dmesg | grep -Ei 'vmwgfx|drm|svga'

и я скажу конкретно, где у тебя ломается цепочка.

Важно: не пытайся ставить драйвер AMD/NVIDIA внутрь Ubuntu только потому, что физический компьютер имеет такую видеокарту. Гостю VMware обычно нужен именно виртуальный VMware SVGA/vmwgfx, а не драйвер физической GPU Windows.

# Barra Quickshell — minimalista (#F8F8F8 / #313131)

Barra de status para Hyprland + Quickshell, com Dynamic Island central,
widgets fixos nas laterais, busca via rofi integrada e menus por atalho
de teclado (modo de carregamento, perfil de energia e desligamento).

## Estrutura

```
quickshell/
├── shell.qml                  # entrada: instancia a Bar por monitor
├── config/
│   ├── Theme.qml              # cores, raios, fontes, durações de animação
│   └── Config.qml             # dimensões e comandos externos (rofi, lock...)
├── components/
│   └── Pill.qml               # bloco base (ícone + rótulo) dos widgets
├── services/                  # singletons que fazem polling do sistema
│   ├── Heartbeat.qml          # timer global de 1s (fonte única de ticks)
│   ├── Cpu.qml  Memory.qml  Temperature.qml  ScreenTime.qml
│   ├── Network.qml  Audio.qml  Brightness.qml  Battery.qml
│   ├── Bluetooth.qml  Weather.qml  Tray.qml  Notifications.qml
│   ├── Music.qml            # faixa atual via MPRIS (singleton)
│   └── Launcher.qml           # dispara o rofi
├── widgets/                   # um arquivo por widget lateral
│   ├── CpuWidget.qml  MemoryWidget.qml  TemperatureWidget.qml
│   ├── ScreenTimeWidget.qml  WifiWidget.qml  VolumeWidget.qml
│   ├── BrightnessWidget.qml  BatteryWidget.qml  TrayWidget.qml
├── island/
│   ├── DynamicIsland.qml      # ilha orientada a modos (lista priorizada)
│   ├── CentralView.qml        # painel central: relógio, clima, calendário,
│   │                          #   stats, sliders de brilho/volume, ações
│   ├── CalendarView.qml       # mini calendário do mês
│   ├── NotificationView.qml   # notificação atual na ilha
│   ├── Waveform.qml           # equalizador de 5 pílulas do modo música
│   ├── ActionButton.qml  StatTile.qml
├── menus/                     # cada um é um singleton com seu PopupWindow
│   ├── ChargeModeMenu.qml
│   ├── PowerProfileMenu.qml
│   └── PowerMenu.qml
├── shortcuts/
│   └── Shortcuts.qml          # GlobalShortcut (desativado por padrão)
├── scripts/
│   └── set-charge-mode.sh     # AJUSTE para o seu hardware (ver abaixo)
├── modules/
│   └── Bar.qml                # PanelWindow principal
└── rofi/
    └── theme.rasi             # tema do rofi combinando com a barra
```

Cada peça vive em seu próprio arquivo — widgets, serviços, menus e
componentes são independentes, então adicionar/remover um item da barra
é só criar o `.qml` e importar em `Bar.qml`.

## Dynamic Island em modos

`DynamicIsland.qml` usa uma lista priorizada de modos:

```qml
readonly property var modes: [
    { name: "notification", active: Notifications.current !== null, ... },
    { name: "central",      active: root.hovering,                ... },
    { name: "music",        active: Music.active,                 ... },
    { name: "clock",        active: true,                         ... },  // fallback
]
```

O primeiro modo com `active: true` vence. A ilha fica colada no topo da
tela com cantos superiores invertidos ("wings"), e sua janela usa `mask`
para que só a barra + ilha recebam clique.

O modo **central** (hover) mostra: relógio grande, data por extenso,
clima, calendário do mês, tiles de memória/CPU/tempo de tela/Bluetooth,
sliders verticais de brilho e volume, botões de modo de carregamento e
perfil de energia, e desligar com confirmação inline.

O modo **wallpaper** (atalho `quickshell:wallpaper`) mostra uma busca +
linha de previews: digite para filtrar, use ←/→ para navegar, Enter
aplica e Esc fecha. O wallpaper é aplicado via `hyprctl hyprpaper`
(modo cover), sem editar arquivo de config.

O modo **music** (`services/Music.qml`, MPRIS) aparece enquanto houver
faixa carregada — tocar ou pausado. Layout: relógio à esquerda,
`Título — Artista` ao centro (com reticências) e um equalizador de 5
pílulas à direita que anima só enquanto `Music.playing` é verdadeiro;
pausado, as barras ficam retas no mínimo (`-----`). Sem controles de
playback e sem `Timer`: um único `NumberAnimation` dentro de
`island/Waveform.qml` alimenta a onda e é destruído junto com o modo.

**Atalho de exemplo (hyprland binds):**
```
bind = SUPER SHIFT, W, global, quickshell:wallpaper
```

`Config.wallpapersDir` e `Config.wallpaperMonitor` controlam a pasta e o
monitor usado pelo picker. `Bar.qml` só torna a janela focável enquanto
essa modo está aberto (para o campo de busca receber teclas).

## Dependências

- `quickshell` (git ou AUR) com suporte a Hyprland habilitado
- `hyprland`
- `rofi` (ou `rofi-wayland`)
- `brightnessctl` (brilho)
- `pipewire` + `wireplumber` (fornece `wpctl`, volume)
- `networkmanager` (fornece `nmcli`, wifi)
- `lm_sensors` (temperatura — rode `sensors-detect` uma vez)
- `power-profiles-daemon` (fornece `powerprofilesctl`)
- `hyprlock` (ou troque `Config.lockCommand` pelo seu bloqueador)
- `curl` (clima — `services/Weather.qml` via open-meteo)
- `libnotify` (`notify-send` — alertas de bateria)
- Fonte com emoji (ex: `noto-fonts-emoji`), Nerd Font para ícones dos
  widgets e a fonte `Inter` (ou troque `Theme.fontFamily`)

## Instalação

```bash
mkdir -p ~/.config/quickshell
git clone <repo> ~/.config/quickshell

# testar manualmente
quickshell
```

Para iniciar junto com a sessão, no `hyprland.conf`:

```
exec-once = quickshell
```

## Atalhos de teclado (Hyprland)

O Quickshell expõe os atalhos via `hyprland_global_shortcuts_v1`; quem
define a combinação de teclas é o **Hyprland**, apontando para o nome
declarado em `shortcuts/Shortcuts.qml`. Hoje só existe o atalho do
seletor de wallpaper; adicione mais nomes em `Shortcuts.qml` se
quiser outros:

```
bind = SUPER SHIFT, W, global, quickshell:wallpaper   # seletor de wallpaper
```

(`quickshell` é o `appid` padrão; troque se você definir outro.)

## Modo de carregamento — ajuste obrigatório

Não existe um comando universal de "modo de carregamento" no Linux; ele
depende do fabricante. Abra `scripts/set-charge-mode.sh` e adapte:

- **ASUS**: use `asusctl charge-limit --set <n>`
- **ThinkPad**: use `tlp setcharge <start> <stop> BAT0`
- **Genérico via kernel** (usado no script de exemplo): escreve em
  `/sys/class/power_supply/BAT0/charge_types`, o que exige `sudo`.
  Crie uma regra sem senha **apenas para esse script**:

  ```bash
  sudo visudo -f /etc/sudoers.d/quickshell-charge
  ```
  ```
  seu_usuario ALL=(root) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_types
  ```

## Outros ajustes rápidos

- **Nome da bateria**: se `ls /sys/class/power_supply/` não mostrar
  `BAT0`, ajuste `Config.batteryDevice`.
- **Perfis de energia**: os valores `performance` / `balanced` /
  `power-saver` são os nomes usados pelo `power-profiles-daemon`.
- **Tempo de tela**: como o Linux/Wayland não tem uma API padrão de
  screen-time, `services/ScreenTime.qml` usa o uptime do sistema como
  aproximação. Troque a leitura em `_parseUptime()` para ler o dado real.
- **Clima**: edite `Config.weatherLatitude` / `Config.weatherLongitude`
  para sua localização.
- **Brilho**: ajuste `Brightness.device` em `services/Brightness.qml`
  para o seu backlight (`ls /sys/class/backlight/`).
- **Cores/raios/fonte**: tudo centralizado em `config/Theme.qml`.


w4rl0ck3r ALL=(root) NOPASSWD: /home/w4rl0ck3r/.config/quickshell/scripts/set-charge-mode.sh, /usr/bin/tee /sys/class/power_supply/BAT0/charge_types

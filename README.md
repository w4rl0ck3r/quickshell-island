# Barra Quickshell — minimalista (#F8F8F8 / #313131)

Barra de status para Hyprland + Quickshell, com Dynamic Island central,
widgets fixos nas laterais, busca via rofi integrada e menus por atalho
de teclado (modo de carregamento, perfil de energia e desligamento).

## Estrutura

```
quickshell-bar/
├── shell.qml                  # entrada: instancia a Bar por monitor + atalhos
├── config/
│   ├── Theme.qml              # cores, raios, fontes, durações de animação
│   └── Config.qml             # dimensões e comandos externos (rofi, lock...)
├── components/
│   └── Pill.qml               # bloco base (ícone + rótulo) dos widgets
├── services/                  # singletons que fazem polling do sistema
│   ├── Cpu.qml  Memory.qml  Temperature.qml
│   ├── Network.qml  Audio.qml  Brightness.qml
│   ├── Battery.qml  ScreenTime.qml
│   └── Launcher.qml           # dispara o rofi
├── widgets/                   # um arquivo por widget lateral
│   ├── CpuWidget.qml  MemoryWidget.qml  TemperatureWidget.qml
│   ├── ScreenTimeWidget.qml  WifiWidget.qml  VolumeWidget.qml
│   ├── BrightnessWidget.qml  BatteryWidget.qml
├── island/
│   ├── DynamicIsland.qml      # relógio ↔ calendário ↔ pulso de busca
│   └── CalendarView.qml
├── menus/                     # cada um é um singleton com seu PopupWindow
│   ├── ChargeModeMenu.qml
│   ├── PowerProfileMenu.qml
│   └── PowerMenu.qml
├── shortcuts/
│   └── Shortcuts.qml          # GlobalShortcut (hyprland_global_shortcuts_v1)
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
- Fonte com emoji (ex: `noto-fonts-emoji`) e a fonte `Inter` instalada
  (ou troque `Theme.fontFamily`)

## Instalação

```bash
mkdir -p ~/.config/quickshell
cp -r quickshell-bar ~/.config/quickshell/bar

# testar manualmente
quickshell -c bar
```

Para iniciar junto com a sessão, no `hyprland.conf`:

```
exec-once = quickshell -c bar
```

## Atalhos de teclado (Hyprland)

O Quickshell expõe os atalhos via `hyprland_global_shortcuts_v1`; quem
define a combinação de teclas é o **Hyprland**, apontando para o nome
declarado em `shortcuts/Shortcuts.qml`:

```
bind = SUPER, SPACE,   global, quickshell:search        # abre o rofi
bind = SUPER, B,       global, quickshell:chargeMode    # fast/standard/long_life
bind = SUPER, P,       global, quickshell:powerProfile  # performance/balanced/economy
bind = SUPER, ESCAPE,  global, quickshell:powerMenu      # trancar / desligar
```

(`quickshell` é o `appid` padrão; troque se você definir outro.)

## Modo de carregamento — ajuste obrigatório

Não existe um comando universal de "modo de carregamento" no Linux; ele
depende do fabricante. Abra `scripts/set-charge-mode.sh` e adapte:

- **ASUS**: use `asusctl charge-limit --set <n>`
- **ThinkPad**: use `tlp setcharge <start> <stop> BAT0`
- **Genérico via kernel** (usado no script de exemplo): escreve em
  `/sys/class/power_supply/BAT0/charge_control_end_threshold`, o que
  exige `sudo`. Crie uma regra sem senha **apenas para esse script**:

  ```bash
  sudo visudo -f /etc/sudoers.d/quickshell-charge
  ```
  ```
  seu_usuario ALL=(root) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_control_end_threshold
  ```

## Outros ajustes rápidos

- **Nome da bateria**: se `ls /sys/class/power_supply/` não mostrar
  `BAT0`, ajuste `Config.batteryDevice`.
- **Perfis de energia**: os valores `performance` / `balanced` /
  `power-saver` são os nomes usados pelo `power-profiles-daemon`.
- **Tempo de tela**: como o Linux/Wayland não tem uma API padrão de
  screen-time, `services/ScreenTime.qml` usa o uptime do sistema como
  aproximação. Se você tiver um tracker próprio, troque o comando do
  `Process` nesse arquivo para ler o dado real.
- **Cores/raios/fonte**: tudo centralizado em `config/Theme.qml`.


w4rl0ck3r ALL=(root) NOPASSWD: /home/w4rl0ck3r/.config/quickshell/scripts/set-charge-mode.sh, /usr/bin/tee /sys/class/power_supply/BAT0/charge_types

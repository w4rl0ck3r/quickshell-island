#!/usr/bin/env bash
# Define o modo de carregamento da bateria.
#
# IMPORTANTE: não existe um comando universal no Linux para isso — depende
# do fabricante do notebook. Ajuste o bloco abaixo para o seu hardware:
#
#   ASUS (asusctl):     asusctl charge-limit --set <n>   (mapear 100/80/60)
#   ThinkPad (tlp):     tlp setcharge <start> <stop> BAT0
#   Genérico (kernel):  escrever em
#                       /sys/class/power_supply/BAT0/charge_control_end_threshold
#
# O exemplo abaixo usa o método genérico via kernel. Ele requer escrita em
# /sys, então crie uma regra sudoers SEM SENHA apenas para este script
# (ver README.md) — nunca rode a barra inteira como root.

set -euo pipefail
BAT="/sys/class/power_supply/BAT0/charge_types"
mode="${1:-}"

# Detecta o ID do usuário conectado na interface gráfica (geralmente 1000)
USER_ID=$(id -u w4rl0ck3r 2>/dev/null || echo 1000)

# Função para enviar a notificação injetando as variáveis de ambiente necessárias
enviar_notificacao() {
  sudo -u w4rl0ck3r DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" notify-send -a "Bateria" "$1" "$2" -i /home/w4rl0ck3r/.config/quickshell/assets/icons/charging-station-solid-full.svg
}

case "$mode" in
  Fast)
    echo Fast | sudo tee $BAT >/dev/null
    enviar_notificacao "Modo de carregamento:" "Rápido" ;;
  Standard)
    echo Standard | sudo tee $BAT >/dev/null
    enviar_notificacao "Modo de carregamento:" "Padrão" ;;
  Long_Life)
    echo Long_Life  | sudo tee $BAT >/dev/null
    enviar_notificacao "Modo de carregamento:" "Long life" ;;
  *)
    echo "Uso: $0 {fast|standard|long_life}" >&2
    exit 1 ;;
esac

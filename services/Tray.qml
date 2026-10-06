pragma Singleton
import QtQuick
import Quickshell.Services.SystemTray

// Bandeja do sistema (ícones de apps em segundo plano: Discord, Telegram,
// gerenciadores de rede/volume de terceiros etc.) via protocolo nativo
// StatusNotifierItem — sem Process, sem polling.
QtObject {
    id: root

    // Setado pelo Bar.qml. Necessário para abrir o menu de clique direito
    // de um item — display() espera a janela "dona" do popup.
    property var barWindow: null

    readonly property var items: SystemTray.items
}

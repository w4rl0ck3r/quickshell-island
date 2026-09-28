import Quickshell
import "modules"
// import "shortcuts"

// Ponto de entrada do Quickshell.
// Uma Bar por monitor conectado + atalhos globais (instância única).
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    //Shortcuts {}
}

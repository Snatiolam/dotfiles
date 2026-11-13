import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Shared lock state and PAM authentication, so every monitor shows the same text.
Scope {
    id: root

    signal unlocked()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock(): void {
        if (unlockInProgress || currentText === "") return;
        unlockInProgress = true;
        if (!pam.start()) {
            unlockInProgress = false;
            showFailure = true;
        }
    }

    PamContext {
        id: pam

        // Own PAM config: the system login stack may also ask for fingerprint or 2FA.
        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);
        }

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                root.currentText = "";
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }
            root.unlockInProgress = false;
        }

        onError: (error) => {
            root.unlockInProgress = false;
            root.showFailure = true;
        }
    }
}

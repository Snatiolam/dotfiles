import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Shared lockscreen state + PAM authentication. Kept outside the per-screen
// surfaces so every monitor shares the same text and unlock state.
Scope {
    id: root

    signal unlocked()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    // Clear the error as soon as the user types again.
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

        // Custom config so we only ask for a password. The system "login"
        // stack can expect more (fingerprint, 2FA, ...). Resolved relative to
        // this file unless absolute.
        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"

        // pam_unix asks for a response for the password prompt.
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

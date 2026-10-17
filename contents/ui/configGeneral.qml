import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_refreshInterval: intervalSpin.value

    QQC2.TextField {
        id: apiKeyField
        Kirigami.FormData.label: i18n("API key:")
        placeholderText: "sk-..."
        echoMode: TextInput.Password
    }

    QQC2.SpinBox {
        id: intervalSpin
        Kirigami.FormData.label: i18n("Refresh interval (minutes):")
        from: 1
        to: 1440
    }
}

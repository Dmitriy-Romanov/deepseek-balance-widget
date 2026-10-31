import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string apiKey: Plasmoid.configuration.apiKey ?? ""
    readonly property int refreshInterval: (Plasmoid.configuration.refreshInterval ?? 15) * 60000
    readonly property string deepseekIcon: Qt.resolvedUrl("../icons/deepseek.svg")

    property string balanceText: "—"
    property string errorText: ""
    property bool loading: false

    Plasmoid.title: i18n("DeepSeek Balance")
    toolTipMainText: i18n("DeepSeek Balance")
    toolTipSubText: root.errorText !== "" ? root.errorText : root.balanceText

    function refresh() {
        if (!apiKey) {
            errorText = i18n("No API key set");
            balanceText = "—";
            return;
        }
        loading = true;
        errorText = "";
        const xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.deepseek.com/user/balance");
        xhr.setRequestHeader("Authorization", "Bearer " + apiKey);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            loading = false;
            if (xhr.status !== 200) {
                errorText = i18n("Error %1", xhr.status);
                balanceText = "—";
                return;
            }
            try {
                const data = JSON.parse(xhr.responseText);
                const info = data.balance_infos.find(b => b.currency === "CNY");
                if (info) {
                    balanceText = Number(info.total_balance).toFixed(2) + " ¥";
                } else if (data.balance_infos && data.balance_infos.length > 0) {
                    balanceText = data.balance_infos[0].total_balance + " " + data.balance_infos[0].currency;
                } else {
                    balanceText = "?";
                }
            } catch (e) {
                errorText = i18n("Bad response");
                balanceText = "—";
            }
        };
        xhr.send();
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: root.errorText !== "" ? "data-error" : root.deepseekIcon
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
            }

            Kirigami.Heading {
                level: 2
                text: root.loading ? i18n("Loading…") : root.balanceText
            }
        }

        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            level: 5
            visible: root.errorText !== ""
            opacity: 0.7
            text: root.errorText
        }
    }

    compactRepresentation: MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.Plasmoid.expanded = !root.Plasmoid.expanded

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                source: root.errorText !== "" ? "data-error" : root.deepseekIcon
                implicitWidth: Kirigami.Units.iconSizes.roundedIconSize(mouseArea.width)
                implicitHeight: Kirigami.Units.iconSizes.roundedIconSize(mouseArea.width)
                active: mouseArea.containsMouse
            }

            PC3.Label {
                Layout.alignment: Qt.AlignHCenter
                visible: mouseArea.width > Kirigami.Units.iconSizes.roundedIconSize(mouseArea.width) * 1.6
                text: root.loading ? "…" : root.balanceText
                font.pointSize: Math.max(Kirigami.Theme.defaultFont.pointSize - 1, 1)
                color: Kirigami.Theme.textColor
            }
        }
    }

}

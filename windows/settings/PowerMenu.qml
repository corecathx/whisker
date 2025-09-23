import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import qs.preferences
import qs.windows.quickpanel
import qs.components
import qs.modules
import qs.services

BaseMenu {
    id: root
    property real lowHealthThreshold: 70
    title: "Power"
    description: "View battery status and power options."
    property string current_mode: "Balanced"
    
    BaseCard {
        Text {
            text: "Batteries"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        Repeater {
            model: Power.batteries
            delegate: BaseCard {
                color: Appearance.colors.m3surface_container
                RowLayout {
                    Text {
                        text: "Battery " + (index + 1)
                        font.pixelSize: 16
                        font.bold: true
                        color: Appearance.colors.m3on_background
                    }
                    Text {
                        text: modelData.model
                        font.pixelSize: 10
                        color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
                    }
                }
                InfoCard {
                    visible: modelData.healthSupported && modelData.healthPercentage < lowHealthThreshold
                    icon: "error"
                    backgroundColor: Appearance.colors.m3error
                    contentColor: Appearance.colors.m3on_error
                    title: "Critical battery health"
                    description: "Battery health at " + modelData.healthPercentage.toFixed(1) + "%, consider replacing."
                }

                StyledProgressBar {
                    fill: modelData.percentage
                }
                RowLayout {
                    Text {
                        text: (modelData.percentage * 100) + "%"
                        font.pixelSize: 12
                        color: Appearance.colors.m3on_background
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Power.onBattery
                            ? Utils.formatSeconds(modelData.timeToEmpty) || "Calculating"
                            : Utils.formatSeconds(modelData.timeToFull) || "Fully charged"
                        font.pixelSize: 12
                        color: Appearance.colors.m3on_background
                    }
                }
            }
        }
    }
    
    BaseCard {
        Text {
            text: "Power Profiles"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        ExpPowerProfile {}
    }

}

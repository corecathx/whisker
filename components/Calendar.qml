// Calendar.qml (fixed day-label alignment)
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules

BaseCard {
    id: root
    anchors.left: undefined
    anchors.right: undefined
    width: 300
    height: 250
    property int year: new Date().getFullYear()
    property int month: new Date().getMonth()
    property int selectedDay: -1

    function generateMonthGrid(year, month) {
        let grid = []
        let firstDay = new Date(year, month, 1).getDay()
        firstDay = firstDay === 0 ? 7 : firstDay

        let daysInCurrentMonth = new Date(year, month + 1, 0).getDate()
        let prevMonth = month === 0 ? 11 : month - 1
        let prevYear = month === 0 ? year - 1 : year
        let daysInPrevMonth = new Date(prevYear, prevMonth + 1, 0).getDate()

        for (let i = firstDay - 1; i > 0; i--) {
            let day = daysInPrevMonth - i + 1
            grid.push({day: day, isCurrentMonth: false, isToday: false, isWeekend: (new Date(prevYear, prevMonth, day).getDay()===0 || new Date(prevYear, prevMonth, day).getDay()===6)})
        }

        for (let d = 1; d <= daysInCurrentMonth; d++) {
            let date = new Date(year, month, d)
            grid.push({
                day: d,
                isCurrentMonth: true,
                isToday: (d === new Date().getDate() && month === new Date().getMonth() && year === new Date().getFullYear()),
                isWeekend: (date.getDay() === 0)
            })
        }

        let totalCells = 35
        let nextDay = 1
        let nextMonth = month === 11 ? 0 : month + 1
        let nextYear = month === 11 ? year + 1 : year
        while (grid.length < totalCells) {
            let date = new Date(nextYear, nextMonth, nextDay)
            grid.push({
                day: nextDay,
                isCurrentMonth: false,
                isToday: false,
                isWeekend: date.getDay()===0
            })
            nextDay++
        }

        return grid
    }

    Column {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            StyledButton {
                icon: "chevron_left"
                onClicked: {
                    if (root.month === 0) {
                        root.month = 11
                        root.year--
                    } else {
                        root.month--
                    }
                }
                implicitHeight: 30
                secondary: true
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
                font.bold: true
                text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
                color: Appearance.colors.m3on_background
            }
            Item {
                Layout.fillWidth: true
            }
            StyledButton {
                icon: "chevron_right"
                onClicked: {
                    if (root.month === 11) {
                        root.month = 0
                        root.year++
                    } else {
                        root.month++
                    }
                }
                implicitHeight: 30
                secondary: true
            }
        }


        RowLayout {
            id: weekHeader
            width: parent.width
            spacing: 0

            Repeater {
                model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                Label {
                    width: (parent.width-10)/2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    text: modelData
                    color: index > 5 ? Appearance.colors.m3error : Appearance.colors.m3on_background
                }
            }
        }

        // Calendar grid
        Grid {
            id: dayGrid
            columns: 7
            spacing: 2
            width: parent.width-10

            Repeater {
                model: root.generateMonthGrid(root.year, root.month)
                Rectangle {
                    width: Math.floor(dayGrid.width / 7)    // keep consistent with header
                    height: width
                    radius: 20
                    color: modelData.isToday ? Appearance.colors.m3primary_container
                           : modelData.isCurrentMonth && modelData.day === root.selectedDay ? Appearance.colors.m3secondary_container
                           : Appearance.colors.m3background
                    Behavior on color {
                        ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                    }
                    Label {
                        anchors.centerIn: parent
                        text: modelData.day
                        font.pixelSize: modelData.isCurrentMonth ? 12 : 11
                        font.bold: modelData.isToday
                        color: modelData.isCurrentMonth
                               ? (modelData.isWeekend ? Appearance.colors.m3error : Appearance.colors.m3on_background)
                               : Colors.opacify(Appearance.colors.m3on_background, 0.48)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.isCurrentMonth)
                                root.selectedDay = modelData.day
                        }
                    }
                }
            }
        }
    }
}

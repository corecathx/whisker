import QtQuick

Item {
    id: root

    width: 20
    height: 40

    property string position: "left"
    property real level: 0
    property real waveHeight: 2
    property color color: "white"
    property bool running: true

    property real waveOffset: 0

    NumberAnimation on waveOffset {
        running: root.running && root.waveHeight > 0
        from: 0
        to: Math.PI * 2
        duration: 1500
        loops: Animation.Infinite
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            const horizontal = root.position === "top" ||
                               root.position === "bottom"

            const length = horizontal ? width : height
            const size = horizontal ? height : width
            const fill = root.waveHeight

            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.color
            ctx.beginPath()

            const edge = size * root.level

            if (root.position === "left" || root.position === "top")
                ctx.moveTo(0, 0)
            else
                ctx.moveTo(width, height)

            for (let i = 0; i <= length; i++) {
                const wave = Math.sin(
                    i / length * Math.PI * 2 + root.waveOffset
                ) * fill

                if (horizontal)
                    ctx.lineTo(i, root.position === "top"
                        ? edge + fill + wave
                        : height - edge - fill + wave)
                else
                    ctx.lineTo(root.position === "left"
                        ? edge + fill + wave
                        : width - edge - fill + wave, i)
            }

            if (root.position === "left")
                ctx.lineTo(0, height)
            else if (root.position === "right")
                ctx.lineTo(width, 0)
            else if (root.position === "top")
                ctx.lineTo(width, 0)
            else
                ctx.lineTo(0, height)

            ctx.closePath()
            ctx.fill()
        }
    }

    onWaveOffsetChanged: canvas.requestPaint()
    onLevelChanged: canvas.requestPaint()
    onWaveHeightChanged: canvas.requestPaint()
    onPositionChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
}
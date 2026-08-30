import QtQuick
import qs.modules
Item {
    id: root

    property real progress: 0.75
    property real thickness: 2
    property real gap: 20
    property bool animated: true
    property real amplitude: 1.5
    property real frequency: 6
    property real phaseMult: 0.2;

    property color color: Appearance.colors.m3primary
    property color backgroundColor: Appearance.colors.m3primary_container

    implicitWidth: 24
    implicitHeight: implicitWidth

    Canvas {
        id: canvas
        anchors.fill: parent

        property real phase: 0

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const w = width;
            const h = height;

            const cx = w * 0.5;
            const cy = h * 0.5;

            const radius = Math.min(w, h) * 0.5 - root.thickness * 1.5;

            const full = Math.PI * 2;

            const p = Math.max(0, Math.min(1, root.progress));

            const sweep = full * p;

            const gap = (p >= 0.995)
                ? 0
                : root.gap * Math.PI / 180;

            const halfGap = gap * 0.5;

            const filledStart = -Math.PI / 2 + halfGap;
            const filledEnd = filledStart + Math.max(0, sweep - gap);

            const emptyStart = filledEnd + gap;
            const emptyEnd = -Math.PI / 2 + full - halfGap;

            if (p < 0.995) {
                ctx.beginPath();
                ctx.arc(
                    cx,
                    cy,
                    radius,
                    emptyStart,
                    emptyEnd,
                    false
                );

                ctx.strokeStyle = root.backgroundColor;
                ctx.lineWidth = root.thickness;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            if (p > 0) {
                ctx.beginPath();

                const step = Math.PI / 180;

                let first = true;

                for (let a = filledStart; a <= filledEnd; a += step) {

                    const t = (a - filledStart) /
                              Math.max(0.0001, filledEnd - filledStart);

                    const envelope = Math.sin(t * Math.PI);

                    const r =
                        radius +
                        Math.sin(
                            a * root.frequency + phase
                        ) *
                        root.amplitude;

                    const x = cx + Math.cos(a) * r;
                    const y = cy + Math.sin(a) * r;

                    if (first) {
                        ctx.moveTo(x, y);
                        first = false;
                    } else {
                        ctx.lineTo(x, y);
                    }
                }

                ctx.strokeStyle = root.color;
                ctx.lineWidth = root.thickness;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.stroke();
            }
        }

        Timer {
            running: root.animated
            repeat: true
            interval: 16

            onTriggered: {
                canvas.phase += 0.18 * root.phaseMult;
                canvas.requestPaint();
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onProgressChanged: canvas.requestPaint()
    onThicknessChanged: canvas.requestPaint()
    onGapChanged: canvas.requestPaint()
    onAmplitudeChanged: canvas.requestPaint()
    onFrequencyChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onBackgroundColorChanged: canvas.requestPaint()
}
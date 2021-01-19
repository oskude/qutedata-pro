import QtQuick 2.15
import QtQuick.Shapes 1.15

Rectangle {
	color: theme.bg

	Item  { id: boxes; anchors.fill: parent }
	Shape { id: lines; anchors.fill: parent }

	function draw (patch) {
		let boxref = {}
		for (let item of patch) {
			let box = Qt.createComponent("Box.qml")
			boxref[item.id] = box.createObject(boxes, item)
		}
		for (let item of patch) {
			for (let outlet_idx in item.outlets) {
				let o = item.outlets[outlet_idx]
				if (o === null) continue
				let [inlet_idx, target_id] = o.split("_")
				let source = boxref[item.id]
				let target = boxref[target_id]
				let comp = Qt.createComponent("Line.qml")
				let line = comp.createObject(lines, {
					startX: Qt.binding(()=>source.x + source.outletoffsets[outlet_idx]),
					startY: Qt.binding(()=>source.y + source.height),
					endX: Qt.binding(()=>target.x + target.inletoffsets[inlet_idx]),
					endY: Qt.binding(()=>target.y)
				})
				lines.data.push(line)
			}
		}
	}
}

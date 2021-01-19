import QtQuick 2.15

Rectangle {
	id: root
	property alias text: txt.text
	property var inlets: []
	property var outlets: []
	property int letwidth: 8
	property int letheight: 4
	property int inletstep: Math.round((width - letwidth) / (inlets.length - 1))
	property int outletstep: Math.round((width - letwidth) / (outlets.length - 1))
	property var inletoffsets: inlets.map((c,i)=>
		Math.round((width - letwidth) / (inlets.length - 1)) * i + Math.round(letwidth / 2)
	)
	property var outletoffsets: outlets.map((c,i)=>
		Math.round((width - letwidth) / (outlets.length - 1)) * i + Math.round(letwidth / 2)
	)
	implicitWidth: txt.width
	implicitHeight: txt.height
	color: theme.bg
	border.color: theme.fg
	border.width: 1
	Text {
		id: txt
		text: "empty"
		color: theme.fg
		font.family: "monospace"
		font.pixelSize: 14
		// TODO:FIX font.pixelSize: 15
		leftPadding: 6
		rightPadding: leftPadding
		topPadding: 4
		bottomPadding: topPadding
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.SizeAllCursor
		drag.target: parent
		drag.smoothed: false
		drag.threshold: 0
	}
	Repeater {
		model: inlets
		Rectangle {
			width: root.letwidth
			height: root.letheight
			color: theme.fg
			x: root.inletoffsets[index] - Math.round(width / 2)
		}
	}
	Repeater {
		model: outlets
		Rectangle {
			width: root.letwidth
			height: root.letheight
			color: theme.fg
			x: root.outletoffsets[index] - Math.round(width / 2)
			y: root.height - height
		}
	}
}

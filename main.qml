#!/usr/bin/env -S QML_XHR_ALLOW_FILE_READ=1 QML_XHR_ALLOW_FILE_WRITE=1 qml

import QtQuick 2.15
import "./lib/" as Pd

Item {
	width: 320
	height: 240
	property var theme: {}

	Pd.Canvas {
		id: canvas
		anchors.fill: parent
	}

	Component.onCompleted: {
		theme = {
			bg: "#161616",
			fg: "#606060"
		}
		let patch = loadPatch()
		canvas.draw(patch)
	}

	function loadPatch () {
		let args = Qt.application.arguments.slice(2)
		if (args[0] == "--") args = args.slice(1)
		return JSON.parse(readFile(args[0]))
	}

	function readFile (path) {
		let req = new XMLHttpRequest()
		req.open("GET", path, false)
		req.send(null)
		return req.responseText
	}
}

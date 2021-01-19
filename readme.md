# qutedata-pro

![screencap](screencap.gif?raw=true)

(tiny) experiment on making (some features of) pd-patch editor in qml/js.

just cause i wanted to know if i can, have no use-case for puredata at the moment, (always rage quit tcl/tk), am really facinated by puredata (or visual data/flow things), in case i (or anyone) need any of these ideas/things/notes later... or i have just too much fun with qml, send help ;P

whatever, all files in this repo - _where i have the say about_ - shall be in public domain.

_ps. "pro" stands for "procastination/prototype", right?_

## features

- read pd-patch definition from json file
- draw every pd-patch item as box
- draw all pd-patch connection lines
- drag the boxes with mouse

## requirements

- to run: [qt5-base](https://archlinux.org/packages/extra/x86_64/qt5-base/) and [qt5-declarative](https://archlinux.org/packages/extra/x86_64/qt5-declarative/)
- for what: [puredata](http://puredata.info/) [patches](http://msp.ucsd.edu/Pd_documentation/x2.htm)
- to code: [qml](https://doc.qt.io/qt-5/qmlapplications.html) [knowledge](https://qmlbook.github.io/)
- to code: [javascript](https://developer.mozilla.org/en-US/docs/Web/javascript) [knowledge](https://doc.qt.io/qt-5/qtqml-javascript-expressions.html)

<br>

## [`patch.json`](./patch.json)

to make my life easier, the used pd-patch files are defined as json file. that has an array of objects:

```json
[
	{
		"id": "hash1",
		"text": "HELLO",
		"inlets": [],
		"outlets": ["1_hash2", null, "0_hash2"],
		"x": 130,
		"y": 60
	},
	...
]
```

> in theory, to implement the different types of pd-patch boxes, one could add a "type" field to the json, and inherit the different qml implementations from Box.qml...

> and i assume it would be trivial (at least the non-talk-to-pd-part) to write vanilla pd patch import/export...

<br>

## [`Line.qml`](./lib/Line.qml)

the simplest of all, draw a line from [ShapePath](https://doc.qt.io/qt-5/qml-qtquick-shapes-shapepath.html) `startX/startY` to [PathLine](https://doc.qt.io/qt-5/qml-qtquick-pathline.html) `x/y`:

```qml
ShapePath {
	property alias endX: path.x
	property alias endY: path.y
	PathLine {
		id: path
	}
}
```

> NOTE: to see anything drawn, the [ShapePath](https://doc.qt.io/qt-5/qml-qtquick-shapes-shapepath.html) has to be a child of [Shape](https://doc.qt.io/qt-5/qml-qtquick-shapes-shape.html). and if added through javascript, has to be also added to Shape.data list.

> INFO: the `endX/endY` [aliases](https://doc.qt.io/qt-5/qtqml-syntax-objectattributes.html) are just for convenience/uniformity

> TODO: can haz antialiased lines?

<br>

## [`Box.qml`](./lib/Box.qml)

still pretty simple, just a [Rectangle](https://doc.qt.io/qt-5/qml-qtquick-rectangle.html) with [Text](https://doc.qt.io/qt-5/qml-qtquick-text.html)

```qml
Rectangle {
	property alias text: txt.text
	Text {
		id: txt
	}
}
```

we get the boxes inlet and outlet (iolets) target definitions from the json file:

```qml
property var inlets: []
property var outlets: []
```

we define the iolets distance of each other
```qml
property int inletstep: Math.round((width - letwidth) / (inlets.length - 1))
property int outletstep: Math.round((width - letwidth) / (outlets.length - 1))
```

to make drawing the lines (and iolets) easier, we define all the iolets center x positions relative to the box
```qml
property var inletoffsets: inlets.map((c,i)=>
	Math.round((width - letwidth) / (inlets.length - 1)) * i + Math.round(letwidth / 2)
)
property var outletoffsets: outlets.map((c,i)=>
	Math.round((width - letwidth) / (outlets.length - 1)) * i + Math.round(letwidth / 2)
)
```

the iolets are simple to draw with [Repeater](https://doc.qt.io/qt-5/qml-qtquick-repeater.html) model:
```qml
Repeater {
	model: inlets
	Rectangle {
		width: root.letwidth
		height: root.letheight
		x: root.inletoffsets[index] - Math.round(width / 2)
	}
}
```

to make the box movable, we use [MouseArea](https://doc.qt.io/qt-5/qml-qtquick-mousearea.html) drag:
```qml
MouseArea {
	anchors.fill: parent
	drag.target: parent
}
```

> i guess it should be pretty trivial to make the box editable. (and a function to ask pd for the details/state/callback...)

<br>

## [`Canvas.qml`](./lib/Canvas.qml)

define parents for all the boxes and lines:
```qml
Item  { id: boxes; anchors.fill: parent }
Shape { id: lines; anchors.fill: parent }
```

> side-note: to draw lines before/below(in z-axis) boxes, just swap these two lines..

draw all the pd-patch boxes:

```javascript
for (let item of patch) {
	let box = Qt.createComponent("Box.qml")
	boxref[item.id] = box.createObject(boxes, item)
}
```

- `patch` is the json file instanciated as a javascript object, and as the root is an array, we simply loop through all of its items.
- `box` is some qml thing (TODO) and to actually draw it, we add it to `boxes` and pass the patch `item` object as attributes to the new qml component.
- `boxref` is just there so when we draw the lines, we have all the box references.
- `boxes` is the id of the qml parent component where to draw these

draw all the pd-patch box connection lines:

```javascript
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
```

the coolest part (what qml things do by default, but some js things have to define manually) is the `Qt.binding()` functions, those keep the values up to date. (so when we move a box, the lines move automagically)

<br>

## [`main.qml`](./main.qml)

import our custom components in some namespace:
```qml
import "./lib/" as Pd
```

place the canvas where to draw our patch:
```qml
Pd.Canvas {
	id: canvas
	anchors.fill: parent
}
```

get the patch file how-ever, and draw the pd-patch:
```javascript
canvas.draw(patch)
```

and i could not resist to use my colors as default, please do match to your environment:
```
theme = {
	bg: "#161616",
	fg: "#606060"
}
```

<br>

## run it

on systems with hashbang support:

```shell
> ./main.qml -- patch.json
```

on systems without hashbang support:
```shell
> QML_XHR_ALLOW_FILE_READ=1 qml main.qml -- patch.json
```

> TODO: bug or feature? without `--`  as first argument, qml spits errors, yet works...

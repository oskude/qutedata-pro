import QtQuick 2.15
import QtQuick.Shapes 1.15

ShapePath {
	property alias endX: path.x
	property alias endY: path.y
	strokeColor: theme.fg
	strokeWidth: 1
	PathLine {
		id: path
	}
}

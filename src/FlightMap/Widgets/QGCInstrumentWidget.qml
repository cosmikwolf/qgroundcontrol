/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.Palette       1.0

import QGroundControl.Vehicle       1.0
import QtQuick.Window               2.2

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelHeight / 4

    property real   _innerRadius:           (width - (_topBottomMargin * 3)) / 4
    property real   _outerRadius:           _innerRadius + _topBottomMargin
    property real   _spacing:               ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:       (width * 0.05) / 2

    QGCPalette { id: qgcPal }

    Rectangle {
        id:                 visualInstrument
        height:             _outerRadius * 2
        Layout.fillWidth:   true
        radius:             _outerRadius
        color:              qgcPal.window

        DeadMouseArea { anchors.fill: parent }

        QGCAttitudeWidget {
            id:                     attitude
            anchors.leftMargin:     _topBottomMargin
            anchors.left:           parent.left
            size:                   _innerRadius * 2
            vehicle:                globals.activeVehicle
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCCompassWidget {
            id:                     compass
            anchors.leftMargin:     _spacing
            anchors.left:           attitude.right
            size:                   _innerRadius * 2
            vehicle:                globals.activeVehicle
            anchors.verticalCenter: parent.verticalCenter
        }
    }  

    property int _currentCommand: -1

    QGCButton {
        id: winchEmergency
        anchors.top: visualInstrument.bottom
        anchors.topMargin: Window.height - 370
        property var _active: false
        height:             _outerRadius
        Layout.fillWidth:   true
        text: "Emergency release"
        background: Rectangle {
            color:  "red"
        }
        onClicked: {
            _currentCommand = 0;
            winchDeliver.checked = winchDeliver._active = false;
            winchRetract.checked = winchRetract._active = false;
            if (_active) {checked = false; slider.visible = false}
            else {checked = true; slider.visible = true; slider.confirmText = qsTr("Emergency release winch")}
            _active = !_active
        }
    }

    QGCButton {
        id: winchDeliver
        anchors.top: winchEmergency.bottom
        anchors.topMargin: 5
        property var _active: false
        height:             _outerRadius
        Layout.fillWidth:   true
        text: "Deliver payload"
        onClicked: {
            _currentCommand = 4;
            winchEmergency.checked = winchEmergency._active = false;
            winchRetract.checked = winchRetract._active = false;
            if (_active) {checked = false; slider.visible = false}
            else {checked = true; slider.visible = true; slider.confirmText = qsTr("Perform payload drop")}
            _active = !_active
        }
    }

    QGCButton {
        id: winchRetract
        anchors.top: winchDeliver.bottom
        anchors.topMargin: 5
        property var _active: false 
        height:             _outerRadius
        Layout.fillWidth:   true
        text: "Retract winch"
        onClicked: {
            _currentCommand = 6;
            winchEmergency.checked = winchEmergency._active = false;
            winchDeliver.checked = winchDeliver._active = false;
            if (_active) {checked = false; slider.visible = false}
            else {checked = true; slider.visible = true; slider.confirmText = qsTr("Perform winch retract")}
            _active = !_active
        }
    }

    SliderSwitch {
        id:                             slider
        anchors.top:                    winchRetract.bottom
        anchors.topMargin:              5
        property var _activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
        confirmText:                    qsTr("Perform winch action")
        Layout.fillWidth:               true
        visible:                        false
        onAccept: {
            if (_currentCommand != -1) {
                winchDeliver.checked = winchDeliver._active = false
                winchEmergency.checked = winchEmergency._active = false
                winchRetract.checked = winchRetract._active = false
                _activeVehicle.sendCommand(42, 42600, 1, 1, _currentCommand, 1, 1)
                _currentCommand = -1
                visible = false
            }
        }
    }

    TerrainProgress {
        Layout.fillWidth: true
    }
}

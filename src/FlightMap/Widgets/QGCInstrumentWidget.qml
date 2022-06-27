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
import MAVLink                      1.0

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

    enum WinchCommands {
        RELEASE = 0,
        DELIVER = 4,
        RETRACT = 6
    }
    
    property int _currentCommand:   -1
    property int _WinchNodeID:      42
    property int _MAVLink_CMD_ID:   42600

    QGCButton {
        id:                         winchEmergency
        anchors.top:                visualInstrument.bottom
        anchors.topMargin:          Window.height - 370
        backRadius:                 10
        showBorder:                 true
        height:                     _outerRadius
        Layout.fillWidth:           true
        text:                       "Emergency release"
        background:                 Rectangle {
            color:                  "red"
            radius:                 10
            border.color:           "white"
            border.width:           1
        }
        checkable:                  true
        Image {
            id:                     alert
            source:                 "/qmlimages/Yield.svg"
            height:                 parent.height
            width:                  height
            x:                      10
        }
        onClicked:  {
            _currentCommand = QGCInstrumentWidget.WinchCommands.RELEASE;
            winchDeliver.checked = winchRetract.checked = false;
            if (checked) {slider.visible = true; slider.confirmText = qsTr("Emergency release winch")}
            else {slider.visible = false}
        }
    }

    QGCButton {
        id:                         winchDeliver
        anchors.top:                winchEmergency.bottom
        anchors.topMargin:          5
        backRadius:                 10
        showBorder:                 true
        height:                     _outerRadius
        Layout.fillWidth:           true
        text:                       "Deliver payload"
        checkable:                  true
        Image {
            id:                     downArrow
            source:                 "/qmlimages/ArrowDirection.svg"
            height:                 parent.height
            width:                  height
            x:                      10
            transform: Rotation {
                origin.x:           downArrow.width/2
                origin.y:           downArrow.height/2
                angle:              180
            }
        }
        onClicked: {
            _currentCommand = QGCInstrumentWidget.WinchCommands.DELIVER;
            winchEmergency.checked = winchRetract.checked = false;
            if (checked) {slider.visible = true; slider.confirmText = qsTr("Perform payload drop")}
            else {slider.visible = false}
        }
    }

    QGCButton {
        id:                         winchRetract
        anchors.top:                winchDeliver.bottom
        anchors.topMargin:          5
        backRadius:                 10
        showBorder:                 true
        height:                     _outerRadius
        Layout.fillWidth:           true
        text:                       "Retract winch"
        checkable:                  true
        Image {
            id:                     upArrow
            source:                 "/qmlimages/ArrowDirection.svg"
            height:                 parent.height
            width:                  height
            x:                      10
        }
        onClicked: {
            _currentCommand = QGCInstrumentWidget.WinchCommands.RETRACT;
            winchEmergency.checked = winchDeliver.checked = false;
            if (checked) {slider.visible = true; slider.confirmText = qsTr("Perform winch retract")}
            else {slider.visible = false}
        }
    }

    SliderSwitch {
        id:                             slider
        anchors.top:                    winchRetract.bottom
        anchors.topMargin:              5
        property var _vehicle:          QGroundControl.multiVehicleManager.activeVehicle
        visible:                        false
        confirmText:                    qsTr("Not visible")
        Layout.fillWidth:               true
        onAccept: {
            winchDeliver.checked = winchEmergency.checked = winchRetract.checked = false;
            _vehicle.sendCommand(_WinchNodeID, _MAVLink_CMD_ID, 1, 1, _currentCommand, 1, 1);
            _currentCommand = -1;
            visible = false;
        }
    }

    TerrainProgress {
        Layout.fillWidth: true
    }
}

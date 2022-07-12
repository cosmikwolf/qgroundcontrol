
import QtQuick          2.12
import QtQuick.Layouts  1.12
import QtQuick.Window               2.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0

import MAVLink                      1.0

Rectangle {
    id:                                     winchControlRect
    
    // MAVLink definitions not yet implemented in QGC.
    // Using the actions from https://mavlink.io/en/messages/common.html#WINCH_ACTIONS
    enum WinchCommands {
        WINCH_RELAXED = 0,
        WINCH_DELIVER = 4,
        WINCH_RETRACT = 6
    }

    property var    _currentWinchCommand:   null
    //MAV_COMP_ID_USER18(42) is the chosen component for winches
	// since no winch defaults exist yet in the MAVLink standard.
    property int    _winch_node_id:         42    
    // The QML MAVLink enum doesn't include MAV_CMD_DO_WINCH(42600).
    // Setting it explicitly. See src/comm/QGCMAVLink.h for details.           
    property int    _winch_mavlink_cmd_id:  42600
    property real   _topBottomMargin:       (width * 0.05) / 2

    Layout.fillWidth:               true
    anchors.bottom:                 parent.bottom
    QGCButton {
        id:                         winchEmergencyBtn
        backRadius:                 10
        showBorder:                 true
        width:                      parent.width
        text:                       "Emergency release"
        background:                 Rectangle {
            color:                  "red"
            radius:                 10
            border.color:           "white"
            border.width:           1
        }
        checkable:                  true
        anchors.bottom:             winchDeliverBtn.top
        anchors.bottomMargin:       _topBottomMargin
        Image {
            id:                     alert
            source:                 "/qmlimages/Yield.svg"
            height:                 parent.height
            width:                  height
            x:                      10
        }
        onClicked:  winchRelax()

        function winchRelax() {
            _currentWinchCommand = WinchControl.WinchCommands.WINCH_RELAXED;
            winchDeliverBtn.checked = false;
            winchRetractBtn.checked = false;
            if (checked) {
                slider.visible = true;
                slider.confirmText = qsTr("Emergency release winch")}
            else {
                slider.visible = false
            }
        }
    }

    QGCButton {
        id:                         winchDeliverBtn
        backRadius:                 10
        showBorder:                 true
        width:                      parent.width
        text:                       "Deliver payload"
        checkable:                  true
        anchors.bottom:             winchRetractBtn.top
        anchors.bottomMargin:       _topBottomMargin
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
        onClicked:  winchDeliver()
        
        function winchDeliver() {
            _currentWinchCommand = WinchControl.WinchCommands.WINCH_DELIVER;
            winchEmergencyBtn.checked = false;
            winchRetractBtn.checked = false;
            if (checked) {
                slider.visible = true;
                slider.confirmText = qsTr("Perform payload drop")}
            else {
                slider.visible = false
            }
        }
    }

    QGCButton {
        id:                         winchRetractBtn
        backRadius:                 10
        showBorder:                 true
        width:                      parent.width
        text:                       "Retract winch"
        checkable:                  true
        anchors.bottom:             slider.top
        anchors.bottomMargin:       _topBottomMargin
        Image {
            id:                     upArrow
            source:                 "/qmlimages/ArrowDirection.svg"
            height:                 parent.height
            width:                  height
            x:                      10
        }
        onClicked: winchRetract()
        
        function winchRetract() {
            _currentWinchCommand = WinchControl.WinchCommands.WINCH_RETRACT;
            winchEmergencyBtn.checked = false;
            winchDeliverBtn.checked = false;
            if (checked) {
                slider.visible = true;
                slider.confirmText = qsTr("Perform winch retract")}
            else {
                slider.visible = false
            }
        }
    }

    SliderSwitch {
        id:                             slider
        property var _vehicle:          QGroundControl.multiVehicleManager.activeVehicle
        visible:                        false
        width:                          parent.width
        confirmText:                    qsTr("Not visible")
        anchors.bottom:                 parent.bottom
        anchors.bottomMargin:           2 * _topBottomMargin
        onAccept: sendWinchCommand()
        
        function sendWinchCommand() {
            winchDeliverBtn.checked = false;
            winchEmergencyBtn.checked = false;
            winchRetractBtn.checked = false;
            if (_currentWinchCommand !== null) {
                _vehicle.sendCommand(_winch_node_id, _winch_mavlink_cmd_id, 1, 1, _currentWinchCommand, 1, 1);
            }
            _currentWinchCommand = null;
            visible = false;
        }
    }
}


#!/usr/bin/env python3
"""BlueZ pairing agent for the Quickshell Bluetooth panel.

Quickshell ships no org.bluez.Agent1, so pairing any device that asks for
confirmation (keyboards, headsets, phones, ...) fails without this. It
registers once with BlueZ and accepts every request.

Started automatically by shell.qml. Run manually: python3 scripts/bt-agent.py
"""

import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

PATH = "/qs/btagent"
IFACE = "org.bluez.Agent1"
MANAGER = "org.bluez.AgentManager1"
CAPABILITY = "KeyboardDisplay"


class Agent(dbus.service.Object):
    @dbus.service.method(IFACE, in_signature="", out_signature="")
    def Release(self): pass

    @dbus.service.method(IFACE, in_signature="", out_signature="")
    def Cancel(self): pass

    @dbus.service.method(IFACE, in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid): pass

    @dbus.service.method(IFACE, in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode): pass

    @dbus.service.method(IFACE, in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered): pass

    @dbus.service.method(IFACE, in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey): pass

    @dbus.service.method(IFACE, in_signature="o", out_signature="")
    def RequestAuthorization(self, device): pass

    @dbus.service.method(IFACE, in_signature="o", out_signature="s")
    def RequestPinCode(self, device): return "0000"

    @dbus.service.method(IFACE, in_signature="o", out_signature="u")
    def RequestPasskey(self, device): return dbus.UInt32(0)


dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
Agent(bus, PATH)
manager = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), MANAGER)
manager.RegisterAgent(PATH, CAPABILITY)
try:
    manager.RequestDefaultAgent(PATH)
except dbus.DBusException:
    pass
GLib.MainLoop().run()

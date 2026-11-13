#!/usr/bin/env python3
"""BlueZ pairing agent for the Quickshell Bluetooth panel.

Quickshell ships no org.bluez.Agent1, so pairing fails without one. It
registers once and accepts every request. Started by shell.qml.
"""

import sys

import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

PATH = "/qs/btagent"
IFACE = "org.bluez.Agent1"
MANAGER = "org.bluez.AgentManager1"
CAPABILITY = "KeyboardDisplay"
EXIT_NO_BLUEZ = 2  # keep in sync with btAgentNoBluez in shell.qml


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
try:
    manager = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), MANAGER)
    manager.RegisterAgent(PATH, CAPABILITY)
except dbus.DBusException as error:
    print(f"bt-agent: BlueZ unavailable: {error}", file=sys.stderr)
    sys.exit(EXIT_NO_BLUEZ)
try:
    manager.RequestDefaultAgent(PATH)
except dbus.DBusException:
    pass
GLib.MainLoop().run()

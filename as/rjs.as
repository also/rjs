/*
 * Copyright 2008 Ryan Berdeen.
 *
 * This file is part of rjs.
 *
 * rjs is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * rjs is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with rjs.  If not, see <http://www.gnu.org/licenses/>.
 */

import flash.external.ExternalInterface;

var socket:XMLSocket;

function connect(hostname:String, port:int) {
	socket = new XMLSocket();
	socket.addEventListener(Event.CONNECT, onSocketConnect);
	socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError);
	socket.addEventListener(DataEvent.DATA, onSocketData);
	socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketIoError);
	socket.addEventListener(Event.CLOSE, onSocketClose);

	socket.connect(hostname, port);
}

function send(data:String) {
	socket.send(data);
}

function close() {
	socket.close();
}

function onSocketConnect(event:Event) {
	doCallback('onSocketConnect');
}

function onSocketSecurityError(event:SecurityErrorEvent) {
	doCallback('onSocketSecurityError');
}

function onSocketData(event:DataEvent) {
	ExternalInterface.call("rjs._onData", event.data);
}

function onSocketIoError(event:IOErrorEvent) {
	doCallback('onSocketIoError');
}

// NOTE: only called when the server closes the connection
function onSocketClose(event:Event) {
	doCallback('onSocketClose');
}

function doCallback(callback:String) {
	ExternalInterface.call('rjs._callback', callback);
}

ExternalInterface.marshallExceptions = true;
ExternalInterface.addCallback('connect', connect);
ExternalInterface.addCallback('send', send);
ExternalInterface.addCallback('close', close);

ExternalInterface.call("rjs._onLoad");
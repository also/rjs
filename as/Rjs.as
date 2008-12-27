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

package {
  import flash.display.Sprite;
  import flash.events.DataEvent;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.external.ExternalInterface;
  import flash.net.XMLSocket;

  public class Rjs extends Sprite {
    private var socket:XMLSocket;

    private function connect(hostname:String, port:Number):void {
      socket = new XMLSocket();
      socket.addEventListener(Event.CONNECT, onSocketConnect);
      socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError);
      socket.addEventListener(DataEvent.DATA, onSocketData);
      socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketIoError);
      socket.addEventListener(Event.CLOSE, onSocketClose);

      socket.connect(hostname, port);
    }

    private function send(data:String):void {
      socket.send(data);
    }

    private function close():void {
      socket.close();
    }

    private function onSocketConnect(event:Event):void {
      this.send('hi');
      doCallback('onSocketConnect');
    }

    private function onSocketSecurityError(event:SecurityErrorEvent):void {
      doCallback('onSocketSecurityError');
    }

    private function onSocketData(event:DataEvent):void {
      ExternalInterface.call("rjs._onData", escape(event.data));
    }

    // ExternalInterface doesn't escape backslashes in strings, which are
    // passed as javascript string literals
    private function escape(string:String):String {
        return string.replace(/\\/g, '\\\\');
    }

    private function onSocketIoError(event:IOErrorEvent):void {
      doCallback('onSocketIoError');
    }

    // NOTE: only called when the server closes the connection
    private function onSocketClose(event:Event):void {
      doCallback('onSocketClose');
    }

    private function doCallback(callback:String):void {
      ExternalInterface.call('rjs._callback', escape(callback));
    }
  
    public static function main():void {
      var rjs:Rjs = new Rjs();
      ExternalInterface.marshallExceptions = true;
      ExternalInterface.addCallback('connect', rjs.connect);
      ExternalInterface.addCallback('send', rjs.send);
      ExternalInterface.addCallback('close', rjs. close);

      ExternalInterface.call("rjs._onLoad");
    }
  }
}

Rjs.main();
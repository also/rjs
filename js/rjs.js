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

var rjs = {
  swfUrl: 'rsj.swf',

  connect: function(hostname, port, options) {
    this._hostname = hostname;
    this._port = port;
    rjs._init(options);
  },

  _init: function(options) {
    this._options = options;

    var element = document.createElement('div');
    element.id = '_rjs_swf';
    document.body.appendChild(element);

    // internet explorer 6 will hang/crash if we embed flash in our new element 
    window.setTimeout(function() {
      swfobject.embedSWF(rjs.swfUrl, '_rjs_swf', 1, 1, '9.0.0');
    }, 0);
  },

  _onLoad: function() {
    rjs._swfObject = document.getElementById('_rjs_swf');
    rjs._swfObject.connect(rjs._hostname, rjs._port);
  },

  _callback: function(callbackName) {
    if (rjs._options[callbackName]) {
      rjs._options[callbackName]();
    }
    else if (rjs._options.onEvent) {
      rjs._options.onEvent(callbackName);
    }
  },

  _onData: function(data) {
    rjs._options.onReceive(data);
  },

  send: function(data) {
    rjs._swfObject.send(data);
  },

  disconnect: function() {
    rjs._swfObject.close();
  }
};

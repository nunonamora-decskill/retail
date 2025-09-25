cordova.define("com.oracle.xstoremobile.hardware.hardware", function(require, exports, module) {
var exec = require('cordova/exec'),
    posHardwareEvent = require('./posHardwareEvent');

/**
 * Internal state.
 */
var hardware = function () {
    this.hardwareProperties = null;
    this.iOSModelCode = null;
};

/**
 * Callback for hardware status
 *
 * @param {Object} info         \
 */
hardware.prototype._status = function (info) {
    var me = hardwareInstance;
    me.hardwareProperties = info['hardwareProperties'];
    me.iOSModelCode = info['iOSModelCode'];
};

/**
 * Default error handler.
 */
hardware.prototype._error = function(e) {
};

/**
 * Register callback with device to be called when input event occurs.
 * Part of public API.
 */
hardware.prototype.registerHardwareEventCallback = function(successCallback, errorCallback) {
  var me = hardwareInstance;

  exec(function(pluginDataMap) {
    var eventId = pluginDataMap['eventId'];
    var eventData = pluginDataMap['eventData'];
    
    var returnObject = new posHardwareEvent(eventId, eventData);
    successCallback(returnObject);
  }, errorCallback, "hardware", "registerHardwareEventCallback", [] );

};

/**
 * Initializes hardware.
 * Part of public API.
 */
hardware.prototype.init = function(responseCallback) {
  var me = hardwareInstance;
  
  exec(function(resultMap) {
    me._status(resultMap);
    responseCallback();
  }, me._error, "hardware", "init", []);

};

/**
 * Re-initializes hardware.
 * Part of public API.
 */
hardware.prototype.reinit = function() {
	var me = hardwareInstance;
	
	exec(function(resultMap) {
		me._status(resultMap);
	}, me._error, "hardware", "reinit", []);
};

/**
 * Passes command and arguments to native layer and returns result.
 * Part of public API.
 */
hardware.prototype.runNativeCommand = function(command, params, responseCallback) {
  var me = hardwareInstance;

  exec(function(pluginDataMap) {
    responseCallback();
  }, me._error, "hardware", "runNativeCommand", [command, params]);
    
};

var hardwareInstance = new hardware();

module.exports = hardwareInstance;
});

cordova.define("com.oracle.xstoremobile.keyboard.keyboard", function(require, exports, module) {
var exec = require('cordova/exec');

var Keyboard = function () {};

Keyboard.hide = function () {
    exec(null, null, "Keyboard", "hide", []);
};

Keyboard.show = function () {};

module.exports = Keyboard;
});

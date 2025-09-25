cordova.define("com.oracle.xstoremobile.screenutil.screenutil", function(require, exports, module) {
var exec = require('cordova/exec'),
    screenutil = {
        /** Do any sort of screen initialization work that should be happen when the application starts. */
        initializeScreen:function() {
            exec(null, null, "ScreenUtil", "setInitialParameters", []);
        },

        writeConnectionInfo:function(serverUrl, installToken, retailLocationId, workstationId) {
            exec(null, null, "ScreenUtil", "writeConnectionInfo", [serverUrl, installToken, retailLocationId, workstationId]);
        }
    };

module.exports = screenutil;
});

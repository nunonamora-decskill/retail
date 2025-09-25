cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin-inappbrowser.inappbrowser",
      "file": "plugins/cordova-plugin-inappbrowser/www/inappbrowser.js",
      "pluginId": "cordova-plugin-inappbrowser",
      "clobbers": [
        "cordova.InAppBrowser.open"
      ]
    },
    {
      "id": "@globules-io/cordova-plugin-ios-xhr.formdata-polyfill",
      "file": "plugins/@globules-io/cordova-plugin-ios-xhr/src/www/ios/formdata-polyfill.js",
      "pluginId": "@globules-io/cordova-plugin-ios-xhr",
      "runs": true
    },
    {
      "id": "@globules-io/cordova-plugin-ios-xhr.xhr-polyfill",
      "file": "plugins/@globules-io/cordova-plugin-ios-xhr/src/www/ios/xhr-polyfill.js",
      "pluginId": "@globules-io/cordova-plugin-ios-xhr",
      "runs": true
    },
    {
      "id": "@globules-io/cordova-plugin-ios-xhr.fetch-bootstrap",
      "file": "plugins/@globules-io/cordova-plugin-ios-xhr/src/www/ios/fetch-bootstrap.js",
      "pluginId": "@globules-io/cordova-plugin-ios-xhr",
      "runs": true
    },
    {
      "id": "@globules-io/cordova-plugin-ios-xhr.fetch-polyfill",
      "file": "plugins/@globules-io/cordova-plugin-ios-xhr/src/www/ios/whatwg-fetch-2.0.3.js",
      "pluginId": "@globules-io/cordova-plugin-ios-xhr",
      "runs": true
    },
    {
      "id": "cordova-plugin-statusbar.statusbar",
      "file": "plugins/cordova-plugin-statusbar/www/statusbar.js",
      "pluginId": "cordova-plugin-statusbar",
      "clobbers": [
        "window.StatusBar"
      ]
    },
    {
      "id": "phonegap-plugin-barcodescanner.BarcodeScanner",
      "file": "plugins/phonegap-plugin-barcodescanner/www/barcodescanner.js",
      "pluginId": "phonegap-plugin-barcodescanner",
      "clobbers": [
        "cordova.plugins.barcodeScanner"
      ]
    },
    {
      "id": "com.oracle.xstoremobile.keyboard.keyboard",
      "file": "plugins/com.oracle.xstoremobile.keyboard/www/ios/keyboard.js",
      "pluginId": "com.oracle.xstoremobile.keyboard",
      "clobbers": [
        "window.Keyboard"
      ]
    },
    {
      "id": "com.oracle.xstoremobile.hardware.hardware",
      "file": "plugins/com.oracle.xstoremobile.hardware/www/hardware.js",
      "pluginId": "com.oracle.xstoremobile.hardware",
      "clobbers": [
        "hardware"
      ]
    },
    {
      "id": "com.oracle.xstoremobile.hardware.posHardwareEvent",
      "file": "plugins/com.oracle.xstoremobile.hardware/www/posHardwareEvent.js",
      "pluginId": "com.oracle.xstoremobile.hardware",
      "clobbers": [
        "posHardwareEvent"
      ]
    },
    {
      "id": "com.oracle.xstoremobile.screenutil.screenutil",
      "file": "plugins/com.oracle.xstoremobile.screenutil/www/ScreenUtil.js",
      "pluginId": "com.oracle.xstoremobile.screenutil",
      "clobbers": [
        "screenutil"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-inappbrowser": "5.0.0",
    "@globules-io/cordova-plugin-ios-xhr": "1.2.4",
    "cordova-plugin-migrate-localstorage": "0.0.2",
    "cordova-plugin-splashscreen": "6.0.1",
    "cordova-plugin-statusbar": "3.0.0",
    "phonegap-plugin-barcodescanner": "8.1.0",
    "com.oracle.xstoremobile.keyboard": "1.0.0",
    "com.oracle.xstoremobile.hardware": "1.0.0",
    "com.oracle.xstoremobile.logging": "1.0.0",
    "com.oracle.xstoremobile.screenutil": "1.0.0"
  };
});
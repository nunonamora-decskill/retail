// Copyright (c) 2004, 2021, Oracle and/or its affiliates. All rights reserved.

/**
 * This Javascript class is a wrapper class for a 3rd party qrcode image generation library.  I've wrapped
 * it for two reasons, 1) to make GWT JsInterop work smoothly so we can use this functionality in Java
 * client code, 2) to simplify and reshape the API to be closer to what we need in Xstore Mobile.
 * 
 * THE 3RD PARTY LIBRARY IS: qrcode-generator
 * 
 * We really only need/use 1 specific file from qrcode-generator: qrcode.js
 *
 * For now, since this is the only 3rd-party JS library needed by xstoremgwt (not part of a Cordova plugin),
 * I've added a special build target in the xstoremgwt_cordova project "update-qrcode-generator", which will
 * reach out to our Oracle-sanctioned npm repository to acquire this library, and allow us to keep track of
 * which version we're using.  The build target also copies qrcode.js from xstoremgwt_cordova/node_modules to
 * the proper location, here in this directory where this file (xmqrcode.js) lives.
 * 
 * If we start using more 3rd party JS libraries, the right thing to do would be to update this xstoremgwt
 * project to integrate properly with npm, sort of how the xstoremgwt_cordova project does (some things
 * from that project would also need refactored, probably moved into our nodejs project so multiple other
 * projects can make use of it).
 * 
 * See the XMQRCode.java JsInterop class for additional details.
 *
 * @author REDACTED
 * @created March 16, 2020
 * @since 20.0
 */
class XMQRCode {
  constructor(targetElementId, sizeLimitPixels, marginPixels) {
    this.targetElementId = targetElementId;
    var szInfo = this.findQRCodeActualSize(sizeLimitPixels, marginPixels);
    this.cellSize = szInfo.cellSz;
    this.marginPx = marginPixels;
    this.actualSizePixels = szInfo.sz;
  }
    
  show(uuid) {
    var qr = qrcode(4, 'Q');
    qr.addData(uuid);
    qr.make();
    document.getElementById(this.targetElementId).innerHTML = qr.createImgTag(this.cellSize, this.marginPx);
  }

  findQRCodeActualSize(sizeLimitPixels, marginPixels) {
    var cellSz = 0;
    var sz = 0;
    var prevSz = 0;
    do {
      prevSz = sz;
    }
    while((sz = (++cellSz *37) + (marginPixels*2)) <= sizeLimitPixels);

    return {"sz":prevSz,"cellSz":cellSz-1};
  }
}

// "Export" this class into Javascript's "window" namespace, so GWT/JsInterop can access it.
window.XMQRCode = XMQRCode;

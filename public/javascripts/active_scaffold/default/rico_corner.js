/**
  *
  *  Copyright 2005 Sabre Airline Solutions
  *
  *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *
  *         http://www.apache.org/licenses/LICENSE-2.0
  *
  *  Unless required by applicable law or agreed to in writing, software distributed under the
  *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
  *  either express or implied. See the License for the specific language governing permissions
  *  and limitations under the License.
  **/


//-------------------- rico.js
var Rico = {
  Version: '1.1.0',
  prototypeVersion: parseFloat(Prototype.Version.split(".")[0] + "." + Prototype.Version.split(".")[1])
}

//-------------------- ricoColor.js
Rico.Color = Class.create();

Rico.Color.prototype = {

   initialize: function(red, green, blue) {
      this.rgb = { r: red, g : green, b : blue };
   },

   blend: function(other) {
      this.rgb.r = Math.floor((this.rgb.r + other.rgb.r)/2);
      this.rgb.g = Math.floor((this.rgb.g + other.rgb.g)/2);
      this.rgb.b = Math.floor((this.rgb.b + other.rgb.b)/2);
   },

   asRGB: function() {
      return "rgb(" + this.rgb.r + "," + this.rgb.g + "," + this.rgb.b + ")";
   },

   asHex: function() {
      return "#" + this.rgb.r.toColorPart() + this.rgb.g.toColorPart() + this.rgb.b.toColorPart();
   },

   asHSB: function() {
      return Rico.Color.RGBtoHSB(this.rgb.r, this.rgb.g, this.rgb.b);
   },

   toString: function() {
      return this.asHex();
   }

};

Rico.Color.createFromHex = function(hexCode) {
  if(hexCode.length==4) {
    var shortHexCode = hexCode;
    var hexCode = '#';
    for(var i=1;i<4;i++) hexCode += (shortHexCode.charAt(i) + shortHexCode.charAt(i));
  }
   if ( hexCode.indexOf('#') == 0 )
   hexCode = hexCode.substring(1);
   var red   = hexCode.substring(0,2);
   var green = hexCode.substring(2,4);
   var blue  = hexCode.substring(4,6);
   return new Rico.Color( parseInt(red,16), parseInt(green,16), parseInt(blue,16) );
}

/**
 * Factory method for creating a color from the background of
 * an HTML element.
 */
Rico.Color.createColorFromBackground = function(elem) {

   //var actualColor = RicoUtil.getElementsComputedStyle($(elem), "backgroundColor", "background-color"); // Changed to prototype style
	var actualColor = $(elem).getStyle('backgroundColor');

   if ( actualColor == "transparent" && elem.parentNode )
      return Rico.Color.createColorFromBackground(elem.parentNode);

   if ( actualColor == null )
      return new Rico.Color(255,255,255);

   if ( actualColor.indexOf("rgb(") == 0 ) {
      var colors = actualColor.substring(4, actualColor.length - 1 );
      var colorArray = colors.split(",");
      return new Rico.Color( parseInt( colorArray[0] ),
                            parseInt( colorArray[1] ),
                            parseInt( colorArray[2] )  );

   }
   else if ( actualColor.indexOf("#") == 0 ) {
      return Rico.Color.createFromHex(actualColor);
   }
   else
      return new Rico.Color(255,255,255);
}

/* next two functions changed to mootools color.js functions */
Rico.Color.HSBtoRGB = function(hue, saturation, brightness) {
			
			var br = Math.round(brightness / 100 * 255);
			if (this[1] == 0){
				return [br, br, br];
			} else {
				var hue = this[0] % 360;
				var f = hue % 60;
				var p = Math.round((brightness * (100 - saturation)) / 10000 * 255);
				var q = Math.round((brightness * (6000 - saturation * f)) / 600000 * 255);
				var t = Math.round((brightness * (6000 - saturation * (60 - f))) / 600000 * 255);
				switch(Math.floor(hue / 60)){
					case 0: return { r : br, g : t, b : p };
					case 1: return { r : q, g : br, b : p };
					case 2: return { r : p, g : br, b : t };
					case 3: return { r : p, g : q, b : br };
					case 4: return { r : t, g : p, b : br };
					case 5: return { r : br, g : p, b : q };
				}
			}
			return false;
		}

Rico.Color.RGBtoHSB = function(red, green, blue) {
		var hue, saturation, brightness;
		var max = Math.max(red, green, blue), min = Math.min(red, green, blue);
		var delta = max - min;
		brightness = max / 255;
		saturation = (max != 0) ? delta / max : 0;
		if (saturation == 0){
			hue = 0;
		} else {
			var rr = (max - red) / delta;
			var gr = (max - green) / delta;
			var br = (max - blue) / delta;
			if (red == max) hue = br - gr;
			else if (green == max) hue = 2 + rr - br;
			else hue = 4 + gr - rr;
			hue /= 6;
			if (hue < 0) hue++;
		}
		return { h : Math.round(hue * 360), s : Math.round(saturation * 100), b : Math.round(brightness * 100)};
}


//-------------------- ricoCorner.js
Rico.Corner = {

   round: function(e, options) {
      var e = $(e);
      this._setOptions(options);

      var color = this.options.color;
      if ( this.options.color == "fromElement" )
         color = this._background(e);

      var bgColor = this.options.bgColor;
      if ( this.options.bgColor == "fromParent" )
         bgColor = this._background(e.offsetParent);

      this._roundCornersImpl(e, color, bgColor);
   },

   _roundCornersImpl: function(e, color, bgColor) {
      if(this.options.border)
         this._renderBorder(e,bgColor);
      if(this._isTopRounded())
         this._roundTopCorners(e,color,bgColor);
      if(this._isBottomRounded())
         this._roundBottomCorners(e,color,bgColor);
   },

   _renderBorder: function(el,bgColor) {
      var borderValue = "1px solid " + this._borderColor(bgColor);
      var borderL = "border-left: "  + borderValue;
      var borderR = "border-right: " + borderValue;
      var style   = "style='" + borderL + ";" + borderR +  "'";
      el.innerHTML = "<div " + style + ">" + el.innerHTML + "</div>"
   },

   _roundTopCorners: function(el, color, bgColor) {
      var corner = this._createCorner(bgColor);
      for(var i=0 ; i < this.options.numSlices ; i++ )
         corner.appendChild(this._createCornerSlice(color,bgColor,i,"top"));
      el.style.paddingTop = 0;
      el.insertBefore(corner,el.firstChild);
   },

   _roundBottomCorners: function(el, color, bgColor) {
      var corner = this._createCorner(bgColor);
      for(var i=(this.options.numSlices-1) ; i >= 0 ; i-- )
         corner.appendChild(this._createCornerSlice(color,bgColor,i,"bottom"));
      el.style.paddingBottom = 0;
      el.appendChild(corner);
   },

   _createCorner: function(bgColor) {
      var corner = document.createElement("div");
      corner.style.backgroundColor = (this._isTransparent() ? "transparent" : bgColor);
      return corner;
   },

   _createCornerSlice: function(color,bgColor, n, position) {
      var slice = document.createElement("span");

      var inStyle = slice.style;
      inStyle.backgroundColor = color;
      inStyle.display  = "block";
      inStyle.height   = "1px";
      inStyle.overflow = "hidden";
      inStyle.fontSize = "1px";

      var borderColor = this._borderColor(color,bgColor);
      if ( this.options.border && n == 0 ) {
         inStyle.borderTopStyle    = "solid";
         inStyle.borderTopWidth    = "1px";
         inStyle.borderLeftWidth   = "0px";
         inStyle.borderRightWidth  = "0px";
         inStyle.borderBottomWidth = "0px";
         inStyle.height            = "0px"; // assumes css compliant box model
         inStyle.borderColor       = borderColor;
      }
      else if(borderColor) {
         inStyle.borderColor = borderColor;
         inStyle.borderStyle = "solid";
         inStyle.borderWidth = "0px 1px";
      }

      if ( !this.options.compact && (n == (this.options.numSlices-1)) )
         inStyle.height = "2px";

      this._setMargin(slice, n, position);
      this._setBorder(slice, n, position);
      return slice;
   },

   _setOptions: function(options) {
      this.options = {
         corners : "all",
         color   : "fromElement",
         bgColor : "fromParent",
         blend   : true,
         border  : false,
         compact : false
      }
      Object.extend(this.options, options || {});

      this.options.numSlices = this.options.compact ? 2 : 4;
      if ( this._isTransparent() )
         this.options.blend = false;
   },

   _whichSideTop: function() {
      if ( this._hasString(this.options.corners, "all", "top") )
         return "";

      if ( this.options.corners.indexOf("tl") >= 0 && this.options.corners.indexOf("tr") >= 0 )
         return "";

      if (this.options.corners.indexOf("tl") >= 0)
         return "left";
      else if (this.options.corners.indexOf("tr") >= 0)
          return "right";
      return "";
   },

   _whichSideBottom: function() {
      if ( this._hasString(this.options.corners, "all", "bottom") )
         return "";

      if ( this.options.corners.indexOf("bl")>=0 && this.options.corners.indexOf("br")>=0 )
         return "";

      if(this.options.corners.indexOf("bl") >=0)
         return "left";
      else if(this.options.corners.indexOf("br")>=0)
         return "right";
      return "";
   },

   _borderColor : function(color,bgColor) {
      if ( color == "transparent" )
         return bgColor;
      else if ( this.options.border )
         return this.options.border;
      else if ( this.options.blend )
         return this._blend( bgColor, color );
      else
         return "";
   },


   _setMargin: function(el, n, corners) {
      var marginSize = this._marginSize(n);
      var whichSide = corners == "top" ? this._whichSideTop() : this._whichSideBottom();

      if ( whichSide == "left" ) {
         el.style.marginLeft = marginSize + "px"; el.style.marginRight = "0px";
      }
      else if ( whichSide == "right" ) {
         el.style.marginRight = marginSize + "px"; el.style.marginLeft  = "0px";
      }
      else {
         el.style.marginLeft = marginSize + "px"; el.style.marginRight = marginSize + "px";
      }
   },

   _setBorder: function(el,n,corners) {
      var borderSize = this._borderSize(n);
      var whichSide = corners == "top" ? this._whichSideTop() : this._whichSideBottom();
      if ( whichSide == "left" ) {
         el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = "0px";
      }
      else if ( whichSide == "right" ) {
         el.style.borderRightWidth = borderSize + "px"; el.style.borderLeftWidth  = "0px";
      }
      else {
         el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = borderSize + "px";
      }
      if (this.options.border != false)
        el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = borderSize + "px";
   },

   _marginSize: function(n) {
      if ( this._isTransparent() )
         return 0;

      var marginSizes          = [ 5, 3, 2, 1 ];
      var blendedMarginSizes   = [ 3, 2, 1, 0 ];
      var compactMarginSizes   = [ 2, 1 ];
      var smBlendedMarginSizes = [ 1, 0 ];

      if ( this.options.compact && this.options.blend )
         return smBlendedMarginSizes[n];
      else if ( this.options.compact )
         return compactMarginSizes[n];
      else if ( this.options.blend )
         return blendedMarginSizes[n];
      else
         return marginSizes[n];
   },

   _borderSize: function(n) {
      var transparentBorderSizes = [ 5, 3, 2, 1 ];
      var blendedBorderSizes     = [ 2, 1, 1, 1 ];
      var compactBorderSizes     = [ 1, 0 ];
      var actualBorderSizes      = [ 0, 2, 0, 0 ];

      if ( this.options.compact && (this.options.blend || this._isTransparent()) )
         return 1;
      else if ( this.options.compact )
         return compactBorderSizes[n];
      else if ( this.options.blend )
         return blendedBorderSizes[n];
      else if ( this.options.border )
         return actualBorderSizes[n];
      else if ( this._isTransparent() )
         return transparentBorderSizes[n];
      return 0;
   },

   _hasString: function(str) { for(var i=1 ; i<arguments.length ; i++) if (str.indexOf(arguments[i]) >= 0) return true; return false; },
   _blend: function(c1, c2) { var cc1 = Rico.Color.createFromHex(c1); cc1.blend(Rico.Color.createFromHex(c2)); return cc1; },
   _background: function(el) { try { return Rico.Color.createColorFromBackground(el).asHex(); } catch(err) { return "#ffffff"; } },
   _isTransparent: function() { return this.options.color == "transparent"; },
   _isTopRounded: function() { return this._hasString(this.options.corners, "all", "top", "tl", "tr"); },
   _isBottomRounded: function() { return this._hasString(this.options.corners, "all", "bottom", "bl", "br"); },
   _hasSingleTextChild: function(el) { return el.childNodes.length == 1 && el.childNodes[0].nodeType == 3; }
}


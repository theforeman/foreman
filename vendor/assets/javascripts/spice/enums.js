"use strict";
/*
   Copyright (C) 2012 by Jeremy P. White <jwhite@codeweavers.com>

   This file is part of spice-html5.

   spice-html5 is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   spice-html5 is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with spice-html5.  If not, see <http://www.gnu.org/licenses/>.
*/


/*----------------------------------------------------------------------------
**  enums.js
**      'constants' for Spice
**--------------------------------------------------------------------------*/
var SPICE_MAGIC         = "REDQ";
var SPICE_VERSION_MAJOR = 2;
var SPICE_VERSION_MINOR = 2;

var SPICE_CONNECT_TIMEOUT = (30 * 1000);

var SPICE_COMMON_CAP_PROTOCOL_AUTH_SELECTION = 0;
var SPICE_COMMON_CAP_AUTH_SPICE              = 1;
var SPICE_COMMON_CAP_AUTH_SASL               = 2;
var SPICE_COMMON_CAP_MINI_HEADER             = 3;

var SPICE_TICKET_KEY_PAIR_LENGTH             = 1024;
var SPICE_TICKET_PUBKEY_BYTES                = (SPICE_TICKET_KEY_PAIR_LENGTH / 8 + 34);

var SPICE_LINK_ERR_OK                        = 0,
    SPICE_LINK_ERR_ERROR                     = 1,
    SPICE_LINK_ERR_INVALID_MAGIC             = 2,
    SPICE_LINK_ERR_INVALID_DATA              = 3,
    SPICE_LINK_ERR_VERSION_MISMATCH          = 4,
    SPICE_LINK_ERR_NEED_SECURED              = 5,
    SPICE_LINK_ERR_NEED_UNSECURED            = 6,
    SPICE_LINK_ERR_PERMISSION_DENIED         = 7,
    SPICE_LINK_ERR_BAD_CONNECTION_ID         = 8,
    SPICE_LINK_ERR_CHANNEL_NOT_AVAILABLE     = 9;

var SPICE_MSG_MIGRATE                   = 1;
var SPICE_MSG_MIGRATE_DATA              = 2;
var SPICE_MSG_SET_ACK                   = 3;
var SPICE_MSG_PING                      = 4;
var SPICE_MSG_WAIT_FOR_CHANNELS         = 5;
var SPICE_MSG_DISCONNECTING             = 6;
var SPICE_MSG_NOTIFY                    = 7;
var SPICE_MSG_LIST                      = 8;

var SPICE_MSG_MAIN_MIGRATE_BEGIN        = 101;
var SPICE_MSG_MAIN_MIGRATE_CANCEL       = 102;
var SPICE_MSG_MAIN_INIT                 = 103;
var SPICE_MSG_MAIN_CHANNELS_LIST        = 104;
var SPICE_MSG_MAIN_MOUSE_MODE           = 105;
var SPICE_MSG_MAIN_MULTI_MEDIA_TIME     = 106;
var SPICE_MSG_MAIN_AGENT_CONNECTED      = 107;
var SPICE_MSG_MAIN_AGENT_DISCONNECTED   = 108;
var SPICE_MSG_MAIN_AGENT_DATA           = 109;
var SPICE_MSG_MAIN_AGENT_TOKEN          = 110;
var SPICE_MSG_MAIN_MIGRATE_SWITCH_HOST  = 111;
var SPICE_MSG_MAIN_MIGRATE_END          = 112;
var SPICE_MSG_MAIN_NAME                 = 113;
var SPICE_MSG_MAIN_UUID                 = 114;
var SPICE_MSG_END_MAIN                  = 115;


var SPICE_MSGC_ACK_SYNC                 = 1;
var SPICE_MSGC_ACK                      = 2;
var SPICE_MSGC_PONG                     = 3;
var SPICE_MSGC_MIGRATE_FLUSH_MARK       = 4;
var SPICE_MSGC_MIGRATE_DATA             = 5;
var SPICE_MSGC_DISCONNECTING            = 6;


var SPICE_MSGC_MAIN_CLIENT_INFO         = 101;
var SPICE_MSGC_MAIN_MIGRATE_CONNECTED   = 102;
var SPICE_MSGC_MAIN_MIGRATE_CONNECT_ERROR = 103;
var SPICE_MSGC_MAIN_ATTACH_CHANNELS     = 104;
var SPICE_MSGC_MAIN_MOUSE_MODE_REQUEST  = 105;
var SPICE_MSGC_MAIN_AGENT_START         = 106;
var SPICE_MSGC_MAIN_AGENT_DATA          = 107;
var SPICE_MSGC_MAIN_AGENT_TOKEN         = 108;
var SPICE_MSGC_MAIN_MIGRATE_END         = 109;
var SPICE_MSGC_END_MAIN                 = 110;

var SPICE_MSG_DISPLAY_MODE              = 101;
var SPICE_MSG_DISPLAY_MARK              = 102;
var SPICE_MSG_DISPLAY_RESET             = 103;
var SPICE_MSG_DISPLAY_COPY_BITS         = 104;
var SPICE_MSG_DISPLAY_INVAL_LIST        = 105;
var SPICE_MSG_DISPLAY_INVAL_ALL_PIXMAPS = 106;
var SPICE_MSG_DISPLAY_INVAL_PALETTE     = 107;
var SPICE_MSG_DISPLAY_INVAL_ALL_PALETTES= 108;

var SPICE_MSG_DISPLAY_STREAM_CREATE     = 122;
var SPICE_MSG_DISPLAY_STREAM_DATA       = 123;
var SPICE_MSG_DISPLAY_STREAM_CLIP       = 124;
var SPICE_MSG_DISPLAY_STREAM_DESTROY    = 125;
var SPICE_MSG_DISPLAY_STREAM_DESTROY_ALL= 126;

var SPICE_MSG_DISPLAY_DRAW_FILL         = 302;
var SPICE_MSG_DISPLAY_DRAW_OPAQUE       = 303;
var SPICE_MSG_DISPLAY_DRAW_COPY         = 304;
var SPICE_MSG_DISPLAY_DRAW_BLEND        = 305;
var SPICE_MSG_DISPLAY_DRAW_BLACKNESS    = 306;
var SPICE_MSG_DISPLAY_DRAW_WHITENESS    = 307;
var SPICE_MSG_DISPLAY_DRAW_INVERS       = 308;
var SPICE_MSG_DISPLAY_DRAW_ROP3         = 309;
var SPICE_MSG_DISPLAY_DRAW_STROKE       = 310;
var SPICE_MSG_DISPLAY_DRAW_TEXT         = 311;
var SPICE_MSG_DISPLAY_DRAW_TRANSPARENT  = 312;
var SPICE_MSG_DISPLAY_DRAW_ALPHA_BLEND  = 313;
var SPICE_MSG_DISPLAY_SURFACE_CREATE    = 314;
var SPICE_MSG_DISPLAY_SURFACE_DESTROY   = 315;

var SPICE_MSGC_DISPLAY_INIT             = 101;

var SPICE_MSG_INPUTS_INIT               = 101;
var SPICE_MSG_INPUTS_KEY_MODIFIERS      = 102;

var SPICE_MSG_INPUTS_MOUSE_MOTION_ACK   = 111;

var SPICE_MSGC_INPUTS_KEY_DOWN          = 101;
var SPICE_MSGC_INPUTS_KEY_UP            = 102;
var SPICE_MSGC_INPUTS_KEY_MODIFIERS     = 103;

var SPICE_MSGC_INPUTS_MOUSE_MOTION      = 111;
var SPICE_MSGC_INPUTS_MOUSE_POSITION    = 112;
var SPICE_MSGC_INPUTS_MOUSE_PRESS       = 113;
var SPICE_MSGC_INPUTS_MOUSE_RELEASE     = 114;

var SPICE_MSG_CURSOR_INIT               = 101;
var SPICE_MSG_CURSOR_RESET              = 102;
var SPICE_MSG_CURSOR_SET                = 103;
var SPICE_MSG_CURSOR_MOVE               = 104;
var SPICE_MSG_CURSOR_HIDE               = 105;
var SPICE_MSG_CURSOR_TRAIL              = 106;
var SPICE_MSG_CURSOR_INVAL_ONE          = 107;
var SPICE_MSG_CURSOR_INVAL_ALL          = 108;


var SPICE_CHANNEL_MAIN                  = 1;
var SPICE_CHANNEL_DISPLAY               = 2;
var SPICE_CHANNEL_INPUTS                = 3;
var SPICE_CHANNEL_CURSOR                = 4;
var SPICE_CHANNEL_PLAYBACK              = 5;
var SPICE_CHANNEL_RECORD                = 6;
var SPICE_CHANNEL_TUNNEL                = 7;
var SPICE_CHANNEL_SMARTCARD             = 8;
var SPICE_CHANNEL_USBREDIR              = 9;

var SPICE_SURFACE_FLAGS_PRIMARY = (1 << 0);

var SPICE_NOTIFY_SEVERITY_INFO  = 0;
var SPICE_NOTIFY_SEVERITY_WARN  = 1;
var SPICE_NOTIFY_SEVERITY_ERROR = 2;

var SPICE_MOUSE_MODE_SERVER = (1 << 0),
    SPICE_MOUSE_MODE_CLIENT = (1 << 1),
    SPICE_MOUSE_MODE_MASK = 0x3;

var SPICE_CLIP_TYPE_NONE            = 0;
var SPICE_CLIP_TYPE_RECTS           = 1;

var SPICE_IMAGE_TYPE_BITMAP         = 0;
var SPICE_IMAGE_TYPE_QUIC           = 1;
var SPICE_IMAGE_TYPE_RESERVED       = 2;
var SPICE_IMAGE_TYPE_LZ_PLT         = 100;
var SPICE_IMAGE_TYPE_LZ_RGB         = 101;
var SPICE_IMAGE_TYPE_GLZ_RGB        = 102;
var SPICE_IMAGE_TYPE_FROM_CACHE     = 103;
var SPICE_IMAGE_TYPE_SURFACE        = 104;
var SPICE_IMAGE_TYPE_JPEG           = 105;
var SPICE_IMAGE_TYPE_FROM_CACHE_LOSSLESS = 106;
var SPICE_IMAGE_TYPE_ZLIB_GLZ_RGB   = 107;
var SPICE_IMAGE_TYPE_JPEG_ALPHA     = 108;

var SPICE_IMAGE_FLAGS_CACHE_ME = (1 << 0),
    SPICE_IMAGE_FLAGS_HIGH_BITS_SET = (1 << 1),
    SPICE_IMAGE_FLAGS_CACHE_REPLACE_ME = (1 << 2);

var SPICE_BITMAP_FLAGS_PAL_CACHE_ME = (1 << 0),
    SPICE_BITMAP_FLAGS_PAL_FROM_CACHE = (1 << 1),
    SPICE_BITMAP_FLAGS_TOP_DOWN = (1 << 2),
    SPICE_BITMAP_FLAGS_MASK = 0x7;

var SPICE_BITMAP_FMT_INVALID        = 0,
    SPICE_BITMAP_FMT_1BIT_LE        = 1,
    SPICE_BITMAP_FMT_1BIT_BE        = 2,
    SPICE_BITMAP_FMT_4BIT_LE        = 3,
    SPICE_BITMAP_FMT_4BIT_BE        = 4,
    SPICE_BITMAP_FMT_8BIT           = 5,
    SPICE_BITMAP_FMT_16BIT          = 6,
    SPICE_BITMAP_FMT_24BIT          = 7,
    SPICE_BITMAP_FMT_32BIT          = 8,
    SPICE_BITMAP_FMT_RGBA           = 9;


var SPICE_CURSOR_FLAGS_NONE = (1 << 0),
    SPICE_CURSOR_FLAGS_CACHE_ME = (1 << 1),
    SPICE_CURSOR_FLAGS_FROM_CACHE = (1 << 2),
    SPICE_CURSOR_FLAGS_MASK = 0x7;

var SPICE_MOUSE_BUTTON_MASK_LEFT = (1 << 0),
    SPICE_MOUSE_BUTTON_MASK_MIDDLE = (1 << 1),
    SPICE_MOUSE_BUTTON_MASK_RIGHT = (1 << 2),
    SPICE_MOUSE_BUTTON_MASK_MASK = 0x7;
    
var SPICE_MOUSE_BUTTON_INVALID  = 0;
var SPICE_MOUSE_BUTTON_LEFT     = 1;
var SPICE_MOUSE_BUTTON_MIDDLE   = 2;
var SPICE_MOUSE_BUTTON_RIGHT    = 3;
var SPICE_MOUSE_BUTTON_UP       = 4;
var SPICE_MOUSE_BUTTON_DOWN     = 5;

var SPICE_BRUSH_TYPE_NONE = 0,
    SPICE_BRUSH_TYPE_SOLID = 1,
    SPICE_BRUSH_TYPE_PATTERN = 2;

var SPICE_SURFACE_FMT_INVALID = 0,
    SPICE_SURFACE_FMT_1_A = 1,
    SPICE_SURFACE_FMT_8_A = 8,
    SPICE_SURFACE_FMT_16_555 = 16,
    SPICE_SURFACE_FMT_32_xRGB = 32,
    SPICE_SURFACE_FMT_16_565 = 80,
    SPICE_SURFACE_FMT_32_ARGB = 96;

var SPICE_ROPD_INVERS_SRC = (1 << 0),
    SPICE_ROPD_INVERS_BRUSH = (1 << 1),
    SPICE_ROPD_INVERS_DEST = (1 << 2),
    SPICE_ROPD_OP_PUT = (1 << 3),
    SPICE_ROPD_OP_OR = (1 << 4),
    SPICE_ROPD_OP_AND = (1 << 5),
    SPICE_ROPD_OP_XOR = (1 << 6),
    SPICE_ROPD_OP_BLACKNESS = (1 << 7),
    SPICE_ROPD_OP_WHITENESS = (1 << 8),
    SPICE_ROPD_OP_INVERS = (1 << 9),
    SPICE_ROPD_INVERS_RES = (1 << 10),
    SPICE_ROPD_MASK = 0x7ff;

var LZ_IMAGE_TYPE_INVALID = 0,
    LZ_IMAGE_TYPE_PLT1_LE = 1,
    LZ_IMAGE_TYPE_PLT1_BE = 2,      // PLT stands for palette
    LZ_IMAGE_TYPE_PLT4_LE = 3,
    LZ_IMAGE_TYPE_PLT4_BE = 4,
    LZ_IMAGE_TYPE_PLT8    = 5,
    LZ_IMAGE_TYPE_RGB16   = 6,
    LZ_IMAGE_TYPE_RGB24   = 7,
    LZ_IMAGE_TYPE_RGB32   = 8,
    LZ_IMAGE_TYPE_RGBA    = 9,
    LZ_IMAGE_TYPE_XXXA    = 10;


var QUIC_IMAGE_TYPE_INVALID = 0,
    QUIC_IMAGE_TYPE_GRAY    = 1,
    QUIC_IMAGE_TYPE_RGB16   = 2,
    QUIC_IMAGE_TYPE_RGB24   = 3,
    QUIC_IMAGE_TYPE_RGB32   = 4,
    QUIC_IMAGE_TYPE_RGBA    = 5;

var SPICE_INPUT_MOTION_ACK_BUNCH = 4;


var SPICE_CURSOR_TYPE_ALPHA     = 0,
    SPICE_CURSOR_TYPE_MONO      = 1,
    SPICE_CURSOR_TYPE_COLOR4    = 2,
    SPICE_CURSOR_TYPE_COLOR8    = 3,
    SPICE_CURSOR_TYPE_COLOR16   = 4,
    SPICE_CURSOR_TYPE_COLOR24   = 5,
    SPICE_CURSOR_TYPE_COLOR32   = 6;

var SPICE_VIDEO_CODEC_TYPE_MJPEG = 1;

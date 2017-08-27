--[[
	zlib-deflate.lua
	Version: 0.2.0
	LastModified: September 13 2015
	Copyright (C) 2014 David McWilliams

	This library is a Lua implementation of zlib deflate.

	Based on zlib-js (Javascript implementation)
	http://www.onicos.com/staff/iz/release/zlib-js/zlib-js.html
	Copyright (C) 2012 Masanao Izumo

	Based on zlib (Original implementation)
	http://www.zlib.net/
	Copyright (C) 1995-2013 Jean-loup Gailly and Mark Adler

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.
]]--

function requireany(...)
	-- (c) 2011-2012 David Manura. Licensed under Lua 5.1 terms (MIT license).
	local errs = {}
	for i = 1, select('#', ...) do local name = select(i, ...)
		if type(name) ~= 'string' then return name, nil end
		local ok, mod = pcall(require, name)
		if ok then return mod, name end
		errs[#errs+1] = mod
	end
	error(table.concat(errs, '\n'), 2)
end

local crc32 = require 'crc32lua' . crc32_byte
local bit, name_ = requireany('bit', 'bit32', 'bit.numberlua')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift = bit.lshift, bit.rshift

-- common definitions
local ZLIB = {}

-- Allowed flush values; see deflate() and inflate() below for details
ZLIB.Z_NO_FLUSH      = 0
ZLIB.Z_PARTIAL_FLUSH = 1
ZLIB.Z_SYNC_FLUSH    = 2
ZLIB.Z_FULL_FLUSH    = 3
ZLIB.Z_FINISH        = 4
ZLIB.Z_BLOCK         = 5
ZLIB.Z_TREES         = 6

-- Return codes for the compression/decompression functions. Negative values are errors, positive values are used for special but normal events.
ZLIB.Z_OK            =   0
ZLIB.Z_STREAM_END    =   1
ZLIB.Z_NEED_DICT     =   2
ZLIB.Z_ERRNO         = (-1)
ZLIB.Z_STREAM_ERROR  = (-2)
ZLIB.Z_DATA_ERROR    = (-3)
ZLIB.Z_MEM_ERROR     = (-4)
ZLIB.Z_BUF_ERROR     = (-5)
ZLIB.Z_VERSION_ERROR = (-6)

-- compression levels 
ZLIB.Z_NO_COMPRESSION      = 0
ZLIB.Z_BEST_SPEED          = 1
ZLIB.Z_BEST_COMPRESSION    = 9
ZLIB.Z_DEFAULT_COMPRESSION = (-1)

-- compression strategy; see deflateInit2() below for details 
ZLIB.Z_FILTERED         = 1
ZLIB.Z_HUFFMAN_ONLY     = 2
ZLIB.Z_RLE              = 3
ZLIB.Z_FIXED            = 4
ZLIB.Z_DEFAULT_STRATEGY = 0

-- Possible values of the data_type field (though see inflate())
ZLIB.Z_BINARY  = 0
ZLIB.Z_TEXT    = 1
ZLIB.Z_ASCII   = ZLIB.Z_TEXT  -- for compatibility with 1.2.2 and earlier
ZLIB.Z_UNKNOWN = 2

-- The deflate compression method (the only one supported in this version)
ZLIB.Z_DEFLATED = 8

-- Maximum value for memLevel in deflateInit2
ZLIB.MAX_MEM_LEVEL = 9

-- z_stream constructor
ZLIB.z_stream = function()
	local s = {}
	s.next_in = 0       -- next input byte
	s.avail_in = 0      -- number of bytes available in input_data
	s.total_in = 0      -- total number of input bytes read so far

	s.next_out = 0      -- next output byte
	s.avail_out = 0     -- remaining free space at next_out
	s.total_out = 0     -- total number of bytes output so far

	s.msg = nil         -- last error message, nil if no error
	s.state = nil       -- not visible by applications

	s.data_type = 0     -- best guess about the data type: binary or text

	s.input_data = ''   -- input data
	s.output_data = ''  -- output data
	s.error = 0         -- error code
	s.checksum_function = nil  -- crc32(for gzip) or adler32(for zlib)
	return s
end

ZLIB.crc32 = function(crc, buf, offset, len)
	if (buf == nil) then return 0 end

	while (len > 0) do
		crc = crc32(buf[offset], crc)
		offset = offset + 1
		len = len - 1
	end
	return crc
end

-- Maximum value for windowBits in deflateInit2 and inflateInit2.
-- WARNING: reducing MAX_WBITS makes minigzip unable to extract .gz files created by gzip.
-- (Files created by minigzip can still be extracted by gzip.)
ZLIB.MAX_WBITS = 15

ZLIB.OS_CODE = 0xff  -- unknown

-- default memLevel
local DEF_MEM_LEVEL
if (ZLIB.MAX_MEM_LEVEL >= 8) then
	DEF_MEM_LEVEL = 8
else
	DEF_MEM_LEVEL = ZLIB.MAX_MEM_LEVEL
end

-- The three kinds of block type
local STORED_BLOCK = 0
local STATIC_TREES = 1
local DYN_TREES	= 2

-- The minimum and maximum match lengths
local MIN_MATCH = 3
local MAX_MATCH = 258

-- preset dictionary flag in zlib header
local PRESET_DICT = 0x20


-- ===========================================================================
-- Internal compression state.

-- number of length codes, not counting the special END_BLOCK code
local LENGTH_CODES = 29

-- number of literal bytes 0..255
local LITERALS = 256

-- number of Literal or Length codes, including the END_BLOCK code
local L_CODES = (LITERALS+1+LENGTH_CODES)

-- number of distance codes
local D_CODES = 30

-- number of codes used to transfer the bit lengths
local BL_CODES = 19

-- maximum heap size
local HEAP_SIZE = (2*L_CODES+1)

-- All codes must not exceed MAX_BITS bits
local MAX_BITS = 15

-- size of bit buffer in bi_buf
local Buf_size = 16

-- Stream status
local INIT_STATE    = 42
local EXTRA_STATE   = 69
local NAME_STATE    = 73
local COMMENT_STATE = 91
local HCRC_STATE    = 103
local BUSY_STATE    = 113
local FINISH_STATE  = 666

function new_array(size)
	local ary = {}
	for i = 0, size-1 do
		ary[i] = 0
	end
	return ary
end

function new_ct_array(count)
	local ary = {}
	for i = 0, count-1 do
		ary[i] = {fc=0, dl=0}
	end	
	return ary
end

function getarg(opts, name, def_value)
	if (opts and opts[name]) then
		return opts[name]
	end
	return def_value
end

function checksum_none()
	return 0
end

-- constructor
function tree_desc()
	local this = {}
	this.dyn_tree = nil       -- the dynamic tree
	this.max_code = 0         -- largest code with non zero frequency
	this.stat_desc = nil      -- the corresponding static tree
	return this
end

-- constructor
function deflate_state()
	local this = {}
	this.strm = nil           -- pointer back to this zlib stream (TODO remove: cross reference)
	this.status = 0           -- as the name implies
	this.pending_buf = ''     -- output still pending
	this.pending_buf_size = 0 -- size of pending_buf
	this.wrap = 0             -- bit 0 true for zlib, bit 1 true for gzip
	this.gzhead = nil         -- TODO: gzip header information to write
	this.gzindex = 0          -- TODO: where in extra, name, or comment
	this.method = 0           -- STORED (for zip only) or DEFLATED
	this.last_flush = 0       -- value of flush param for previous deflate call

	-- used by deflate.c:
	this.w_size = 0           -- LZ77 window size (32K by default)
	this.w_bits = 0           -- log2(w_size)  (8..16)
	this.w_mask = 0           -- w_size - 1

	-- Sliding window. Input bytes are read into the second half of the window, and move to the first half later to keep a dictionary of at least wSize bytes. With this organization, matches are limited to a distance of wSize-MAX_MATCH bytes, but this ensures that IO is always performed with a length multiple of the block size. Also, it limits the window size to 64K, which is quite useful on MSDOS. To do: use the user input buffer as sliding window.
	this.window = nil

	-- Actual size of window: 2*wSize, except when the user input buffer is directly used as sliding window.
	this.window_size = 0

	-- Link to older string with same hash index. To limit the size of this array to 64K, this link is maintained only for the last 32K strings. An index in this array is thus a window index modulo 32K.
	this.prev = nil

	this.head = nil     -- Heads of the hash chains or NIL.

	this.ins_h = 0      -- hash index of string to be inserted
	this.hash_size = 0  -- number of elements in hash table
	this.hash_bits = 0  -- log2(hash_size)
	this.hash_mask = 0  -- hash_size-1

	-- Number of bits by which ins_h must be shifted at each input step. It must be such that after MIN_MATCH steps, the oldest byte no longer takes part in the hash key, that is: hash_shift * MIN_MATCH >= hash_bits
	this.hash_shift = 0

	-- Window position at the beginning of the current output block. Gets negative when the window is moved backwards.
	this.block_start = 0

	this.match_length = 0         -- length of best match
	this.prev_match = 0           -- previous match
	this.match_available = false  -- set if previous match exists
	this.strstart = 0             -- start of string to insert
	this.match_start = 0          -- start of matching string
	this.lookahead = 0            -- number of valid bytes ahead in window

	-- Length of the best match at previous step. Matches not greater than this are discarded. This is used in the lazy match evaluation.
	this.prev_length = 0

	this.max_chain_length = 0
	-- To speed up deflation, hash chains are never searched beyond this length.  A higher limit improves compression ratio but degrades the speed.

	-- Attempt to find a better match only when the current match is strictly smaller than this value. This mechanism is used only for compression levels >= 4.
	this.max_lazy_match = 0

	this.level = 0     -- compression level (1..9)
	this.strategy = 0  -- favor or force Huffman coding

	-- Use a faster search when the previous match is longer than this
	this.good_match = 0

	this.nice_match = 0  -- Stop searching when current match exceeds this

	-- used by trees.c:
	-- Didn't use ct_data typedef below to suppress compiler warning
	this.dyn_ltree = new_ct_array(HEAP_SIZE)    -- literal and length tree
	this.dyn_dtree = new_ct_array(2*D_CODES+1)  -- distance tree
	this.bl_tree = new_ct_array(2*BL_CODES+1)   -- Huffman tree for bit lengths

	this.l_desc = tree_desc()   -- desc. for literal tree
	this.d_desc = tree_desc()   -- desc. for distance tree
	this.bl_desc = tree_desc()  -- desc. for bit length tree

	-- number of codes at each bit length for an optimal tree
	this.bl_count = new_array(MAX_BITS+1)

	-- The sons of heap[n] are heap[2*n] and heap[2*n+1]. heap[0] is not used.
	-- The same heap array is used to build all trees.
	this.heap = new_array(2*L_CODES+1)  -- heap used to build the Huffman trees
	this.heap_len = 0    -- number of elements in the heap
	this.heap_max = 0    -- element of largest frequency

	-- Depth of each subtree used as tie breaker for trees of equal frequency
	this.depth = new_array(2*L_CODES+1)

	this.l_buf = nil     -- buffer for literals or lengths

	-- Size of match buffer for literals/lengths
	this.lit_bufsize = 0
	
	this.last_lit = 0    -- running index in l_buf

	-- Buffer for distances. To simplify the code, d_buf and l_buf have the same number of elements. To use different lengths, an extra flag array would be necessary.
	this.d_buf = nil

	this.opt_len = 0     -- bit length of current block with optimal trees
	this.static_len = 0  -- bit length of current block with static trees
	this.matches = 0     -- number of string matches in current block
	this.insert = 0      -- bytes at end of window left to insert

	--this.compressed_len = 0  -- total bit length of compressed file mod 2^32
	this.bits_sent = 0   -- bit length of compressed data sent mod 2^32

	-- Output buffer. bits are inserted starting at the bottom (least significant bits).
	this.bi_buf = 0

	-- Number of valid bits in bi_buf.  All bits above the last valid bit are always zero.
	this.bi_valid = 0

	-- High water mark offset in window for initialized bytes -- bytes above this are set to zero in order to avoid memory check warnings when longest match routines access bytes past the input.  This is then updated to the new high water mark.
	this.high_water = 0

	return this
end

-- Minimum amount of lookahead, except at the end of the input file. See deflate.c for comments about the MIN_MATCH+1.
local MIN_LOOKAHEAD = (MAX_MATCH+MIN_MATCH+1)

-- In order to simplify the code, particularly on 16 bit machines, match distances are limited to MAX_DIST instead of WSIZE.
function MAX_DIST(s)
	return s.w_size - MIN_LOOKAHEAD
end

-- Number of bytes after end of data in window to initialize in order to avoid memory checker errors from longest match routines
local WIN_INIT = MAX_MATCH


-- ===========================================================================
-- trees.c -- output deflated data using Huffman coding

-- Constants

-- Bit length codes must not exceed MAX_BL_BITS bits
local MAX_BL_BITS = 7

-- end of block literal code
local END_BLOCK = 256

-- repeat previous bit length 3-6 times (2 bits of repeat count)
local REP_3_6 = 16

-- repeat a zero length 3-10 times  (3 bits of repeat count)
local REPZ_3_10	= 17

-- repeat a zero length 11-138 times  (7 bits of repeat count)
local REPZ_11_138 = 18

-- extra bits for each length code
local extra_lbits = {0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0}
extra_lbits[0] = 0

-- extra bits for each distance code
local extra_dbits = {0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}
extra_dbits[0] = 0

-- extra bits for each bit length code
local extra_blbits = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,7}
extra_blbits[0] = 0

-- The lengths of the bit length codes are sent in order of decreasing probability, to avoid transmitting the lengths for unused bit length codes.
local bl_order = {17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}
bl_order[0] = 16

-- see definition of array dist_code below
local DIST_CODE_LEN = 512 

local static_ltree = {
                {fc=140, dl=8}, {fc= 76, dl=8}, {fc=204, dl=8}, {fc= 44, dl=8},
{fc=172, dl=8}, {fc=108, dl=8}, {fc=236, dl=8}, {fc= 28, dl=8}, {fc=156, dl=8},
{fc= 92, dl=8}, {fc=220, dl=8}, {fc= 60, dl=8}, {fc=188, dl=8}, {fc=124, dl=8},
{fc=252, dl=8}, {fc=  2, dl=8}, {fc=130, dl=8}, {fc= 66, dl=8}, {fc=194, dl=8},
{fc= 34, dl=8}, {fc=162, dl=8}, {fc= 98, dl=8}, {fc=226, dl=8}, {fc= 18, dl=8},
{fc=146, dl=8}, {fc= 82, dl=8}, {fc=210, dl=8}, {fc= 50, dl=8}, {fc=178, dl=8},
{fc=114, dl=8}, {fc=242, dl=8}, {fc= 10, dl=8}, {fc=138, dl=8}, {fc= 74, dl=8},
{fc=202, dl=8}, {fc= 42, dl=8}, {fc=170, dl=8}, {fc=106, dl=8}, {fc=234, dl=8},
{fc= 26, dl=8}, {fc=154, dl=8}, {fc= 90, dl=8}, {fc=218, dl=8}, {fc= 58, dl=8},
{fc=186, dl=8}, {fc=122, dl=8}, {fc=250, dl=8}, {fc=  6, dl=8}, {fc=134, dl=8},
{fc= 70, dl=8}, {fc=198, dl=8}, {fc= 38, dl=8}, {fc=166, dl=8}, {fc=102, dl=8},
{fc=230, dl=8}, {fc= 22, dl=8}, {fc=150, dl=8}, {fc= 86, dl=8}, {fc=214, dl=8},
{fc= 54, dl=8}, {fc=182, dl=8}, {fc=118, dl=8}, {fc=246, dl=8}, {fc= 14, dl=8},
{fc=142, dl=8}, {fc= 78, dl=8}, {fc=206, dl=8}, {fc= 46, dl=8}, {fc=174, dl=8},
{fc=110, dl=8}, {fc=238, dl=8}, {fc= 30, dl=8}, {fc=158, dl=8}, {fc= 94, dl=8},
{fc=222, dl=8}, {fc= 62, dl=8}, {fc=190, dl=8}, {fc=126, dl=8}, {fc=254, dl=8},
{fc=  1, dl=8}, {fc=129, dl=8}, {fc= 65, dl=8}, {fc=193, dl=8}, {fc= 33, dl=8},
{fc=161, dl=8}, {fc= 97, dl=8}, {fc=225, dl=8}, {fc= 17, dl=8}, {fc=145, dl=8},
{fc= 81, dl=8}, {fc=209, dl=8}, {fc= 49, dl=8}, {fc=177, dl=8}, {fc=113, dl=8},
{fc=241, dl=8}, {fc=  9, dl=8}, {fc=137, dl=8}, {fc= 73, dl=8}, {fc=201, dl=8},
{fc= 41, dl=8}, {fc=169, dl=8}, {fc=105, dl=8}, {fc=233, dl=8}, {fc= 25, dl=8},
{fc=153, dl=8}, {fc= 89, dl=8}, {fc=217, dl=8}, {fc= 57, dl=8}, {fc=185, dl=8},
{fc=121, dl=8}, {fc=249, dl=8}, {fc=  5, dl=8}, {fc=133, dl=8}, {fc= 69, dl=8},
{fc=197, dl=8}, {fc= 37, dl=8}, {fc=165, dl=8}, {fc=101, dl=8}, {fc=229, dl=8},
{fc= 21, dl=8}, {fc=149, dl=8}, {fc= 85, dl=8}, {fc=213, dl=8}, {fc= 53, dl=8},
{fc=181, dl=8}, {fc=117, dl=8}, {fc=245, dl=8}, {fc= 13, dl=8}, {fc=141, dl=8},
{fc= 77, dl=8}, {fc=205, dl=8}, {fc= 45, dl=8}, {fc=173, dl=8}, {fc=109, dl=8},
{fc=237, dl=8}, {fc= 29, dl=8}, {fc=157, dl=8}, {fc= 93, dl=8}, {fc=221, dl=8},
{fc= 61, dl=8}, {fc=189, dl=8}, {fc=125, dl=8}, {fc=253, dl=8}, {fc= 19, dl=9},
{fc=275, dl=9}, {fc=147, dl=9}, {fc=403, dl=9}, {fc= 83, dl=9}, {fc=339, dl=9},
{fc=211, dl=9}, {fc=467, dl=9}, {fc= 51, dl=9}, {fc=307, dl=9}, {fc=179, dl=9},
{fc=435, dl=9}, {fc=115, dl=9}, {fc=371, dl=9}, {fc=243, dl=9}, {fc=499, dl=9},
{fc= 11, dl=9}, {fc=267, dl=9}, {fc=139, dl=9}, {fc=395, dl=9}, {fc= 75, dl=9},
{fc=331, dl=9}, {fc=203, dl=9}, {fc=459, dl=9}, {fc= 43, dl=9}, {fc=299, dl=9},
{fc=171, dl=9}, {fc=427, dl=9}, {fc=107, dl=9}, {fc=363, dl=9}, {fc=235, dl=9},
{fc=491, dl=9}, {fc= 27, dl=9}, {fc=283, dl=9}, {fc=155, dl=9}, {fc=411, dl=9},
{fc= 91, dl=9}, {fc=347, dl=9}, {fc=219, dl=9}, {fc=475, dl=9}, {fc= 59, dl=9},
{fc=315, dl=9}, {fc=187, dl=9}, {fc=443, dl=9}, {fc=123, dl=9}, {fc=379, dl=9},
{fc=251, dl=9}, {fc=507, dl=9}, {fc=  7, dl=9}, {fc=263, dl=9}, {fc=135, dl=9},
{fc=391, dl=9}, {fc= 71, dl=9}, {fc=327, dl=9}, {fc=199, dl=9}, {fc=455, dl=9},
{fc= 39, dl=9}, {fc=295, dl=9}, {fc=167, dl=9}, {fc=423, dl=9}, {fc=103, dl=9},
{fc=359, dl=9}, {fc=231, dl=9}, {fc=487, dl=9}, {fc= 23, dl=9}, {fc=279, dl=9},
{fc=151, dl=9}, {fc=407, dl=9}, {fc= 87, dl=9}, {fc=343, dl=9}, {fc=215, dl=9},
{fc=471, dl=9}, {fc= 55, dl=9}, {fc=311, dl=9}, {fc=183, dl=9}, {fc=439, dl=9},
{fc=119, dl=9}, {fc=375, dl=9}, {fc=247, dl=9}, {fc=503, dl=9}, {fc= 15, dl=9},
{fc=271, dl=9}, {fc=143, dl=9}, {fc=399, dl=9}, {fc= 79, dl=9}, {fc=335, dl=9},
{fc=207, dl=9}, {fc=463, dl=9}, {fc= 47, dl=9}, {fc=303, dl=9}, {fc=175, dl=9},
{fc=431, dl=9}, {fc=111, dl=9}, {fc=367, dl=9}, {fc=239, dl=9}, {fc=495, dl=9},
{fc= 31, dl=9}, {fc=287, dl=9}, {fc=159, dl=9}, {fc=415, dl=9}, {fc= 95, dl=9},
{fc=351, dl=9}, {fc=223, dl=9}, {fc=479, dl=9}, {fc= 63, dl=9}, {fc=319, dl=9},
{fc=191, dl=9}, {fc=447, dl=9}, {fc=127, dl=9}, {fc=383, dl=9}, {fc=255, dl=9},
{fc=511, dl=9}, {fc=  0, dl=7}, {fc= 64, dl=7}, {fc= 32, dl=7}, {fc= 96, dl=7},
{fc= 16, dl=7}, {fc= 80, dl=7}, {fc= 48, dl=7}, {fc=112, dl=7}, {fc=  8, dl=7},
{fc= 72, dl=7}, {fc= 40, dl=7}, {fc=104, dl=7}, {fc= 24, dl=7}, {fc= 88, dl=7},
{fc= 56, dl=7}, {fc=120, dl=7}, {fc=  4, dl=7}, {fc= 68, dl=7}, {fc= 36, dl=7},
{fc=100, dl=7}, {fc= 20, dl=7}, {fc= 84, dl=7}, {fc= 52, dl=7}, {fc=116, dl=7},
{fc=  3, dl=8}, {fc=131, dl=8}, {fc= 67, dl=8}, {fc=195, dl=8}, {fc= 35, dl=8},
{fc=163, dl=8}, {fc= 99, dl=8}, {fc=227, dl=8}
}
static_ltree[0] = {fc=12, dl=8}

local static_dtree = {
               {fc=16, dl=5}, {fc= 8, dl=5}, {fc=24, dl=5}, {fc= 4, dl=5},
{fc=20, dl=5}, {fc=12, dl=5}, {fc=28, dl=5}, {fc= 2, dl=5}, {fc=18, dl=5},
{fc=10, dl=5}, {fc=26, dl=5}, {fc= 6, dl=5}, {fc=22, dl=5}, {fc=14, dl=5},
{fc=30, dl=5}, {fc= 1, dl=5}, {fc=17, dl=5}, {fc= 9, dl=5}, {fc=25, dl=5},
{fc= 5, dl=5}, {fc=21, dl=5}, {fc=13, dl=5}, {fc=29, dl=5}, {fc= 3, dl=5},
{fc=19, dl=5}, {fc=11, dl=5}, {fc=27, dl=5}, {fc= 7, dl=5}, {fc=23, dl=5}
}
static_dtree[0] = {fc=0, dl=5}

local _dist_code = {
     1,  2,  3,  4,  4,  5,  5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  8,
 8,  8,  8,  8,  9,  9,  9,  9,  9,  9,  9,  9, 10, 10, 10, 10, 10, 10, 10, 10,
10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13,
13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15,
15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,  0,  0, 16, 17,
18, 18, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22,
23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27,
27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29
}
_dist_code[0] = 0

local _length_code = {
     1,  2,  3,  4,  5,  6,  7,  8,  8,  9,  9, 10, 10, 11, 11, 12, 12, 12, 12,
13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16,
17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19,
19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22,
22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23,
23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26,
26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 28
}
_length_code[0] = 0

local base_length = {
1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40, 48, 56, 64, 80,
96, 112, 128, 160, 192, 224, 0
}
base_length[0] = 0

local base_dist = {
1, 2, 3, 4, 6, 8, 12, 16, 24,
32, 48, 64, 96, 128, 192, 256, 384, 512, 768,
1024, 1536, 2048, 3072, 4096, 6144, 8192, 12288, 16384, 24576
}
base_dist[0] = 0

local static_l_desc = {
	static_tree = static_ltree,
	extra_bits = extra_lbits,
	extra_base = LITERALS+1,
	elems = L_CODES,
	max_length = MAX_BITS
}

local static_d_desc = {
	static_tree = static_dtree,
	extra_bits = extra_dbits,
	extra_base = 0,
	elems = D_CODES,
	max_length = MAX_BITS
}

local static_bl_desc = {
	static_tree = nil,
	extra_bits = extra_blbits,
	extra_base = 0,
	elems = BL_CODES,
	max_length = MAX_BL_BITS
}

-- Mapping from a distance to a distance code. dist is the distance - 1 and must not have side effects. _dist_code[256] and _dist_code[257] are never used.
function d_code(dist)
	if (dist < 256) then
		return _dist_code[dist]
	end
	return _dist_code[256 + rshift(dist, 7)]
end

-- Send a code of the given tree. c and tree must not have side effects
function send_code(s, c, tree)
	return send_bits(s, tree[c].fc, tree[c].dl)
end

-- Output a byte on the stream.
-- IN assertion: there is enough room in pending_buf.
function put_byte(s, c)
	s.pending_buf = s.pending_buf .. string.char(c)
end

-- Output a short LSB first on the stream.
-- IN assertion: there is enough room in pendingBuf.
function put_short(s, w)
	s.pending_buf = s.pending_buf .. string.char(band(w, 0xff))
	s.pending_buf = s.pending_buf .. string.char(band(rshift(w, 8), 0xff))
end

function send_bits(s, value, length)
	s.bits_sent = s.bits_sent + length

	-- If not enough room in bi_buf, use (valid) bits from bi_buf and (16 - bi_valid) bits from value, leaving (width - (16-bi_valid)) unused bits in value.
	if (s.bi_valid > Buf_size - length) then
		s.bi_buf = bor(s.bi_buf, lshift(value, s.bi_valid))
		put_short(s, s.bi_buf)
		s.bi_buf = rshift(value, Buf_size - s.bi_valid)
		s.bi_valid = s.bi_valid + length - Buf_size
	else
		s.bi_buf = bor(s.bi_buf, lshift(value, s.bi_valid))
		s.bi_valid = s.bi_valid + length
	end
end

-- Initialize the tree data structures for a new zlib stream.
function _tr_init(s)
	s.l_desc.dyn_tree = s.dyn_ltree
	s.l_desc.stat_desc = static_l_desc

	s.d_desc.dyn_tree = s.dyn_dtree
	s.d_desc.stat_desc = static_d_desc

	s.bl_desc.dyn_tree = s.bl_tree
	s.bl_desc.stat_desc = static_bl_desc

	s.bi_buf = 0
	s.bi_valid = 0

	--s.compressed_len = 0
	--s.bits_sent = 0

	-- Initialize the first block of the first file:
	init_block(s)
end

-- Initialize a new block.
function init_block(s)
	-- Initialize the trees.
	for n = 0, L_CODES-1 do s.dyn_ltree[n].fc = 0 end
	for n = 0, D_CODES-1 do s.dyn_dtree[n].fc = 0 end
	for n = 0, BL_CODES-1 do s.bl_tree[n].fc = 0 end

	s.dyn_ltree[END_BLOCK].fc = 1
	s.opt_len = 0
	s.static_len = 0
	s.last_lit = 0
	s.matches = 0
end

-- Index within the heap array of least frequent node in the Huffman tree
local SMALLEST = 1

-- Remove the smallest element from the heap and recreate the heap with one less element. Updates heap and heap_len.
function pqremove(s, tree)
	local top = s.heap[SMALLEST]
	s.heap[SMALLEST] = s.heap[s.heap_len]
	s.heap_len = s.heap_len - 1
	pqdownheap(s, tree, SMALLEST)
	return top
end

-- Compares to subtrees, using the tree depth as tie breaker when the subtrees have equal frequency. This minimizes the worst case length.
function smaller(tree, n, m, depth)
	return tree[n].fc < tree[m].fc or (tree[n].fc == tree[m].fc and depth[n] <= depth[m])
end

-- Restore the heap property by moving down the tree starting at node k, exchanging a node with the smallest of its two sons if necessary, stopping when the heap property is re-established (each father smaller than its two sons).
function pqdownheap(s, tree, k)
	local v = s.heap[k]
	local j = lshift(k, 1)  -- left son of k
	while (j <= s.heap_len) do
		-- Set j to the smallest of the two sons:
		if (j < s.heap_len and smaller(tree, s.heap[j+1], s.heap[j], s.depth)) then
			j = j + 1
		end
		-- Exit if v is smaller than both sons
		if (smaller(tree, v, s.heap[j], s.depth)) then break end

		-- Exchange v with the smallest son
		s.heap[k] = s.heap[j]
		k = j

		-- And continue down the tree, setting j to the left son of k
		j = lshift(j, 1)
	end
	s.heap[k] = v
end

-- Compute the optimal bit lengths for a tree and update the total bit length for the current block.
-- IN assertion: the fields freq and dad are set, heap[heap_max] and above are the tree nodes sorted by increasing frequency.
-- OUT assertions: the field len is set to the optimal bit length, the array bl_count contains the frequencies for each bit length. The length opt_len is updated; static_len is also updated if stree is not null.
function gen_bitlen(s, desc)
	local tree = desc.dyn_tree
	local max_code = desc.max_code
	local stree = desc.stat_desc.static_tree
	local extra	= desc.stat_desc.extra_bits
	local base = desc.stat_desc.extra_base
	local max_length = desc.stat_desc.max_length
	local h             -- heap index
	local n, m          -- iterate over the tree elements
	local bits          -- bit length
	local xbits         -- extra bits
	local f             -- frequency
	local overflow = 0  -- number of elements with bit length too large

	for bits = 0, MAX_BITS do s.bl_count[bits] = 0 end

	-- In a first pass, compute the optimal bit lengths (which may overflow in the case of the bit length tree).
	tree[s.heap[s.heap_max]].dl = 0  -- root of the heap

	h = s.heap_max+1
	while (h < HEAP_SIZE) do
		n = s.heap[h]
		bits = tree[tree[n].dl].dl + 1
		if (bits > max_length) then
			bits = max_length
			overflow = overflow + 1
		end
		-- We overwrite tree[n].Dad which is no longer needed
		tree[n].dl = bits

		if (n > max_code) then
			-- not a leaf node
			-- continue
		else
			s.bl_count[bits] = s.bl_count[bits] + 1
			xbits = 0
			if (n >= base) then xbits = extra[n-base] end
			f = tree[n].fc
			s.opt_len = s.opt_len + f * (bits + xbits)
			if (stree) then s.static_len = s.static_len + f * (stree[n].dl + xbits) end
		end
		h = h + 1
	end
	if (overflow == 0) then return end

	--Trace((stderr,"\nbit length overflow\n"));
	-- This happens for example on obj2 and pic of the Calgary corpus

	-- Find the first bit length which could increase:
	while (overflow > 0) do
		bits = max_length-1
		while (s.bl_count[bits] == 0) do bits = bits - 1 end
		s.bl_count[bits] = s.bl_count[bits] - 1  -- move one leaf down the tree
		s.bl_count[bits+1] = s.bl_count[bits+1] + 2  -- move one overflow item as its brother
		s.bl_count[max_length] = s.bl_count[max_length] - 1
		-- The brother of the overflow item also moves one step up, but this does not affect bl_count[max_length]
		overflow = overflow - 2
	end
	
	-- Now recompute all bit lengths, scanning in increasing frequency. h is still equal to HEAP_SIZE. (It is simpler to reconstruct all lengths instead of fixing only the wrong ones. This idea is taken from 'ar' written by Haruhiko Okumura.)
	for bits = max_length, 1, -1 do
		n = s.bl_count[bits]
		while (n ~= 0) do
			h = h - 1
			m = s.heap[h]
			if (m > max_code) then
				-- continue
			else
				if (tree[m].dl ~= bits) then
					--Trace((stderr,"code %d bits %d->%d\n", m, tree[m].Len, bits));
					s.opt_len = s.opt_len + (bits - tree[m].dl) * tree[m].fc
					tree[m].dl = bits
				end
				n = n - 1
			end
		end
	end
end

-- Generate the codes for a given tree and bit counts (which need not be optimal).
-- IN assertion: the array bl_count contains the bit length statistics for the given tree and the field len is set for all tree elements.
-- OUT assertion: the field code is set for all tree elements of non zero code length.
function gen_codes (tree, max_code, bl_count)
	local next_code = {}
	local code = 0

	-- The distribution counts are first used to generate the code values without bit reversal.
	for bits = 1, MAX_BITS do
		code = lshift(code + bl_count[bits-1], 1)
		next_code[bits] = code
	end
	-- Check that the bit counts in bl_count are consistent. The last code must be all ones.
	assert(code + bl_count[MAX_BITS]-1 == lshift(1, MAX_BITS)-1,
		"inconsistent bit counts")
	--Tracev((stderr,"\ngen_codes: max_code %d ", max_code));

	for n = 0, max_code do
		local len = tree[n].dl
		if (len == 0) then
			-- continue
		else
			-- Now reverse the bits
			tree[n].fc = bi_reverse(next_code[len], len)
			next_code[len] = next_code[len] + 1

			--Tracecv(tree != static_ltree, (stderr,"\nn %3d %c l %2d c %4x (%x) ",
			--	 n, (isgraph(n) ? n : ' '), len, tree[n].Code, next_code[len]-1));
		end
	end
end

-- Construct one Huffman tree and assigns the code bit strings and lengths. Update the total bit length for the current block.
-- IN assertion: the field freq is set for all tree elements.
-- OUT assertions: the fields len and code are set to the optimal bit length and corresponding code. The length opt_len is updated; static_len is also updated if stree is not null. The field max_code is set.
function build_tree(s, desc)
	local tree = desc.dyn_tree
	local stree = desc.stat_desc.static_tree
	local elems = desc.stat_desc.elems
	local n, m           -- iterate over heap elements
	local max_code = -1  -- largest code with non zero frequency
	local node           -- new node being created

	-- Construct the initial heap, with least frequent element in heap[SMALLEST]. The sons of heap[n] are heap[2*n] and heap[2*n+1]. heap[0] is not used.
	s.heap_len = 0
	s.heap_max = HEAP_SIZE

	for n = 0, elems-1 do
		if (tree[n].fc ~= 0) then
			s.heap_len = s.heap_len + 1
			max_code = n
			s.heap[s.heap_len] = n
			s.depth[n] = 0
		else
			tree[n].dl = 0
		end
	end

	-- The pkzip format requires that at least one distance code exists, and that at least one bit should be sent even if there is only one possible code. So to avoid special checks later on we force at least two codes of non zero frequency.
	while (s.heap_len < 2) do
		s.heap_len = s.heap_len + 1
		if (max_code < 2) then
			max_code = max_code + 1
			s.heap[s.heap_len] = max_code
		else
			s.heap[s.heap_len] = 0
		end
		node = s.heap[s.heap_len]
		tree[node].fc = 1
		s.depth[node] = 0
		s.opt_len = s.opt_len - 1
		if (stree) then s.static_len = s.static_len - stree[node].dl end
		-- node is 0 or 1 so it does not have extra bits
	end
	desc.max_code = max_code

	-- The elements heap[heap_len/2+1 .. heap_len] are leaves of the tree, establish sub-heaps of increasing lengths:
	for n = rshift(s.heap_len, 1), 1, -1 do pqdownheap(s, tree, n) end

	-- Construct the Huffman tree by repeatedly combining the least two frequent nodes.
	node = elems               -- next internal node of the tree
	while (s.heap_len >= 2) do
		n = pqremove(s, tree)  -- n = node of least frequency
		m = s.heap[SMALLEST]   -- m = node of next least frequency

		-- keep the nodes sorted by frequency
		s.heap_max = s.heap_max - 1
		s.heap[s.heap_max] = n
		s.heap_max = s.heap_max - 1
		s.heap[s.heap_max] = m

		-- Create a new node father of n and m
		tree[node].fc = tree[n].fc + tree[m].fc
		if (s.depth[n] >= s.depth[m]) then
			s.depth[node] = s.depth[n]
		else
			s.depth[node] = s.depth[m] + 1
		end
		tree[n].dl = node
		tree[m].dl = node
--#ifdef DUMP_BL_TREE
--		if (tree == s->bl_tree) {
--			fprintf(stderr,"\nnode %d(%d), sons %d(%d) %d(%d)",
--					node, tree[node].Freq, n, tree[n].Freq, m, tree[m].Freq);
--		}
--#endif

		-- and insert the new node in the heap
		s.heap[SMALLEST] = node
		node = node + 1
		pqdownheap(s, tree, SMALLEST)
	end

	s.heap_max = s.heap_max - 1
	s.heap[s.heap_max] = s.heap[SMALLEST]

	-- At this point, the fields freq and dad are set. We can now generate the bit lengths.
	gen_bitlen(s, desc)

	-- The field len is now set, we can generate the bit codes
	gen_codes(tree, max_code, s.bl_count)
end

-- Scan a literal or distance tree to determine the frequencies of the codes in the bit length tree.
function scan_tree (s, tree, max_code)
	local prevlen = -1          -- last emitted length
	local curlen                -- length of current code
	local nextlen = tree[0].dl  -- length of next code
	local count = 0             -- repeat count of the current code
	local max_count = 7         -- max repeat count
	local min_count = 4         -- min repeat count

	if (nextlen == 0) then max_count = 138; min_count = 3 end
	tree[max_code+1].dl = 0xffff  -- guard

	for n = 0, max_code do
		curlen = nextlen; nextlen = tree[n+1].dl
		count = count + 1
		if (count < max_count and curlen == nextlen) then
			-- continue
		else
			if (count < min_count) then
				s.bl_tree[curlen].fc = s.bl_tree[curlen].fc + count
			elseif (curlen ~= 0) then
				if (curlen ~= prevlen) then s.bl_tree[curlen].fc = s.bl_tree[curlen].fc + 1 end
				s.bl_tree[REP_3_6].fc = s.bl_tree[REP_3_6].fc + 1
			elseif (count <= 10) then
				s.bl_tree[REPZ_3_10].fc = s.bl_tree[REPZ_3_10].fc + 1
			else
				s.bl_tree[REPZ_11_138].fc = s.bl_tree[REPZ_11_138].fc + 1
			end
			count = 0; prevlen = curlen
			if (nextlen == 0) then
				max_count = 138; min_count = 3
			elseif (curlen == nextlen) then
				max_count = 6; min_count = 3
			else
				max_count = 7; min_count = 4
			end
		end
	end
end

-- Send a literal or distance tree in compressed form, using the codes in bl_tree.
function send_tree (s, tree, max_code)
	local prevlen = -1          -- last emitted length
	local curlen                -- length of current code
	local nextlen = tree[0].dl  -- length of next code
	local count = 0             -- repeat count of the current code
	local max_count = 7         -- max repeat count
	local min_count = 4         -- min repeat count

	-- tree[max_code+1].Len = -1  -- guard already set
	if (nextlen == 0) then max_count = 138; min_count = 3 end

	for n = 0, max_code do
		curlen = nextlen; nextlen = tree[n+1].dl
		count = count + 1
		if (count < max_count and curlen == nextlen) then
			-- continue
		else
			if (count < min_count) then
				while count ~= 0 do
					send_code(s, curlen, s.bl_tree)
					count = count - 1
				end
			elseif (curlen ~= 0) then
				if (curlen ~= prevlen) then
					send_code(s, curlen, s.bl_tree)
					count = count - 1
				end
				assert(count >= 3 and count <= 6, " 3_6?")
				send_code(s, REP_3_6, s.bl_tree); send_bits(s, count-3, 2)
	
			elseif (count <= 10) then
				send_code(s, REPZ_3_10, s.bl_tree); send_bits(s, count-3, 3)
	
			else
				send_code(s, REPZ_11_138, s.bl_tree); send_bits(s, count-11, 7)
			end
			count = 0; prevlen = curlen
			if (nextlen == 0) then
				max_count = 138; min_count = 3
			elseif (curlen == nextlen) then
				max_count = 6; min_count = 3
			else
				max_count = 7; min_count = 4
			end
		end
	end
end

-- Construct the Huffman tree for the bit lengths and return the index in bl_order of the last bit length code to send.
function build_bl_tree(s)
	local max_blindex  -- index of last bit length code of non zero freq

	-- Determine the bit length frequencies for literal and distance trees
	scan_tree(s, s.dyn_ltree, s.l_desc.max_code)
	scan_tree(s, s.dyn_dtree, s.d_desc.max_code)

	-- Build the bit length tree:
	build_tree(s, s.bl_desc)
	-- opt_len now includes the length of the tree representations, except the lengths of the bit lengths codes and the 5+5+4 bits for the counts.

	-- Determine the number of bit length codes to send. The pkzip format requires that at least 4 bit length codes be sent. (appnote.txt says 3 but the actual value used is 4.)
	
	max_blindex = BL_CODES-1
	while (max_blindex >= 3) do
		if (s.bl_tree[bl_order[max_blindex]].dl ~= 0) then break end
		max_blindex = max_blindex - 1
	end
	-- Update opt_len to include the bit length tree and counts
	s.opt_len = s.opt_len + 3*(max_blindex+1) + 5+5+4
	--Tracev((stderr, "\ndyn trees: dyn %ld, stat %ld",
	--		s->opt_len, s->static_len));

	return max_blindex
end

-- Send the header for a block using dynamic Huffman trees: the counts, the lengths of the bit length codes, the literal tree and the distance tree.
-- IN assertion: lcodes >= 257, dcodes >= 1, blcodes >= 4.
function send_all_trees(s, lcodes, dcodes, blcodes)
	assert(lcodes >= 257 and dcodes >= 1 and blcodes >= 4, "not enough codes")
	assert(lcodes <= L_CODES and dcodes <= D_CODES and blcodes <= BL_CODES,
		"too many codes")
	--Tracev((stderr, "\nbl counts: "));
	send_bits(s, lcodes-257, 5)  -- not +255 as stated in appnote.txt
	send_bits(s, dcodes-1,   5)
	send_bits(s, blcodes-4,  4)  -- not -3 as stated in appnote.txt
	for rank = 0, blcodes - 1 do
		--Tracev((stderr, "\nbl code %2d ", bl_order[rank]));
		send_bits(s, s.bl_tree[bl_order[rank]].dl, 3)
	end
	--Tracev((stderr, "\nbl tree: sent %ld", s->bits_sent));

	send_tree(s, s.dyn_ltree, lcodes-1)  -- literal tree
	--Tracev((stderr, "\nlit tree: sent %ld", s->bits_sent));

	send_tree(s, s.dyn_dtree, dcodes-1)  -- distance tree
	--Tracev((stderr, "\ndist tree: sent %ld", s->bits_sent));
end

-- Send a stored block
function _tr_stored_block(s, buf, stored_len, last)
	send_bits(s, lshift(STORED_BLOCK, 1)+last, 3)	-- send block type
	--s.compressed_len = band(s.compressed_len + 3 + 7, 0xfffffff8)
	--s.compressed_len = s.compressed_len + lshift(stored_len + 4, 3)
	copy_block(s, buf, stored_len, 1)  -- with header
end

-- Flush the bits in the bit buffer to pending output (leaves at most 7 bits)
function _tr_flush_bits(s)
	bi_flush(s)
end

-- Send one empty static block to give enough lookahead for inflate. This takes 10 bits, of which 7 may remain in the bit buffer.
function _tr_align(s)
	send_bits(s, lshift(STATIC_TREES, 1), 3)
	send_code(s, END_BLOCK, static_ltree)
	--s.compressed_len = s.compressed_len + 10  -- 3 for block type, 7 for EOB
	bi_flush(s)
end

--  Determine the best encoding for the current block: dynamic trees, static trees or store, and output the encoded block to the zip file.
function _tr_flush_block(s, buf, stored_len, last)
	local opt_lenb, static_lenb  -- opt_len and static_len in bytes
	local max_blindex = 0  -- index of last bit length code of non zero freq

	-- Build the Huffman trees unless a stored block is forced
	if (s.level > 0) then

		-- Check if the file is binary or text
		if (s.strm.data_type == ZLIB.Z_UNKNOWN) then
			s.strm.data_type = detect_data_type(s)
		end
		
		-- Construct the literal and distance trees
		build_tree(s, s.l_desc)
		--Tracev((stderr, "\nlit data: dyn %ld, stat %ld", s->opt_len,
		--		s->static_len));

		build_tree(s, s.d_desc)
		--Tracev((stderr, "\ndist data: dyn %ld, stat %ld", s->opt_len,
		--		s->static_len));
		-- At this point, opt_len and static_len are the total bit lengths of the compressed block data, excluding the tree representations.

		-- Build the bit length tree for the above two trees, and get the index in bl_order of the last bit length code to send.
		max_blindex = build_bl_tree(s)

		-- Determine the best encoding. Compute the block lengths in bytes.
		opt_lenb = rshift(s.opt_len+3+7, 3)
		static_lenb = rshift(s.static_len+3+7, 3)

		--Tracev((stderr, "\nopt %lu(%lu) stat %lu(%lu) stored %lu lit %u ",
		--		opt_lenb, s->opt_len, static_lenb, s->static_len, stored_len,
		--		s->last_lit));

		if (static_lenb <= opt_lenb) then opt_lenb = static_lenb end

	else
		--Assert(buf != (char*)0, "lost buf");
		static_lenb = stored_len + 5  -- force a stored block
		opt_lenb = static_lenb
	end

	if (stored_len+4 <= opt_lenb and buf ~= nil) then
		-- 4: two words for the lengths

		-- The test buf != NULL is only necessary if LIT_BUFSIZE > WSIZE.
		-- Otherwise we can't have processed more than WSIZE input bytes since the last block flush, because compression would have been successful. If LIT_BUFSIZE <= WSIZE, it is never too late to transform a block into a stored block.
		_tr_stored_block(s, buf, stored_len, last)

	elseif (s.strategy == ZLIB.Z_FIXED or static_lenb == opt_lenb) then
		send_bits(s, lshift(STATIC_TREES, 1)+last, 3)
		compress_block(s, static_ltree, static_dtree)
		--s.compressed_len = s.compressed_len + 3 + s.static_len
	else
		send_bits(s, lshift(DYN_TREES, 1)+last, 3)
		send_all_trees(s, s.l_desc.max_code+1, s.d_desc.max_code+1, max_blindex+1)
		compress_block(s, s.dyn_ltree, s.dyn_dtree)
		--s.compressed_len = s.compressed_len + 3 + s.opt_len
	end
	--assert(s.compressed_len == s.bits_sent, "bad compressed size")
	-- The above check is made mod 2^32, for files larger than 512 MB and uLong implemented on 32 bits.
	init_block(s)

	if (last > 0) then
		bi_windup(s)
		--s.compressed_len = s.compressed_len + 7  -- align on byte boundary
	end
	--Tracev((stderr,"\ncomprlen %lu(%lu) ", s->compressed_len>>3,
	--	   s->compressed_len-7*last));
end

-- Save the match info and tally the frequency counts. Return true if the current block must be flushed.
function _tr_tally (s, dist, lc)
	s.d_buf[s.last_lit] = dist
	s.l_buf[s.last_lit] = lc
	s.last_lit = s.last_lit + 1
	if (dist == 0) then
		-- lc is the unmatched char
		s.dyn_ltree[lc].fc = s.dyn_ltree[lc].fc + 1
	else
		s.matches = s.matches + 1
		-- Here, lc is the match length - MIN_MATCH
		dist = dist - 1  -- dist = match distance - 1
		assert(dist < MAX_DIST(s)
			and lc <= MAX_MATCH-MIN_MATCH
			and d_code(dist) < D_CODES,  "_tr_tally: bad match")

		s.dyn_ltree[_length_code[lc]+LITERALS+1].fc = s.dyn_ltree[_length_code[lc]+LITERALS+1].fc + 1
		s.dyn_dtree[d_code(dist)].fc = s.dyn_dtree[d_code(dist)].fc + 1
	end

	return (s.last_lit == s.lit_bufsize-1)
	-- We avoid equality with lit_bufsize because of wraparound at 64K on 16 bit machines and because stored blocks are restricted to 64K-1 bytes.
end

function _tr_tally_lit(s, c)
	return _tr_tally(s, 0, c)
end

function _tr_tally_dist(s, distance, length)
	return _tr_tally(s, distance, length)
end

-- Send the block data compressed using the given Huffman trees
function compress_block(s, ltree, dtree)
	local dist   -- distance of matched string
	local lc     -- match length or unmatched char (if dist == 0)
	local lx = 0 -- running index in l_buf
	local code   -- the code to send
	local extra  -- number of extra bits to send

	while (lx < s.last_lit) do
		dist = s.d_buf[lx]
		lc = s.l_buf[lx]
		lx = lx + 1
		if (dist == 0) then
			send_code(s, lc, ltree)  -- send a literal byte
			--Tracecv(isgraph(lc), (stderr," '%c' ", lc));
		else
			-- Here, lc is the match length - MIN_MATCH
			code = _length_code[lc]
			send_code(s, code+LITERALS+1, ltree)  -- send the length code
			extra = extra_lbits[code]
			if (extra ~= 0) then
				lc = lc - base_length[code]
				send_bits(s, lc, extra)  -- send the extra length bits
			end
			dist = dist - 1  -- dist is now the match distance - 1
			code = d_code(dist)
			assert(code < D_CODES, "bad d_code")

			send_code(s, code, dtree)  -- send the distance code
			extra = extra_dbits[code]
			if (extra ~= 0) then
				dist = dist - base_dist[code]
				send_bits(s, dist, extra)  -- send the extra distance bits
			end
		end  -- literal or match pair ?
		
		-- Check that the overlay between pending_buf and d_buf+l_buf is ok:
		assert(s.pending_buf:len() < s.lit_bufsize + 2*lx,
			   "pendingBuf overflow")

	end

	send_code(s, END_BLOCK, ltree)
end

-- Check if the data type is TEXT or BINARY, using the following algorithm:
-- - TEXT if the two conditions below are satisfied:
--	a) There are no non-portable control characters belonging to the "black list" (0..6, 14..25, 28..31).
--	b) There is at least one printable character belonging to the "white list" (9 {TAB}, 10 {LF}, 13 {CR}, 32..255).
-- - BINARY otherwise.
-- - The following partially-portable control characters form a "gray list" that is ignored in this detection algorithm:
--   (7 {BEL}, 8 {BS}, 11 {VT}, 12 {FF}, 26 {SUB}, 27 {ESC}).
-- IN assertion: the fields Freq of dyn_ltree are set.
function detect_data_type(s)
	-- black_mask is the bit mask of black-listed bytes
	-- set bits 0..6, 14..25, and 28..31
	-- 0xf3ffc07f = binary 11110011111111111100000001111111
	local black_mask = 0xf3ffc07f

	-- Check for non-textual ("black-listed") bytes.
	for n = 0, 31 do
		black_mask = rshift(black_mask, 1)
		if (band(black_mask, 1) and (s.dyn_ltree[n].fc ~= 0)) then
			return ZLIB.Z_BINARY
		end
	end

	-- Check for textual ("white-listed") bytes.
	if (s.dyn_ltree[9].fc ~= 0 or s.dyn_ltree[10].fc ~= 0 or s.dyn_ltree[13].fc ~= 0) then
		return ZLIB.Z_TEXT
	end
	for n = 32, LITERALS-1 do
		if (s.dyn_ltree[n].fc ~= 0) then
			return ZLIB.Z_TEXT
		end
	end

	-- There are no "black-listed" or "white-listed" bytes:
	-- this stream either is empty or has tolerated ("gray-listed") bytes only.
	return ZLIB.Z_BINARY
end

-- Reverse the first len bits of a code, using straightforward code (a faster method would use a table)
-- IN assertion: 1 <= len <= 15
function bi_reverse(code, len)
	local res = 0
	while (len > 0) do
		res = bor(res, band(code, 1))
		code = rshift(code, 1)
		res = lshift(res, 1)
		len = len - 1
	end
	return rshift(res, 1)
end

-- Flush the bit buffer, keeping at most 7 bits in it.
function bi_flush(s)
	if (s.bi_valid == 16) then
		put_short(s, s.bi_buf)
		s.bi_buf = 0
		s.bi_valid = 0
	elseif (s.bi_valid >= 8) then
		put_byte(s, band(s.bi_buf, 0xff))
		s.bi_buf = rshift(s.bi_buf, 8)
		s.bi_valid = s.bi_valid - 8
	end
end

-- Flush the bit buffer and align the output on a byte boundary
function bi_windup(s)
	if (s.bi_valid > 8) then
		put_short(s, s.bi_buf)
	elseif (s.bi_valid > 0) then
		put_byte(s, s.bi_buf)
	end
	s.bi_buf = 0
	s.bi_valid = 0
end

-- Copy a stored block, storing first the length and its one's complement if requested.
function copy_block(s, buf, len, header)
	bi_windup(s)  -- align on byte boundary

	if (header) then
		put_short(s, len)
		put_short(s, bnot(len))
	end
	local window = s.window
	while (len > 0) do
		len = len - 1
		put_byte(s, window[buf])
		buf = buf + 1
	end
end


-- ===========================================================================
-- deflate.c -- compress data using the deflation algorithm

-- enum block_state
local need_more = 0       -- block not completed, need more input or more output
local block_done = 1      -- block flush performed
local finish_started = 2  -- finish started, need only more output at next deflate
local finish_done = 3     -- finish done, accept no more input or output

local TOO_FAR = 4096

-- Note: the deflate() code requires max_lazy >= MIN_MATCH and max_chain >= 4
-- For deflate_fast() (levels <= 3) good is ignored and lazy has a different meaning.
local configuration_table = {
	{good_length=4,  max_lazy=4,   nice_length=8,   max_chain=4,    func=deflate_fast},  -- max speed, no lazy matches
	{good_length=4,  max_lazy=5,   nice_length=16,  max_chain=8,    func=deflate_fast},
	{good_length=4,  max_lazy=6,   nice_length=32,  max_chain=32,   func=deflate_fast},
	{good_length=4,  max_lazy=4,   nice_length=16,  max_chain=16,   func=deflate_slow},  -- lazy matches
	{good_length=8,  max_lazy=16,  nice_length=32,  max_chain=32,   func=deflate_slow},
	{good_length=8,  max_lazy=16,  nice_length=128, max_chain=128,  func=deflate_slow},
	{good_length=8,  max_lazy=32,  nice_length=128, max_chain=256,  func=deflate_slow},
	{good_length=32, max_lazy=128, nice_length=258, max_chain=1024, func=deflate_slow},
	{good_length=32, max_lazy=258, nice_length=258, max_chain=4096, func=deflate_slow},
}
configuration_table[0] =
	{good_length=0,  max_lazy=0,   nice_length=0,   max_chain=0,    func=deflate_stored}  -- store only

-- rank Z_BLOCK between Z_NO_FLUSH and Z_PARTIAL_FLUSH
function RANK(f)
	if (f > 4) then
		return lshift(f, 1) - 9
	end
	return lshift(f, 1)
end

-- Update a hash value with the given input byte
-- IN  assertion: all calls to to UPDATE_HASH are made with consecutive input characters, so that a running hash key can be computed from the previous key instead of complete recalculation each time.
function UPDATE_HASH(s,c)
	s.ins_h = band(bxor(lshift(s.ins_h, s.hash_shift), c), s.hash_mask)
end

-- Insert string str in the dictionary and set match_head to the previous head of the hash chain (the most recent string with same hash key). Return the previous length of the hash chain.
-- IN  assertion: all calls to to INSERT_STRING are made with consecutive input characters and the first MIN_MATCH bytes of str are valid (except for the last MIN_MATCH-1 bytes of the input file).
function INSERT_STRING(s)
	local str = s.strstart
	UPDATE_HASH(s, s.window[str + (MIN_MATCH-1)])
	local match_head = s.head[s.ins_h]
	s.prev[band(str, s.w_mask)] = s.head[s.ins_h]
	s.head[s.ins_h] = str
	return match_head
end

-- Initialize the hash table (avoiding 64K overflow for 16 bit systems).
-- prev[] will be initialized on the fly.
function CLEAR_HASH(s)
	for i = 0, s.hash_size-1 do
		s.head[i] = 0
	end
end

ZLIB.deflateInit = function(opts)
	local level	= getarg(opts, 'level', ZLIB.Z_DEFAULT_COMPRESSION)
	local method = getarg(opts, 'method', ZLIB.Z_DEFLATED)
	local windowBits = getarg(opts, 'windowBits', ZLIB.MAX_WBITS)
	local memLevel = getarg(opts, 'memLevel', DEF_MEM_LEVEL)
	local strategy = getarg(opts, 'strategy', ZLIB.Z_DEFAULT_STRATEGY)
	return deflateInit2(level, method, windowBits, memLevel, strategy)
end

function deflateInit2(level, method, windowBits, memLevel, strategy)
	local s  -- deflate_state
	local wrap = 1

	local strm = ZLIB.z_stream()
	if (level == ZLIB.Z_DEFAULT_COMPRESSION) then level = 6 end

	if (windowBits < 0) then  -- suppress zlib wrapper
		wrap = 0
		windowBits = -windowBits
	elseif (windowBits > 15) then
		wrap = 2  -- write gzip wrapper instead
		windowBits = windowBits - 16
	end

	if (wrap == 1 and ZLIB.adler32) then
		strm.checksum_function = ZLIB.adler32
	elseif (wrap == 2 and ZLIB.crc32) then
		strm.checksum_function = ZLIB.crc32
	else
		strm.checksum_function = checksum_none
	end

	if (memLevel < 1 or memLevel > ZLIB.MAX_MEM_LEVEL or method ~= ZLIB.Z_DEFLATED
		or windowBits < 8 or windowBits > 15 or level < 0 or level > 9
		or strategy < 0 or strategy > ZLIB.Z_FIXED) then
		return nil  -- ZLIB.Z_STREAM_ERROR
	end
	if (windowBits == 8) then windowBits = 9 end  -- until 256-byte window bug fixed
	s = deflate_state()
	strm.state = s
	s.strm = strm

	s.wrap = wrap
	s.gzhead = nil
	s.w_bits = windowBits
	s.w_size = lshift(1, s.w_bits)
	s.w_mask = s.w_size - 1

	s.hash_bits = memLevel + 7
	s.hash_size = lshift(1, s.hash_bits)
	s.hash_mask = s.hash_size - 1
	s.hash_shift = band((s.hash_bits+MIN_MATCH-1)/MIN_MATCH, 0xffffffff)

	s.window = new_array(s.w_size)
	s.prev   = new_array(s.w_size)
	s.head   = new_array(s.hash_size)

	s.high_water = 0  -- nothing written to s->window yet

	s.lit_bufsize = lshift(1, memLevel + 6)  -- 16K elements by default

	s.pending_buf = ''
	s.pending_buf_size = s.lit_bufsize * 4

	s.d_buf = new_array(s.lit_bufsize)
	s.l_buf = new_array(s.lit_bufsize)

	s.level = level
	s.strategy = strategy
	s.method = method

	ZLIB.deflateReset(strm)
	return strm
end

ZLIB.deflateResetKeep = function(strm)
	local s

	if (not strm or not strm.state) then
		return ZLIB.Z_STREAM_ERROR
	end

	strm.total_in = 0
	strm.total_out = 0
	strm.msg = nil  -- use zfree if we ever allocate msg dynamically
	strm.data_type = ZLIB.Z_UNKNOWN

	s = strm.state
	s.pending_buf = ''

	if (s.wrap < 0) then
		s.wrap = -s.wrap  -- was made negative by deflate(..., Z_FINISH)
	end
	if (s.wrap ~= 0) then
		s.status = INIT_STATE
	else
		s.status = BUSY_STATE
	end
	strm.adler = strm.checksum_function(0, nil, 0, 0)
	s.last_flush = ZLIB.Z_NO_FLUSH

	_tr_init(s)

	return ZLIB.Z_OK
end

ZLIB.deflateReset = function(strm)
	local ret

	ret = ZLIB.deflateResetKeep(strm)
	if (ret == ZLIB.Z_OK) then
		lm_init(strm.state)
	end
	return ret
end

-- For the default windowBits of 15 and memLevel of 8, this function returns a close to exact, as well as small, upper bound on the compressed size. They are coded as constants here for a reason--if the #define's are changed, then this function needs to be changed as well.  The return value for 15 and 8 only works for those exact settings.
-- For any setting other than those defaults for windowBits and memLevel, the value returned is a conservative worst case for the maximum expansion resulting from using fixed blocks instead of stored blocks, which deflate can emit on compressed data for some combinations of the parameters.
-- This function could be more sophisticated to provide closer upper bounds for every combination of windowBits and memLevel.  But even the conservative upper bound of about 14% expansion does not seem onerous for output buffer allocation.
ZLIB.deflateBound = function(strm, sourceLen)
	local s
	local complen, wraplen
	local str

	-- conservative upper bound for compressed data
	complen = sourceLen + rshift(sourceLen + 7, 3) + rshift(sourceLen + 63, 6) + 5

	-- if can't get parameters, return conservative bound plus zlib wrapper
	if (not strm or not strm.state) then
		return complen + 6
	end
	
	-- compute wrapper length
	s = strm.state
	if (s.wrap == 0) then				-- raw deflate
		wraplen = 0
	elseif (s.wrap == 1) then			-- zlib wrapper
		if (s.strstart ~= 0) then
			wraplen = 6 + 4
		else
			wraplen = 6
		end
	elseif (s.wrap == 2) then			-- gzip wrapper
		wraplen = 18
		if (s.gzhead ~= nil) then		-- user-supplied gzip header
			if (s.gzhead.extra ~= nil) then
				wraplen = wraplen + 2 + s.gzhead.extra:len()
			end
			str = s.gzhead.name
			if (str ~= nil) then
				local len = 0
				repeat
					len = len + 1
					wraplen = wraplen + 1
				until (len >= str:len() or str:byte(len,len) == 0)
			end
			str = s.gzhead.comment
			if (str ~= nil) then
				local len = 0
				repeat
					len = len + 1
					wraplen = wraplen + 1
				until (len >= str:len() or str:byte(len,len) == 0)
			end
			if (s.gzhead.hcrc) then
				wraplen = wraplen + 2
			end
		end
	else 								-- for compiler happiness
		wraplen = 6
	end

	-- if not default parameters, return conservative bound
	if (s.w_bits ~= 15 or s.hash_bits ~= 8 + 7) then
		return complen + wraplen
	end

	-- default settings: return tight bound for that case
	return sourceLen + rshift(sourceLen, 12) + rshift(sourceLen, 14) + rshift(sourceLen, 25) + 13 - 6 + wraplen
end

-- Put a short in the pending buffer. The 16-bit value is put in MSB order.
-- IN assertion: the stream state is correct and there is enough room in pending_buf.
function putShortMSB (s, b)
	s.pending_buf = s.pending_buf .. string.char(band(rshift(b, 8), 0xff))
	s.pending_buf = s.pending_buf .. string.char(band(b, 0xff))
end

-- Flush as much pending output as possible. All deflate() output goes through this function so some applications may wish to modify it to avoid allocating a large strm->next_out buffer and copying into it.
-- (See also read_buf()).
function flush_pending(strm)
	local len
	local s = strm.state

	_tr_flush_bits(s)
	len = s.pending_buf:len()
	if (len > strm.avail_out) then len = strm.avail_out end
	if (len == 0) then return end

	strm.output_data = strm.output_data .. s.pending_buf:sub(1, len)
	s.pending_buf = s.pending_buf:sub(len + 1)
	strm.total_out = strm.total_out + len
	strm.avail_out = strm.avail_out - len
end

local z_errmsg = {
	'need dictionary',       -- Z_NEED_DICT       2
	 'stream end',		     -- Z_STREAM_END      1
	 '',                     -- Z_OK              0
	 'file error',           -- Z_ERRNO         (-1)
	 'stream error',         -- Z_STREAM_ERROR  (-2)
	 'data error',           -- Z_DATA_ERROR    (-3)
	 'insufficient memory',  -- Z_MEM_ERROR     (-4)
	 'buffer error',         -- Z_BUF_ERROR     (-5)
	 'incompatible version', -- Z_VERSION_ERROR (-6)
	 ''
}
function ERR_MSG(err) 
	return z_errmsg[3 - err]
end
function ERR_RETURN(strm, err)
	strm.msg = ERR_MSG(err)
	return err
end

ZLIB.deflate = function(strm, flush)
	local old_flush  -- value of flush param for previous deflate call
	local s

	if (not strm or not strm.state or
		flush > ZLIB.Z_BLOCK or flush < 0) then
		return ZLIB.Z_STREAM_ERROR
	end
	s = strm.state

	if (strm.output_data == nil
		or (strm.input_data == nil and strm.avail_in ~= 0)
		or (s.status == FINISH_STATE and flush ~= ZLIB.Z_FINISH)) then
		return ERR_RETURN(strm, ZLIB.Z_STREAM_ERROR)
	end
	if (strm.avail_out == 0) then return ERR_RETURN(strm, ZLIB.Z_BUF_ERROR) end

	s.strm = strm  -- just in case
	old_flush = s.last_flush
	s.last_flush = flush

	-- Write the header
	if (s.status == INIT_STATE) then
		if (s.wrap == 2) then
			strm.adler = strm.checksum_function(0, nil, 0, 0)
			put_byte(s, 31)
			put_byte(s, 139)
			put_byte(s, 8)
			if (s.gzhead == nil) then
				put_byte(s, 0)
				put_byte(s, 0)
				put_byte(s, 0)
				put_byte(s, 0)
				put_byte(s, 0)
				if (s.level == 9) then
					put_byte(s, 2)
				elseif (s.strategy >= ZLIB.Z_HUFFMAN_ONLY or s.level < 2) then
					put_byte(s, 4)
				else
					put_byte(s, 0)
				end
				put_byte(s, ZLIB.OS_CODE)
				s.status = BUSY_STATE
			else
				local flags = 0
				if (s.gzhead.text) then flags = flags + 1 end
				if (s.gzhead.hcrc) then flags = flags + 2 end
				if (s.gzhead.extra) then flags = flags + 4 end
				if (s.gzhead.name) then flags = flags + 8 end
				if (s.gzhead.comment) then flags = flags + 16 end
				put_byte(s, flags)
				put_byte(s, band(s.gzhead.time, 0xff))
				put_byte(s, band(rshift(s.gzhead.time, 8), 0xff))
				put_byte(s, band(rshift(s.gzhead.time, 16), 0xff))
				put_byte(s, band(rshift(s.gzhead.time, 24), 0xff))
				if (s.level == 9) then
					put_byte(s, 2)
				elseif (s.strategy >= ZLIB.Z_HUFFMAN_ONLY or s.level < 2) then
					put_byte(s, 4)
				else
					put_byte(s, 0)
				end
				put_byte(s, band(s.gzhead.os, 0xff))
				if (s.gzhead.extra ~= nil) then
					put_byte(s, band(s.gzhead.extra:len(), 0xff))
					put_byte(s, band(rshift(s.gzhead.extra:len(), 8), 0xff))
				end
				if (s.gzhead.hcrc) then
					strm.adler = strm.checksum_function(strm.adler, s.pending_buf, s.pending)
				end
				s.gzindex = 0
				s.status = EXTRA_STATE
			end
		else
			local header = lshift(ZLIB.Z_DEFLATED + lshift(s.w_bits-8, 4), 8)
			local level_flags

			if (s.strategy >= ZLIB.Z_HUFFMAN_ONLY or s.level < 2) then
				level_flags = 0
			elseif (s.level < 6) then
				level_flags = 1
			elseif (s.level == 6) then
				level_flags = 2
			else
				level_flags = 3
			end
			header = bor(header, lshift(level_flags, 6))
			if (s.strstart ~= 0) then header = bor(header, PRESET_DICT) end
			header = header + 31 - (header % 31)

			s.status = BUSY_STATE
			putShortMSB(s, header)

			-- Save the adler32 of the preset dictionary:
			if (s.strstart ~= 0) then
				putShortMSB(s, rshift(strm.adler, 16))
				putShortMSB(s, band(strm.adler, 0xffff))
			end
			strm.adler = strm.checksum_function(0, nil, 0, 0)
		end
	end
	if (s.status == EXTRA_STATE) then
		if (s.gzhead.extra ~= nil) then
			local beg = s.pending_buf:len()  -- start of bytes to update crc
			local extra_len = s.gzhead.extra:len()

			while (s.gzindex < band(extra_len, 0xffff)) do
				if (s.pending_buf:len() == s.pending_buf_size) then
					if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
						strm.adler = strm.checksum_function(strm.adler, s.pending_buf, beg, s.pending_buf:len() - beg)
					end
					flush_pending(strm)
					beg = s.pending_buf:len()
					if (s.pending_buf:len() == s.pending_buf_size) then
						break
					end
				end
				s.gzindex = s.gzindex + 1
				put_byte(s, band(s.gzhead.extra:byte(s.gzindex,s.gzindex), 0xff))
			end
			if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
				strm.adler = strm.checksum_function(strm.adler, s.pending_buf, beg, s.pending_buf:len() - beg)
			end
			if (s.gzindex == extra_len) then
				s.gzindex = 0
				s.status = NAME_STATE
			end
		else
			s.status = NAME_STATE
		end
	end
	if (s.status == NAME_STATE) then
		if (s.gzhead.name ~= nil) then
			local beg = s.pending_buf:len()  -- start of bytes to update crc
			local val = 1

			while (val ~= 0) do
				if (s.pending_buf:len() == s.pending_buf_size) then
					if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
						strm.adler = strm.checksum_function(strm.adler, s.pending_buf + beg, s.pending_buf:len() - beg)
					end
					flush_pending(strm)
					beg = s.pending_buf:len()
					if (s.pending_buf:len() == s.pending_buf_size) then
						val = 1
						break
					end
				end
				if (s.gzindex == s.gzhead.name:len()) then
					val = 0
				else
					s.gzindex = s.gzindex + 1
					val = band(s.gzhead.name:byte(s.gzindex,s.gzindex), 0xff)
				end
				put_byte(s, val)
			end
			if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
				strm.adler = strm.checksum_function(strm.adler, s.pending_buf, beg, s.pending_buf:len() - beg)
			end
			if (val == 0) then
				s.gzindex = 0
				s.status = COMMENT_STATE
			end
		else
			s.status = COMMENT_STATE
		end
	end
	if (s.status == COMMENT_STATE) then
		if (s.gzhead.comment ~= nil) then
			local beg = s.pending_buf:len()  -- start of bytes to update crc
			local val = 1

			while (val ~= 0) do
				if (s.pending_buf:len() == s.pending_buf_size) then
					if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
						strm.adler = strm.checksum_function(strm.adler, s.pending_buf, beg, s.pending_buf:len() - beg)
					end
					flush_pending(strm)
					beg = s.pending_buf:len()
					if (s.pending_buf:len() == s.pending_buf_size) then
						val = 1
						break
					end
				end
				if (s.gzhead.comment:len() == s.gzindex) then
					val = 0
				else
					s.gzindex = s.gzindex + 1
					val = band(s.gzhead.comment:byte(s.gzindex,s.gzindex), 0xff)
				end
				put_byte(s, val)
			end
			if (s.gzhead.hcrc and s.pending_buf:len() > beg) then
				strm.adler = strm.checksum_function(strm.adler, s.pending_buf, beg, s.pending_buf:len() - beg)
			end
			if (val == 0) then
				s.status = HCRC_STATE
			end
		else
			s.status = HCRC_STATE
		end
	end
	if (s.status == HCRC_STATE) then
		if (s.gzhead.hcrc) then
			if (s.pending_buf:len() + 2 > s.pending_buf_size) then
				flush_pending(strm)
			end
			if (s.pending_buf:len() + 2 <= s.pending_buf_size) then
				put_byte(s, band(strm.adler, 0xff))
				put_byte(s, band(rshift(strm.adler, 8), 0xff))
				strm.adler = strm.checksum_function(0, nil, 0, 0)
				s.status = BUSY_STATE
			end
		else
			s.status = BUSY_STATE
		end
	end

	-- Flush as much pending output as possible
	if (s.pending_buf:len() ~= 0) then
		flush_pending(strm)
		if (strm.avail_out == 0) then
			-- Since avail_out is 0, deflate will be called again with more output space, but possibly with both pending and avail_in equal to zero. There won't be anything to do, but this is not an error situation so make sure we return OK instead of BUF_ERROR at next call of deflate:
			s.last_flush = -1
			return ZLIB.Z_OK
		end

	-- Make sure there is something to do and avoid duplicate consecutive flushes. For repeated and useless calls with Z_FINISH, we keep returning Z_STREAM_END instead of Z_BUF_ERROR.
	elseif (strm.avail_in == 0 and RANK(flush) <= RANK(old_flush) and flush ~= ZLIB.Z_FINISH) then
		return ERR_RETURN(strm, ZLIB.Z_BUF_ERROR)
	end

	-- User must not provide more input after the first FINISH:
	if (s.status == FINISH_STATE and strm.avail_in ~= 0) then
		return ERR_RETURN(strm, ZLIB.Z_BUF_ERROR)
	end

	-- Start a new block or continue the current one.
	if (strm.avail_in ~= 0 or s.lookahead ~= 0
		or (flush ~= ZLIB.Z_NO_FLUSH and s.status ~= FINISH_STATE)) then
		local bstate

		if (s.strategy == ZLIB.Z_HUFFMAN_ONLY) then
			bstate = deflate_huff(s, flush)
		elseif (s.strategy == ZLIB.Z_RLE) then
			bstate = deflate_rle(s, flush)
		else
			if (s.level >= 4) then
				bstate = deflate_slow(s, flush)
			elseif (s.level >= 1) then
				bstate = deflate_fast(s, flush)
			else
				bstate = deflate_stored(s, flush)
			end
			--bstate = (configuration_table[s.level].func)(s, flush)
		end

		if (bstate == finish_started or bstate == finish_done) then
			s.status = FINISH_STATE
		end
		if (bstate == need_more or bstate == finish_started) then
			if (strm.avail_out == 0) then
				s.last_flush = -1  -- avoid BUF_ERROR next call, see above
			end
			return ZLIB.Z_OK
			-- If flush != Z_NO_FLUSH && avail_out == 0, the next call of deflate should use the same flush parameter to make sure that the flush is complete. So we don't have to output an empty block here, this will be done at next call. This also ensures that for a very small output buffer, we emit at most one empty block.
		end
		if (bstate == block_done) then
			if (flush == ZLIB.Z_PARTIAL_FLUSH) then
				_tr_align(s)
			elseif (flush ~= ZLIB.Z_BLOCK) then  -- FULL_FLUSH or SYNC_FLUSH
				_tr_stored_block(s, nil, 0, 0)
				-- For a full flush, this empty block will be recognized as a special marker by inflate_sync().
				if (flush == ZLIB.Z_FULL_FLUSH) then
					CLEAR_HASH(s)  -- forget history
					if (s.lookahead == 0) then
						s.strstart = 0
						s.block_start = 0
						s.insert = 0
					end
				end
			end
			flush_pending(strm)
			if (strm.avail_out == 0) then
				s.last_flush = -1  -- avoid BUF_ERROR at next call, see above
				return ZLIB.Z_OK
			end
		end
	end
	assert(s.strm.avail_out > 0, "bug2")

	if (flush ~= ZLIB.Z_FINISH) then return ZLIB.Z_OK end
	if (s.wrap <= 0) then return ZLIB.Z_STREAM_END end

	-- Write the trailer
	if (s.wrap == 2) then
		put_byte(s, band(strm.adler, 0xff))
		put_byte(s, band(rshift(strm.adler, 8), 0xff))
		put_byte(s, band(rshift(strm.adler, 16), 0xff))
		put_byte(s, band(rshift(strm.adler, 24), 0xff))
		put_byte(s, band(strm.total_in, 0xff))
		put_byte(s, band(rshift(strm.total_in, 8), 0xff))
		put_byte(s, band(rshift(strm.total_in, 16), 0xff))
		put_byte(s, band(rshift(strm.total_in, 24), 0xff))
	else
		putShortMSB(s, rshift(strm.adler, 16))
		putShortMSB(s, band(strm.adler, 0xffff))
	end
	flush_pending(strm)
	-- If avail_out is zero, the application will call deflate again to flush the rest.
	if (s.wrap > 0) then s.wrap = -s.wrap end  -- write the trailer only once!
	if (s.pending_buf:len() ~= 0) then
		return ZLIB.Z_OK
	else
		return ZLIB.Z_STREAM_END
	end
end

ZLIB.deflateEnd = function(strm)
	local status

	if (not strm or not strm.state) then return ZLIB.Z_STREAM_ERROR end

	status = strm.state.status
	if (status ~= INIT_STATE
		and status ~= EXTRA_STATE
		and status ~= NAME_STATE
		and status ~= COMMENT_STATE
		and status ~= HCRC_STATE
		and status ~= BUSY_STATE
		and status ~= FINISH_STATE) then
		return ZLIB.Z_STREAM_ERROR
	end

	-- Deallocate in reverse order of allocations:
	strm.state.pending_buf = nil
	strm.state.head = nil
	strm.state.prev = nil
	strm.state.window = nil

	strm.state = nil

	if (status == BUSY_STATE) then
		return ZLIB.Z_DATA_ERROR
	else
		return ZLIB.Z_OK
	end
end

-- Read a new buffer from the current input stream, update the adler32 and total number of bytes read.  All deflate() input goes through this function so some applications may wish to modify it to avoid allocating a large strm.input_data buffer and copying from it.
-- (See also flush_pending()).
function read_buf(strm, buf, offset, size)
	local len = strm.avail_in

	if (len > size) then len = size end
	if (len == 0) then return 0 end

	strm.avail_in = strm.avail_in - len

	local src_i = strm.next_in
	for i = 1, len do
		buf[offset + i - 1] = band(strm.input_data:byte(src_i + i, src_i + i), 0xff)
	end
	if (strm.state.wrap ~= 0) then
		strm.adler = strm.checksum_function(strm.adler, buf, offset, len)
	end
	strm.next_in = strm.next_in + len
	strm.total_in = strm.total_in + len

	return len
end

-- Initialize the "longest match" routines for a new zlib stream
function lm_init (s)
	s.window_size = 2*s.w_size

	CLEAR_HASH(s)

	-- Set the default configuration parameters:
	s.max_lazy_match   = configuration_table[s.level].max_lazy
	s.good_match	   = configuration_table[s.level].good_length
	s.nice_match	   = configuration_table[s.level].nice_length
	s.max_chain_length = configuration_table[s.level].max_chain

	s.strstart = 0
	s.block_start = 0
	s.lookahead = 0
	s.insert = 0
	s.match_length = MIN_MATCH-1
	s.prev_length = s.match_length
	s.match_available = false
	s.ins_h = 0
end


-- Set match_start to the longest match starting at the given string and return its length. Matches shorter or equal to prev_length are discarded, in which case the result is equal to prev_length and match_start is garbage.
-- IN assertions: cur_match is the head of the hash chain for the current string (strstart) and its distance is <= MAX_DIST, and prev_length >= 1
-- OUT assertion: the match length is not greater than s->lookahead.
function longest_match(s, cur_match)
	local window = s.window
	local chain_length = s.max_chain_length  -- max hash chain length

	-- zlib.js: scan -> window[scan], match -> window[match]
	local scan = s.strstart          -- current string
	local match                      -- matched string

	local len                        -- length of current match
	local best_len = s.prev_length   -- best match length so far
	local nice_match = s.nice_match  -- stop if match long enough
	local limit = 0
	if (s.strstart > MAX_DIST(s)) then
		limit = s.strstart - MAX_DIST(s)
	end
	-- Stop when cur_match becomes <= limit. To simplify the code, we prevent matches with the string of window index 0.
	local prev = s.prev
	local wmask = s.w_mask

	-- zlib.js: strend -> window[strend]
	local strend = s.strstart + MAX_MATCH
	local scan_end1  = window[scan+best_len-1]
	local scan_end   = window[scan+best_len]

	-- The code is optimized for HASH_BITS >= 8 and MAX_MATCH-2 multiple of 16.
	-- It is easy to get rid of this optimization if necessary.
	assert(s.hash_bits >= 8 and MAX_MATCH == 258, "Code too clever")

	-- Do not waste too much time if we already have a good match:
	if (s.prev_length >= s.good_match) then
		chain_length = rshift(chain_length, 2)
	end
	-- Do not look for matches beyond the end of the input. This is necessary to make deflate deterministic.
	if (nice_match > s.lookahead) then nice_match = s.lookahead end

	assert(s.strstart <= s.window_size-MIN_LOOKAHEAD, "need lookahead")

	repeat
		assert(cur_match < s.strstart, "no future")
		match = cur_match

		-- Skip to next match if the match length cannot increase or if the match length is less than 2.  Note that the checks below for insufficient lookahead only occur occasionally for performance reasons.  Therefore uninitialized memory will be accessed, and conditional jumps will be made that depend on those values. However the length of the match is limited to the lookahead, so the output of deflate is not affected by the uninitialized values.
		if (window[match+best_len] ~= scan_end
			or window[match+best_len-1] ~= scan_end1
			or window[match] ~= window[scan]
			or window[match+1] ~= window[scan+1]) then
			match = match + 1
			-- continue
		else
			match = match + 1

			-- The check at best_len-1 can be removed because it will be made again later. (This heuristic is not always a win.)
			-- It is not necessary to compare scan[2] and match[2] since they are always equal when the other bytes match, given that the hash keys are equal and that HASH_BITS >= 8.
			scan = scan + 2; match = match + 1
			assert(window[scan] == window[match], "match[2]?")
	
			-- We check for insufficient lookahead only every 8th comparison; the 256th check will be made at strstart+258.
			while (scan < strend) do
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
				scan = scan + 1; match = match + 1; if (window[scan] ~= window[match]) then break end
			end
	
			--Assert(scan <= s->window+(unsigned)(s->window_size-1), "wild scan");
	
			len = MAX_MATCH - (strend - scan)
			scan = strend - MAX_MATCH
	
			if (len > best_len) then
				s.match_start = cur_match
				best_len = len
				if (len >= nice_match) then break end
				scan_end1 = window[scan+best_len-1]
				scan_end = window[scan+best_len]
			end
		end

		cur_match = prev[band(cur_match, wmask)]
		chain_length = chain_length - 1
	until (cur_match <= limit or chain_length == 0)

	if (best_len <= s.lookahead) then return best_len end
	return s.lookahead
end

-- Check that the match at match_start is indeed a match.
function check_match(s, start, match, length) end

-- Fill the window when the lookahead becomes insufficient.
-- Updates strstart and lookahead.
-- IN assertion: lookahead < MIN_LOOKAHEAD
-- OUT assertions: strstart <= window_size-MIN_LOOKAHEAD
-- At least one byte has been read, or avail_in == 0; reads are performed for at least two bytes (required for the zip translate_eol option -- not supported here).
function fill_window(s)
	local n, m
	local p, ary  -- Posf *
	local more  -- Amount of free space at the end of the window.
	local wsize = s.w_size

	assert(s.lookahead < MIN_LOOKAHEAD, "already enough lookahead")

	repeat
		more = s.window_size - s.lookahead - s.strstart

		-- If the window is almost full and there is insufficient lookahead, move the upper half to the lower one to make room in the upper half.
		if (s.strstart >= wsize+MAX_DIST(s)) then

			for i = 0, wsize-1 do s.window[i] = s.window[wsize + i] end
			s.match_start = s.match_start - wsize
			s.strstart = s.strstart - wsize  -- we now have strstart >= MAX_DIST
			s.block_start = s.block_start - wsize

			-- Slide the hash table (could be avoided with 32 bit values at the expense of memory usage). We slide even when level == 0 to keep the hash table consistent if we switch back to level > 0 later. (Using level 0 permanently is not an optimal usage of zlib, so we don't care about this pathological case.)
			n = s.hash_size
			-- p = &s->head[n];
			ary = s.head
			p = n
			repeat
				p = p - 1
				m = ary[p]
				if (m >= wsize) then ary[p] = m-wsize else ary[p] = 0 end
				n = n - 1
			until (n == 0)

			n = wsize
			-- p = &s->prev[n];
			ary = s.prev
			p = n
			repeat
				p = p - 1
				m = ary[p]
				if (m >= wsize) then ary[p] = m-wsize else ary[p] = 0 end
				-- If n is not on any hash chain, prev[n] is garbage but its value will never be used.
				n = n - 1
			until (n == 0)

			more = more + wsize
		end
		if (s.strm.avail_in == 0) then break end

		-- If there was no sliding:
		-- strstart <= WSIZE+MAX_DIST-1 && lookahead <= MIN_LOOKAHEAD - 1 && more == window_size - lookahead - strstart => more >= window_size - (MIN_LOOKAHEAD-1 + WSIZE + MAX_DIST-1) => more >= window_size - 2*WSIZE + 2
		-- In the BIG_MEM or MMAP case (not yet supported),
		-- window_size == input_size + MIN_LOOKAHEAD && strstart + s->lookahead <= input_size => more >= MIN_LOOKAHEAD.
		-- Otherwise, window_size == 2*WSIZE so more >= 2.
		-- If there was sliding, more >= WSIZE. So in all cases, more >= 2.
		assert(more >= 2, "more < 2")

		n = read_buf(s.strm, s.window, s.strstart + s.lookahead, more)
		s.lookahead = s.lookahead + n

		-- Initialize the hash value now that we have some input:
		if (s.lookahead + s.insert >= MIN_MATCH) then
			local str = s.strstart - s.insert
			s.ins_h = s.window[str]
			UPDATE_HASH(s, s.window[str + 1])

			while (s.insert > 0) do
				UPDATE_HASH(s, s.window[str + MIN_MATCH-1])
				s.prev[band(str, s.w_mask)] = s.head[s.ins_h]
				s.head[s.ins_h] = str
				str = str + 1
				s.insert = s.insert - 1
				if (s.lookahead + s.insert < MIN_MATCH) then
					break
				end
			end
		end
		-- If the whole input has less than MIN_MATCH bytes, ins_h is garbage, but this is not important since only literal bytes will be emitted.

	until (s.lookahead >= MIN_LOOKAHEAD or s.strm.avail_in == 0)

	-- If the WIN_INIT bytes after the end of the current data have never been written, then zero those bytes in order to avoid memory check reports of the use of uninitialized (or uninitialised as Julian writes) bytes by the longest match routines.  Update the high water mark for the next time through here.  WIN_INIT is set to MAX_MATCH since the longest match routines allow scanning to strstart + MAX_MATCH, ignoring lookahead.
	if (s.high_water < s.window_size) then
		local curr = s.strstart + s.lookahead
		local init

		if (s.high_water < curr) then
			-- Previous high water mark below current data -- zero WIN_INIT bytes or up to end of window, whichever is less.
			init = s.window_size - curr
			if (init > WIN_INIT) then
				init = WIN_INIT
			end
			for i = 0, init-1 do s.window[i + curr] = 0 end
			s.high_water = curr + init
		elseif (s.high_water < curr + WIN_INIT) then
			-- High water mark at or above current data, but below current data plus WIN_INIT -- zero out to current data plus WIN_INIT, or up to end of window, whichever is less.
			init = curr + WIN_INIT - s.high_water
			if (init > s.window_size - s.high_water) then
				init = s.window_size - s.high_water
			end
			for i = 0, init-1 do s.window[s.high_water + i] = 0 end
			s.high_water = s.high_water + init
		end
	end

	assert(s.strstart <= s.window_size - MIN_LOOKAHEAD,
		   "not enough room for search")
end

-- Flush the current block, with given end-of-file flag.
-- IN assertion: strstart is set to the end of the current match.
function FLUSH_BLOCK_ONLY(s, last)
	local buf = nil
	if (s.block_start >= 0) then
		buf = s.block_start
	end
	_tr_flush_block(s, buf, s.strstart - s.block_start, last)
	s.block_start = s.strstart
	flush_pending(s.strm)
	--Tracev((stderr,"[FLUSH]"));
end

-- Copy without compression as much as possible from the input stream, return the current block state.
-- This function does not insert new strings in the dictionary since uncompressible data is probably not useful. This function is used only for the level=0 compression option.
-- NOTE: this function should be optimized to avoid extra copying from window to pending_buf.
function deflate_stored(s, flush)
	-- Stored blocks are limited to 0xffff bytes, pending_buf is limited to pending_buf_size, and each stored block has a 5 byte header:
	local max_block_size = 0xffff
	local max_start

	if (max_block_size > s.pending_buf_size - 5) then
		max_block_size = s.pending_buf_size - 5
	end

	-- Copy as much as possible from input to output:
	while (true) do
		-- Fill the window as much as possible:
		if (s.lookahead <= 1) then

			assert(s.strstart < s.w_size+MAX_DIST(s)
				or s.block_start >= s.w_size, "slide too late")

			fill_window(s)
			if (s.lookahead == 0 and flush == ZLIB.Z_NO_FLUSH) then return need_more end

			if (s.lookahead == 0) then break end  -- flush the current block
		end
		assert(s.block_start >= 0, "block gone")

		s.strstart = s.strstart + s.lookahead
		s.lookahead = 0

		-- Emit a stored block if pending_buf will be full:
		max_start = s.block_start + max_block_size
		if (s.strstart == 0 or s.strstart >= max_start) then
			-- strstart == 0 is possible when wraparound on 16-bit machine
			s.lookahead = s.strstart - max_start
			s.strstart = max_start
			FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
		end
		-- Flush if we may have to slide, otherwise block_start may become negative and the data will be gone:
		if (s.strstart - s.block_start >= MAX_DIST(s)) then
			FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
		end
	end
	s.insert = 0
	if (flush == ZLIB.Z_FINISH) then
		FLUSH_BLOCK_ONLY(s, 1); if (s.strm.avail_out == 0) then return finish_started end
		return finish_done
	end
	if (s.strstart > s.block_start) then
		FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
	end
	return block_done
end

-- Compress as much as possible from the input stream, return the current block state.
-- This function does not perform lazy evaluation of matches and inserts new strings in the dictionary only for unmatched strings or for short matches. It is used only for the fast compression options.
function deflate_fast(s, flush)
	local hash_head  -- head of the hash chain
	local bflush     -- set if current block must be flushed

	while (true) do
		-- Make sure that we always have enough lookahead, except at the end of the input file. We need MAX_MATCH bytes for the next match, plus MIN_MATCH bytes to insert the string following the next match.
		if (s.lookahead < MIN_LOOKAHEAD) then
			fill_window(s)
			if (s.lookahead < MIN_LOOKAHEAD and flush == ZLIB.Z_NO_FLUSH) then
				return need_more
			end
			if (s.lookahead == 0) then break end  -- flush the current block
		end

		-- Insert the string window[strstart .. strstart+2] in the dictionary, and set hash_head to the head of the hash chain:
		hash_head = 0
		if (s.lookahead >= MIN_MATCH) then
			hash_head = INSERT_STRING(s)
		end

		-- Find the longest match, discarding those <= prev_length.
		-- At this point we have always match_length < MIN_MATCH
		if (hash_head ~= 0 and s.strstart - hash_head <= MAX_DIST(s)) then
			-- To simplify the code, we prevent matches with the string of window index 0 (in particular we have to avoid a match of the string with itself at the start of the input file).
			s.match_length = longest_match(s, hash_head)
			-- longest_match() sets match_start
		end
		if (s.match_length >= MIN_MATCH) then
			check_match(s, s.strstart, s.match_start, s.match_length)

			bflush = _tr_tally_dist(s, s.strstart - s.match_start, s.match_length - MIN_MATCH)

			s.lookahead = s.lookahead - s.match_length

			-- Insert new strings in the hash table only if the match length is not too large. This saves time but degrades compression.
			if (s.match_length <= s.max_insert_length and s.lookahead >= MIN_MATCH) then
				s.match_length = s.match_length - 1  -- string at strstart already in table
				repeat
					s.strstart = s.strstart + 1
					hash_head = INSERT_STRING(s)
					-- strstart never exceeds WSIZE-MAX_MATCH, so there are always MIN_MATCH bytes ahead.
					s.match_length = s.match_length - 1
				until (s.match_length == 0)
				s.strstart = s.strstart + 1
			else
				s.strstart = s.strstart + s.match_length
				s.match_length = 0
				s.ins_h = s.window[s.strstart]
				UPDATE_HASH(s, s.window[s.strstart+1])
				-- If lookahead < MIN_MATCH, ins_h is garbage, but it does not matter since it will be recomputed at next deflate call.
			end
		else
			-- No match, output a literal byte
			--Tracevv((stderr,"%c", s->window[s->strstart]));
			bflush = _tr_tally_lit (s, s.window[s.strstart])
			s.lookahead = s.lookahead - 1
			s.strstart = s.strstart + 1
		end
		if (bflush) then
			FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
		end
	end
	if (s.strstart < MIN_MATCH-1) then s.insert = s.strstart else s.insert = MIN_MATCH-1 end
	if (flush == ZLIB.Z_FINISH) then
		FLUSH_BLOCK_ONLY(s, 1); if (s.strm.avail_out == 0) then return finish_started end
		return finish_done
	end
	if (s.last_lit ~= 0) then
		FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
	end
	return block_done
end

-- Same as above, but achieves better compression. We use a lazy evaluation for matches: a match is finally adopted only if there is no better match at the next window position.
function deflate_slow(s, flush)
	local hash_head  -- head of hash chain
	local bflush     -- set if current block must be flushed

	-- Process the input block.
	while (true) do
		-- Make sure that we always have enough lookahead, except at the end of the input file. We need MAX_MATCH bytes for the next match, plus MIN_MATCH bytes to insert the string following the next match.
		if (s.lookahead < MIN_LOOKAHEAD) then
			fill_window(s)
			if (s.lookahead < MIN_LOOKAHEAD and flush == ZLIB.Z_NO_FLUSH) then
				return need_more
			end
			if (s.lookahead == 0) then break end  -- flush the current block
		end

		-- Insert the string window[strstart .. strstart+2] in the dictionary, and set hash_head to the head of the hash chain:
		hash_head = 0
		if (s.lookahead >= MIN_MATCH) then
			hash_head = INSERT_STRING(s)
		end

		-- Find the longest match, discarding those <= prev_length.
		s.prev_length = s.match_length; s.prev_match = s.match_start
		s.match_length = MIN_MATCH-1

		if (hash_head ~= 0 and s.prev_length < s.max_lazy_match
			and s.strstart - hash_head <= MAX_DIST(s)) then
			-- To simplify the code, we prevent matches with the string of window index 0 (in particular we have to avoid a match of the string with itself at the start of the input file).
			s.match_length = longest_match(s, hash_head)
			-- longest_match() sets match_start

			if (s.match_length <= 5 and
				(s.strategy == ZLIB.Z_FILTERED
					or (s.match_length == MIN_MATCH and s.strstart - s.match_start > TOO_FAR)
				)
			) then
				-- If prev_match is also MIN_MATCH, match_start is garbage but we will ignore the current match anyway.
				s.match_length = MIN_MATCH-1
			end
		end

		-- If there was a match at the previous step and the current match is not better, output the previous match:
		if (s.prev_length >= MIN_MATCH and s.match_length <= s.prev_length) then
			local max_insert = s.strstart + s.lookahead - MIN_MATCH
			-- Do not insert strings in hash table beyond this.

			check_match(s, s.strstart-1, s.prev_match, s.prev_length)

			bflush = _tr_tally_dist(s, s.strstart-1 - s.prev_match, s.prev_length - MIN_MATCH)

			-- Insert in hash table all strings up to the end of the match. 
			-- strstart-1 and strstart are already inserted. If there is not enough lookahead, the last two strings are not inserted in the hash table.
			s.lookahead = s.lookahead - (s.prev_length-1)
			s.prev_length = s.prev_length - 2
			repeat
				s.strstart = s.strstart + 1
				if (s.strstart <= max_insert) then
					hash_head = INSERT_STRING(s)
				end
				s.prev_length = s.prev_length - 1
			until (s.prev_length == 0)
			s.match_available = false
			s.match_length = MIN_MATCH-1
			s.strstart = s.strstart + 1

			if (bflush) then
				FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
			end

		elseif (s.match_available) then
			-- If there was no match at the previous position, output a single literal. If there was a match but the current match is longer, truncate the previous match to a single literal.
			--Tracevv((stderr,"%c", s->window[s->strstart-1]));
			bflush = _tr_tally_lit(s, s.window[s.strstart-1])
			if (bflush) then
				FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
			end
			s.strstart = s.strstart + 1
			s.lookahead = s.lookahead - 1
			if (s.strm.avail_out == 0) then return need_more end
		else
			-- There is no previous match to compare with, wait for the next step to decide.
			s.match_available = true
			s.strstart = s.strstart + 1
			s.lookahead = s.lookahead - 1
		end

	end
	--assert (flush ~= Z_NO_FLUSH, "no flush?")
	if (s.match_available) then
		--Tracevv((stderr,"%c", s->window[s->strstart-1]));
		bflush = _tr_tally_lit(s, s.window[s.strstart-1])
		s.match_available = false
	end
	if (s.strstart < MIN_MATCH-1) then s.insert = s.strstart else s.insert = MIN_MATCH-1 end
	if (flush == ZLIB.Z_FINISH) then
		FLUSH_BLOCK_ONLY(s, 1); if (s.strm.avail_out == 0) then return finish_started end
		return finish_done
	end
	if (s.last_lit ~= 0) then
		FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
	end
	return block_done
end

-- For Z_RLE, simply look for runs of bytes, generate matches only of distance one.  Do not maintain a hash table.  (It will be regenerated if this run of deflate switches away from Z_RLE.)
function deflate_rle(s, flush)
	local bflush        -- set if current block must be flushed
	local prev          -- byte at distance one to match
	-- window[scan], window[strend]
	local scan, strend  -- scan goes up to strend for length of run
	local window = s.window

	while (true) do
		-- Make sure that we always have enough lookahead, except at the end of the input file. We need MAX_MATCH bytes for the longest run, plus one for the unrolled loop.
		if (s.lookahead <= MAX_MATCH) then
			fill_window(s)
			if (s.lookahead <= MAX_MATCH and flush == ZLIB.Z_NO_FLUSH) then
				return need_more
			end
			if (s.lookahead == 0) then break end  -- flush the current block
		end

		-- See how many times the previous byte repeats
		s.match_length = 0
		if (s.lookahead >= MIN_MATCH and s.strstart > 0) then
			scan = s.strstart - 1
			prev = window[scan]
			if (prev == window[scan+1] and prev == window[scan+2] and prev == window[scan+3]) then
				scan = scan + 3
				strend = s.strstart + MAX_MATCH
				while (scan < strend) do
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
					scan = scan + 1; if (prev ~= window[scan]) then break end
				end
				s.match_length = MAX_MATCH - (strend - scan)
				if (s.match_length > s.lookahead) then
					s.match_length = s.lookahead
				end
			end
			--Assert(scan <= s->window+(uInt)(s->window_size-1), "wild scan");
		end

		-- Emit match if have run of MIN_MATCH or longer, else emit literal
		if (s.match_length >= MIN_MATCH) then
			check_match(s, s.strstart, s.strstart - 1, s.match_length)

			bflush = _tr_tally_dist(s, 1, s.match_length - MIN_MATCH)

			s.lookahead = s.lookahead - s.match_length
			s.strstart = s.strstart + s.match_length
			s.match_length = 0
		else
			-- No match, output a literal byte
			--Tracevv((stderr,"%c", s->window[s->strstart]));
			bflush = _tr_tally_lit (s, s.window[s.strstart])
			s.lookahead = s.lookahead - 1
			s.strstart = s.strstart + 1
		end
		if (bflush) then
			FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
		end
	end
	s.insert = 0
	if (flush == ZLIB.Z_FINISH) then
		FLUSH_BLOCK_ONLY(s, 1); if (s.strm.avail_out == 0) then return finish_started end
		return finish_done
	end
	if (s.last_lit ~= 0) then
		FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
	end
	return block_done
end

-- For Z_HUFFMAN_ONLY, do not look for matches.  Do not maintain a hash table. (It will be regenerated if this run of deflate switches away from Huffman.)
function deflate_huff(s, flush)
	local bflush  -- set if current block must be flushed

	while (true) do
		-- Make sure that we have a literal to write.
		if (s.lookahead == 0) then
			fill_window(s)
			if (s.lookahead == 0) then
				if (flush == ZLIB.Z_NO_FLUSH) then
					return need_more
				end
				break  -- flush the current block
			end
		end

		-- Output a literal byte
		s.match_length = 0
		--Tracevv((stderr,"%c", s->window[s->strstart]));
		bflush = _tr_tally_lit (s, s.window[s.strstart])
		s.lookahead = s.lookahead - 1
		s.strstart = s.strstart + 1
		if (bflush) then
			FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
		end
	end
	s.insert = 0
	if (flush == ZLIB.Z_FINISH) then
		FLUSH_BLOCK_ONLY(s, 1); if (s.strm.avail_out == 0) then return finish_started end
		return finish_done
	end
	if (s.last_lit ~= 0) then
		FLUSH_BLOCK_ONLY(s, 0); if (s.strm.avail_out == 0) then return need_more end
	end
	return block_done
end


-- ===========================================================================
-- Public API

local M = {}

M.deflate = function(input_string, opts)
	local DEFAULT_BUFFER_SIZE = 4000000000 -- 4 GB

	local this = ZLIB.deflateInit(opts)
	this.input_data = input_string
	this.next_in = getarg(opts, 'next_in', 0)
	this.avail_in = getarg(opts, 'avail_in', input_string:len() - this.next_in)

	local flush = getarg(opts, 'flush', ZLIB.Z_SYNC_FLUSH)
	local avail_out = getarg(opts, 'avail_out', -1)

	local result = ''
	repeat
		if (avail_out >= 0) then
			this.avail_out = avail_out
		else
			this.avail_out = DEFAULT_BUFFER_SIZE
		end
		this.output_data = ''
		this.next_out = 0
		this.error = ZLIB.deflate(this, flush)
		if (avail_out >= 0) then
			return this.output_data
		end
		result = result .. this.output_data
		if (this.avail_out > 0) then
			break
		end
	until (this.error ~= ZLIB.Z_OK)

	return result
end

M.gzip = function(input_string, opts)
	if (not opts or type(opts) ~= 'table') then opts = {} end
	opts.windowBits = 15 + 16
	opts.flush = ZLIB.Z_FINISH
	return M.deflate(input_string, opts)
end

return M
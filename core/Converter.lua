local inflate = require "lib.deflatelua"
local deflate = require "lib.zlib-deflate"
local base64 = require "lib.base64"

---
-- Description of the module.
-- @module Converter
--
local Converter = {
  -- single-line comment
  classname = "HMConverter",
  -- use gzip
  compressed = true,
  -- length of line
  line_length = 120
}

-------------------------------------------------------------------------------
-- Trim string
--
-- @function [parent=#Converter] trim
--
-- @param #string s
--
-- @return #string
--
function Converter.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


-------------------------------------------------------------------------------
-- Write table to string
--
-- @function [parent=#Converter] write
--
-- @param #table data_table
--
-- @return #string
--
function Converter.write(data_table)
  local data_string = serpent.dump(data_table)
  if (Converter.compressed) then
    data_string = deflate.gzip(data_string)
    data_string = base64.enc(data_string)
    if (Converter.line_length > 0) then
      -- Add line breaks
      data_string = data_string:gsub( ("%S"):rep(Converter.line_length), "%1\n" )
    end
  end
  data_string = data_string .. "\n"
  return data_string
end

-------------------------------------------------------------------------------
-- Read string to table
--
-- @function [parent=#Converter] read
--
-- @param #string data_string
--
-- @return #table
--
function Converter.read(data_string)
  Logging:debug(Converter.classname, "data_string",data_string)
  if data_string == nil then return nil end
  data_string = Converter.trim(data_string)
  if (string.sub(data_string, 1, 8) ~= "do local") then
    local input = base64.dec(data_string)
    local data_table = {}
    local output = {}
    local status, result = pcall(inflate.gunzip, { input = input, output = function(byte) output[#output+1] = string.char(byte) end })
    Logging:debug(Converter.classname, "status, result",status, result)
    if (status) then
      data_string = table.concat(output)
    else
      return nil
    end
  end
  local status, data_table = pcall(loadstring, data_string)
  if (status) then
    return data_table()
  end
  return nil
end

return Converter

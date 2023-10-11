local bin = require 'bin'

local revx2 = { DEBUG = false }

function revx2.header_parse_global(buf)
    local magic_1 = buf:i32be(4)
    local slices = buf:i32be(4)
    buf:skip(1) -- unused byte
    local bars = buf:u8(1)
    local plus_beats = buf:u8(1)
    local beats_bar = buf:u8(1)
    local beats_type = buf:u8(1)
    
    buf:skip(7) -- offset to BPM
    local tempo = buf:i32be(4) / 1000.0
    
    if revx2.DEBUG then print(string.format("Global - Magic 1: %d Slices: %d Tempo: %2.2f BPM Bars: %d + %d beats in %d/%d", magic_1, slices, tempo, bars, plus_beats, beats_bar, beats_type)) end
    return slices, tempo, bars, plus_beats, beats_bar, beats_type
end

function revx2.header_parse_slice(buf)
    local magic_1 = buf:i32be(4)
    local start = buf:i32be(4)
    local length = buf:i32be(4)
    local magic_2 = buf:i32be(4)
    
    if revx2.DEBUG then print(string.format("Slice - Magic 1: %d Start: %d Length: %d Magic 2: 0x%X", magic_1, start, length, magic_2)) end
    if length > 1 then
        return start, length
    else
        return nil, nil
    end
end

function revx2.skip_after_pattern(buf, pat, deadline)
	local cur = buf:str(#pat)
	local i = #pat
	while cur ~= pat do
		-- print(i, bin.xd(cur))
		buf:skip(-(#pat-1))
		i = i - (#pat-1)
		cur = buf:str(#pat)
		i = i + #pat
		if ((deadline ~= nil) and (i >= deadline)) then
			return nil, i
		end
	end
	if cur == pat then return cur, i
	else return nil, i end
end

function revx2.parse_file(filename)
    local rx2_file = io.open(filename)
    local rx2_data = rx2_file:read("*a")
    local rx2_buf = bin.rbuf(rx2_data)
	local rx2_buf_len = tonumber(rx2_buf.len)
	local rx2_buf_pos = 0
	if string.find(rx2_buf:str(16), "REX2HEAD") == nil then
		error("Not a REX2 file.")
	end
	if revx2.DEBUG then print(string.format("File size: %d", rx2_buf_len)) end
	rx2_buf:skip(-16)
	local status, meta_len = revx2.skip_after_pattern(rx2_buf, "SDAT")
	if status == nil then
		error("Parsing error. Aborting.")
	end
	if revx2.DEBUG then print(string.format("Metadata size: %d", meta_len)) end
	rx2_buf:skip(-meta_len)
	local status, read = revx2.skip_after_pattern(rx2_buf, "GLOB\x00\x00\x00\x16", meta_len)
	if status == nil then
		error("Parsing error. Aborting.")
	end
	rx2_buf:skip(-4)
	rx2_buf_pos = read - 4
	
    local slices, tempo, bars, plus_beats, beats_bar, beats_type = revx2.header_parse_global(rx2_buf)
    local rx2_info = {
        rx2path = j,
        slices = slices,
        tempo =  tempo,
        bars = bars,
        plus_beats = plus_beats,
        beats_bar = beats_bar,
        beats_type = beats_type,
        slices_list = {}
    }
	rx2_buf_pos = rx2_buf_pos + 24 -- header_parse_global reads 24 bytes
	status, read = revx2.skip_after_pattern(rx2_buf, "SLCLSLCE", rx2_buf_len - rx2_buf_pos)
	if status == nil then
		error("Parsing error. Aborting.")
	end
	rx2_buf_pos = rx2_buf_pos + read
    for i = 1, slices do
        if revx2.DEBUG then io.write(i .. " ") end
        local start, length = revx2.header_parse_slice(rx2_buf)
        if start ~= nil then
            table.insert(rx2_info.slices_list, {start = start, length = length})
        end
        rx2_buf:skip(4) -- offset to next SLCE
		rx2_buf_pos = rx2_buf_pos + 20 -- header_parse_slice reads 16 bytes + 4 to skip next SLCE
    end
    rx2_info["effective_slices"] = #rx2_info.slices_list -- Slices with length > 1
    rx2_file:close()
    
    return rx2_info
end

return revx2
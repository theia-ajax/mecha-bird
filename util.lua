function file_exists(filename)
	local f = io.open(filename, "r")
	if f then f:close() end
	return f ~= nil
end

function lines_from_file(filename)
	if not file_exists(filename) then return nil end

	local lines = {}
	for line in io.lines(filename) do
		lines[#lines + 1] = line
	end

	return lines
end

function split_str(str, delimeter)
	local result = {}
	local fpat = "(.-)" .. delimeter
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(result, cap)
		end
		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(result, cap)
	end
	return result
end
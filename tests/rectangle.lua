function arrange()
end

function assert()
    -- switch to text matrix
    write_byte(1, 2)
    res = read_byte(0xC000) == 160
    res = res and (read_byte(0xC001) == 161)
    res = res and (read_byte(0xC000 + 80) == 162)
    res = res and (read_byte(0xC001 + 80) == 163)
    -- switch to colour matrix
    write_byte(1, 3)
    res = res and (read_byte(0xC000) == 0xAF)
    res = res and (read_byte(0xC001) == 0xAF)
    res = res and (read_byte(0xC000 + 80) == 0xAF)
    res = res and (read_byte(0xC001 + 80) == 0xAF)
    return res, "Unexpected values"
end
function arrange()
end

function get_char_at(x, y)
    return read_byte(y*80 + x + 0xC000)
end

function assert()
    -- switch to text matrix
    write_byte(1, 2)
    res =          get_char_at(1, 1) == 160
    res = res and (get_char_at(2, 1) == 150)
    res = res and (get_char_at(3, 1) == 161)

    res = res and (get_char_at(1, 2) == 130)
    res = res and (get_char_at(3, 2) == 130)

    res = res and (get_char_at(1, 3) == 162)
    res = res and (get_char_at(2, 3) == 150)
    res = res and (get_char_at(3, 3) == 163)
    return res, "Unexpected values"
end
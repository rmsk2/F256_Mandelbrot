require(test_dir .. "tools")

test_data = {
    [1] = {x = 76, y = 52},
    [2] = {x = 0, y = 0},
    [3] = {x = 43, y = 21},
    [4] = {x = 79, y = 59},
}

function num_iterations() 
    return #test_data
end

iter_count = 0

function arrange()
    iter_count = iter_count + 1
    restart()
    set_yreg(test_data[iter_count].y)
    set_xreg(test_data[iter_count].x)
end

function assert()
    in_x = test_data[iter_count].x
    in_y = test_data[iter_count].y
    res = (read_byte(load_address+4) * 256) + read_byte(load_address+3)
    ref_val = in_y * 80 + in_x
    
    return res == ref_val, string.format("Unexpected value: (%d * 80) + %d is not %d. Should be %d", in_y, in_x, res, ref_val)
end
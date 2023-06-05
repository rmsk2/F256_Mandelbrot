test_data = {
    [1] = {x = 1, z = 0, y = "30"},
    [2] = {x = 2, z = 15, y = "3135"},
    [3] = {x = 3, z = 255, y = "323535"},
}

function arrange()
    iter_count = iter_count + 1
    set_pc(load_address)
    set_accu(test_data[iter_count].z)
end

function num_iterations()
    return #test_data
end

iter_count = 0

function assert()
    accu = get_accu()
    if (accu ~= test_data[iter_count].x) then
        return false, "Wrong length"
    end

    if  (get_memory(load_address + 4, test_data[iter_count].x) ~= test_data[iter_count].y) then
        return false, "Wrong conversion data"
    end

    return true, ""
end
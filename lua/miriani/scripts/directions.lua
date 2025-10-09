local function calculate2d(you, target)
    local tx, ty = tonumber(target.x), tonumber(target.y)
    local yx, yy = tonumber(you.x), tonumber(you.y)
    local dx, dy = tx - yx, ty - yy
    local dxa, dya = math.abs(dx), math.abs(dy)
    local distance = math.max(dxa, dya)
    local dir = {}

    if distance > 0 then
        if dx ~= 0 then table.insert(dir, (distance > 1 and dxa or '') .. (dx > 0 and 'E' or 'W')) end
        if dy ~= 0 then table.insert(dir, (distance > 1 and dya or '') .. (dy > 0 and 'S' or 'N')) end
    else
        table.insert(dir, 'Here')
    end

    return { dx = dx, dy = dy, dir = table.concat(dir, ' '), distance = distance }
end

local function calculate3d(you, target)
    local tx, ty, tz = tonumber(target.x), tonumber(target.y), tonumber(target.z)
    local yx, yy, yz = tonumber(you.x), tonumber(you.y), tonumber(you.z)
    local dx, dy, dz = tx - yx, ty - yy, tz - yz
    local dxa, dya, dza = math.abs(dx), math.abs(dy), math.abs(dz)
    local distance = math.max(dxa, dya, dza)
    local dir = {}

    if distance > 0 then
        if dx ~= 0 then table.insert(dir, (distance > 1 and dxa or '') .. (dx > 0 and 'E' or 'W')) end
        if dy ~= 0 then table.insert(dir, (distance > 1 and dya or '') .. (dy > 0 and 'S' or 'N')) end
        if dz ~= 0 then table.insert(dir, (distance > 1 and dza or '') .. (dz > 0 and 'D' or 'U')) end
    else
        table.insert(dir, 'Here')
    end

    return { dx = dx, dy = dy, dz = dz, dir = table.concat(dir, ' '), distance = distance }
end

local function here2d(first, second)
    return first.x == second.x and first.y == second.y
end

local function here3d(first, second)
    return first.x == second.x and first.y == second.y and first.z == second.z
end

return {
    calculate2d = calculate2d,
    calculate3d = calculate3d,
    here2d = here2d,
    here3d = here3d
}

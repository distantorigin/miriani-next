function calculate_direction(you, target, separator)
  separator = separator or " "
  local dx = target.x - you.x
  local dy = target.y - you.y
  local dz = (target.z or 0) - (you.z or 0)
  local dxa, dya, dza = math.abs(dx), math.abs(dy), math.abs(dz)
  local dir = {}
  if dx ~= 0 then table.insert(dir, string.format("%d%s", dxa, dx > 0 and "E" or "W")) end
  if dy ~= 0 then table.insert(dir, string.format("%d%s", dya, dy > 0 and "S" or "N")) end
  if dz ~= 0 then table.insert(dir, string.format("%d%s", dza, dz > 0 and "D" or "U")) end
  if #dir == 0 then return "Here" end
  return table.concat(dir, separator)
end

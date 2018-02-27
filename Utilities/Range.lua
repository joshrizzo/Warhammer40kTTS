function Range.distance(v1, v2)
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

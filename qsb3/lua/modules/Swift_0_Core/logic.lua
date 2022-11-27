--[[
Swift_0_Core/Logic

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

NOT = function(_ID, _Predicate)
    local Predicate = table.copy(_Predicate);
    local Function = table.remove(Predicate, 1);
    return not Function(_ID, unpack(Predicate));
end

XOR = function(_ID, ...)
    local Predicates = table.copy(arg);
    local Truths = 0;
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        Truths = Truths + ((Predicate(_ID, unpack(Predicates[i])) and 1) or 0);
    end
    return Truths == 1;
end

ALL = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if not Predicate(_ID, unpack(Predicates[i])) then
            return false;
        end
    end
    return true;
end

ANY = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if Predicate(_ID, unpack(Predicates[i])) then
            return true;
        end
    end
    return false;
end


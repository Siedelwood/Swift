---
-- A module to test the generated doc
-- @module ldoc-test
--

---
-- foo does nothing!
-- @param string _a just for show
--
function foo(_a)
end

---
-- bar does nothing!
-- @param string _a just for show
-- @param number _b hoh often it does nothing
-- @return boolean
--
function bar(_a, _b)
    for i= 1, _b, 1 do
    end
    return false
end
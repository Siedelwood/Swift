---
-- Heureka, it still works!
-- @within Modulbeschreibung
-- @set sort=false
--
SomeOtherCustomBundle = {};

---
-- This is another test
-- @within Anwenderfunktionen
--
function _bar()
end

SomeOtherCustomBundle = {
    Global = {},
    Local = {},
}

function SomeOtherCustomBundle.Global:Install()

end

function SomeOtherCustomBundle.Local:Install()

end

---
-- Heureka, it works!
-- @within Modulbeschreibung
-- @set sort=false
--
SomeCustomBundle = {};

---
-- This is just a test
-- @within Anwenderfunktionen
--
function _foo()
end

SomeCustomBundle = {
    Global = {},
    Local = {},
}

function SomeCustomBundle.Global:Install()

end

function SomeCustomBundle.Local:Install()

end

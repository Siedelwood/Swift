-- Test for reading the file system.
-- This lua implementation of the PHP function can read a folder for it's
-- contents and return them as table.

function scandir(_directory)
    local i, t, popen = 0, {}, io.popen
    
    local ls = 'ls -a "'.._directory..'"';
    local pfile = popen(ls)
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end


local files = scandir(".", true)
for i=1, #files, 1 do
    print(files[i]);
end
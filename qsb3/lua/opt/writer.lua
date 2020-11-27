OptWriter_ModuleFiles = {
    "Core/swift.lua",
    "Core/api.lua",
    "Core/debug.lua",
    "Core/behavior.lua",

    "ModuleJobs/source.lua",
    "ModuleJobs/api.lua",
    "ModuleTextTools/source.lua",
    "ModuleTextTools/api.lua",
    "ModuleRealtime/source.lua",
    "ModuleRealtime/api.lua",

    "Core/selfload.lua",
};

function OptWriter_LoadSource(_File)
    local fh = io.open("../modules/" .._File, "rt");
    if not fh then
        print("file not found: ../modules/" .._File);
        return "";
    end
    print("loading: ../modules/" .._File);
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

function OptWriter_ConcatSources()
    local Content = "";
    for i= 1, #OptWriter_ModuleFiles, 1 do
        Content = Content .. OptWriter_LoadSource(OptWriter_ModuleFiles[i]);
    end
    return Content;
end

function OptWriter_Write()
    local QsbContent = OptWriter_ConcatSources();
    local fh = io.open("../var/qsb.lua", "rt");
    if fh ~= nil then
        os.remove("../var/qsb.lua");
        fh:close();
    end
    local fh = io.open("../var/qsb.lua", "wt");
    assert(fh, "Output file can not be created!");
    print("write qsb to var");
    fh:write(QsbContent);
    fh:close();
end

OptWriter_Write();


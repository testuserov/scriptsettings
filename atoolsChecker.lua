script_name("atools_checker")

scripts = {}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end

    onSystemInitialized()
    while not isSampAvailable() do wait(100) end

    --> Added atools scripts
    local atools = { }
    for _, v in ipairs(scripts) do
        if v.name == "atools" then
            v.version = tonumber(v.version)
            v.size = getSizeFile(v.path)
            table.insert(atools, v)
        end
    end

    --> If atools scripts > 1, then delete low versions
    if #atools > 1 then
        local idScript = 1
        for id, scr in ipairs(atools) do
            print(scr.filename, scr.size)
            if scr.version > atools[idScript].version then
                -- print(string.format("delete version. ID: %s | Name: %s | Version: %s | Path: %s", idScript, atools[idScript].name, atools[idScript].version, atools[idScript].path))
                deleteScript(atools[idScript])
                table.remove(atools, idScript)
                idScript = id
            end
        end
    end

    --> If atools scripts > 1, then delete by size (bytes) below
    if #atools > 1 then
        local idScript = 1
        for id, scr in ipairs(atools) do
            if scr.size > atools[idScript].size then
                -- print(string.format("delete size. ID: %s | Name: %s | Version: %s | Path: %s", idScript, atools[idScript].name, atools[idScript].version, atools[idScript].path))
                deleteScript(atools[idScript])
                table.remove(atools, idScript)
                idScript = id
            end
        end
    end

    --> If atools scripts > 1, then delete all except one
    if #atools > 1 then
        for id, scr in ipairs(atools) do
            if id > 1 then
                -- print(string.format("delete eq. ID: %s | Name: %s | Version: %s | Path: %s", id, scr.name, scr.version, scr.path))
                table.remove(atools, id)
                deleteScript(scr)
            end
        end
    end
end

--> Events
function onSystemInitialized()
	if not initialized then
		loadScriptsList()
        initialized = true
	end
end

function onScriptLoad(script)
	local s = getScriptFromList(script)
	if s ~= nil then
		s:enable(script)
	else
		addScriptToList(script)
	end
end

function onScriptTerminate(script)
	local s = getScriptFromList(script)
	if s ~= nil then
		s:disable(script)
	end
end

--> Functions
function loadScriptsList()
	for _, it in ipairs(script.list()) do
		addScriptToList(it)
	end
end

function getScriptFromList(script)
	for _, it in pairs(scripts) do
		if it.path == script.path then
			return it
		end
	end
	return nil
end

function addScriptToList(script)
	local s = getScriptFromList(script)
	if s == nil then
		table.insert(scripts, Script:new(script))
	end
end

function deleteScript(script)
    local s = getScriptFromList(script)
    if s ~= nil then
        s:unload()
        os.remove(s.path)
    end
end

function getSizeFile(path)
    local file = io.open(path, "r")
    local s = file:seek()
    local res = file:seek("end")
    file:seek("set", s)
    file:close()
    return res
end

--> Class Script
Script = {}
function Script:new(script)
	local public = {}
		public.loaded = true

	function public:updateInfo(script)
		self.script = script
		self.name = script.name
		self.description = script.description
		self.version_num = script.version_num
		self.version = script.version
		self.authors = script.authors
		self.dependencies = script.dependencies
		self.path = script.path
		self.filename = script.filename
		self.directory = script.directory
		self.frozen = script.frozen
		self.dead = script.dead
	end

	function public:load()
		self:updateInfo(script.load(self.path))
	end

	function public:unload()
		self.script:unload()
	end

	function public:pause()
		self.script:pause()
		self.frozen = self.script.frozen
	end

	function public:resume()
		self.script:resume()
		self.frozen = self.script.frozen
	end

	function public:reload()
		self.script:reload()
	end

	function public:enable(script)
		if self.loaded ~= true then
			self:updateInfo(script)
		end
		self.loaded = true
	end

	function public:disable()
		self.loaded = false
	end

	public:updateInfo(script)
	setmetatable(public, self)
	self.__index = self
	return public
end
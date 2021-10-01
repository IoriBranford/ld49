local DataCache = {}
DataCache.__index = DataCache

function DataCache.new(root)
    root = root or './'
    local info = love.filesystem.getInfo(root, "directory")
    assert(info, string.format("Cannot use %s as data root. Does not exist or is not a directory.", root))
    if root[#root] ~= '/' then
        root = root..'/'
    end
    local assetcache = {
        root = root
    }
    return setmetatable(assetcache, DataCache)
end

function DataCache:load(loader, file, ...)
    local asset = loader(self.root..file, ...)
    self[file] = asset
    return asset
end

function DataCache:get(file)
    return self[file]
end

function DataCache:unload(file)
    self[file] = nil
end

function DataCache:clear()
    local root = self.root
    for k,_ in pairs(self) do
        self[k] = nil
    end
    self.root = root
end

return DataCache
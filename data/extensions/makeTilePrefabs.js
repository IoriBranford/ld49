/// <reference types="@mapeditor/tiled-api" />

const makePrefabsFromMapTilesets = (/** @type {TileMap} */ map, tileCondition) => {
    let layerDict = {}
    for (let i = 0; i < map.layerCount; ++i) {
        let layer = map.layerAt(i)
        layerDict[layer.name] = layer
    }
    let tilesets = map.tilesets
    let offsetx = 0
    let offsety = 0
    let spacing = map.tileWidth
    for (let tileset of tilesets) {
        let tilesetName = tileset.name
        let tileWidth = tileset.tileWidth
        let tileHeight = tileset.tileHeight

        let tiles = tileset.selectedTiles
        if (!tiles)
            tiles = tileset.tiles
        let columns = Math.floor(tileset.imageWidth / tileWidth)
        let tileoffset = tileset.tileOffset
        let prefabx = -tileoffset.x
        let prefaby = -tileoffset.y
        let prefabs = []
        for (let tile of tileset.tiles) {
            if (tileCondition && !tileCondition(tile))
                continue
            let id = tile.id
            let tileName = tile.property("name")
            if (!tileName)
                tileName = id.toString()
            tileName = tilesetName + '_' + tileName
            let prefab = new MapObject(tileName)
            prefab.x = prefabx
            prefab.y = prefaby
            prefab.width = tileWidth
            prefab.height = tileHeight
            prefab.tile = tile
            // convertProperties(prefab)
            prefab.removeProperty("name")
            // prefab.removeProperty("tileset")
            // prefab.removeProperty("tileid")
            prefabs.push(prefab)
            prefabx += tileWidth + spacing
        }

        if (prefabs.length <= 0)
            continue

        /** @type {ObjectGroup} */ let objectGroup = layerDict[tileset.name]
        let objectDict = {}
        if (objectGroup && objectGroup.isObjectLayer) {
            for (let i = 0; i < objectGroup.objectCount; ++i) {
                let object = objectGroup.objectAt(i)
                objectDict[object.name] = object
            }
        } else {
            objectGroup = new ObjectGroup(tileset.name)
            map.addLayer(objectGroup)
        }
        offsety += tileset.tileHeight
        objectGroup.offset = Qt.point(offsetx, offsety)
        offsety += map.tileHeight
        for (prefab of prefabs) {
            if (!objectDict[prefab.name])
                objectGroup.addObject(prefab)
        }
    }
}

const makePrefabsOfAllTilesAction = tiled.registerAction("makePrefabsOfAllTiles", (action) => {
    let map = tiled.activeAsset
    if (!map.isTileMap) {
        tiled.alert("Not a map!")
        return
    }
    map.macro("Make prefabs from tiles", () => {
        makePrefabsFromMapTilesets(map)
    })
})
makePrefabsOfAllTilesAction.text = "Make prefabs of all tiles"

const makePrefabsOfAnimatedOrNamedTilesAction = tiled.registerAction("makePrefabsOfAnimatedOrNamedTiles", (action) => {
    let map = tiled.activeAsset
    if (!map.isTileMap) {
        tiled.alert("Not a map!")
        return
    }
    map.macro("Make prefabs from tiles", () => {
        makePrefabsFromMapTilesets(map, function (/** @type {Tile}*/ tile) {
            return tile.property("name") || tile.animated
        })
    })
})
makePrefabsOfAnimatedOrNamedTilesAction.text = "Make prefabs of animated or named tiles"

tiled.extendMenu("Map", [
    { separator: true },
    { action: "makePrefabsOfAllTiles" },
    { action: "makePrefabsOfAnimatedOrNamedTiles" }
])
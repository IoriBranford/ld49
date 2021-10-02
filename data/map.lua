return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.7.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 100,
  height = 100,
  tilewidth = 65,
  tileheight = 89,
  nextlayerid = 3,
  nextobjectid = 21,
  properties = {},
  tilesets = {
    {
      name = "fullTiles",
      firstgid = 1,
      tilewidth = 65,
      tileheight = 89,
      spacing = 0,
      margin = 0,
      columns = 7,
      image = "fullTiles.png",
      imagewidth = 512,
      imageheight = 512,
      objectalignment = "center",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 65,
        height = 89
      },
      properties = {},
      wangsets = {},
      tilecount = 35,
      tiles = {
        {
          id = 7,
          objectGroup = {
            type = "objectgroup",
            draworder = "index",
            id = 2,
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 2,
                name = "",
                type = "",
                shape = "polygon",
                x = 32,
                y = 1,
                width = 0,
                height = 0,
                rotation = 0,
                visible = true,
                polygon = {
                  { x = 0, y = 0 },
                  { x = 1, y = 0 },
                  { x = 33, y = 16 },
                  { x = 33, y = 48 },
                  { x = 1, y = 63 },
                  { x = 0, y = 63 },
                  { x = -32, y = 48 },
                  { x = -32, y = 16 }
                },
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        }
      }
    },
    {
      name = "aliens",
      firstgid = 36,
      tilewidth = 40,
      tileheight = 66,
      spacing = 0,
      margin = 0,
      columns = 3,
      image = "aliens.png",
      imagewidth = 128,
      imageheight = 256,
      objectalignment = "center",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 40,
        height = 66
      },
      properties = {},
      wangsets = {},
      tilecount = 9,
      tiles = {
        {
          id = 0,
          objectGroup = {
            type = "objectgroup",
            draworder = "topdown",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 0,
                y = 13,
                width = 40,
                height = 40,
                rotation = 0,
                visible = true,
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        },
        {
          id = 1,
          objectGroup = {
            type = "objectgroup",
            draworder = "topdown",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 0,
                y = 13,
                width = 40,
                height = 40,
                rotation = 0,
                visible = true,
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        },
        {
          id = 3,
          objectGroup = {
            type = "objectgroup",
            draworder = "topdown",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 0,
                y = 13,
                width = 40,
                height = 40,
                rotation = 0,
                visible = true,
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        },
        {
          id = 4,
          objectGroup = {
            type = "objectgroup",
            draworder = "topdown",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 0,
                y = 13,
                width = 40,
                height = 40,
                rotation = 0,
                visible = true,
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        },
        {
          id = 6,
          objectGroup = {
            type = "objectgroup",
            draworder = "index",
            id = 2,
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            parallaxx = 1,
            parallaxy = 1,
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "ellipse",
                x = 0,
                y = 13,
                width = 40,
                height = 40,
                rotation = 0,
                visible = true,
                properties = {
                  ["collidable"] = true
                }
              }
            }
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      id = 1,
      name = "Tile Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      chunks = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "Object Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "text",
          x = 130,
          y = 89,
          width = 195,
          height = 44.5,
          rotation = 0,
          visible = true,
          text = "Hello World",
          fontfamily = "Verdana",
          wrap = true,
          color = { 255, 255, 255 },
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 195,
          y = 222.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 162.5,
          y = 267,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 195,
          y = 311.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 260,
          y = 222.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 227.5,
          y = 267,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 260,
          y = 311.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 325,
          y = 222.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 292.5,
          y = 267,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 325,
          y = 311.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 390,
          y = 222.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 357.5,
          y = 267,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 390,
          y = 311.5,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "",
          type = "HexBlock",
          shape = "rectangle",
          x = 422.5,
          y = 267,
          width = 65,
          height = 89,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "",
          type = "Ground",
          shape = "polyline",
          x = 32.5,
          y = 0,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polyline = {
            { x = 0, y = 0 },
            { x = 32.5, y = 89 },
            { x = 32.5, y = 178 },
            { x = 65, y = 267 },
            { x = 65, y = 356 },
            { x = 162.5, y = 400.5 },
            { x = 422.5, y = 400.5 },
            { x = 520, y = 311.5 },
            { x = 552.5, y = 222.5 },
            { x = 585, y = 89 },
            { x = 617.5, y = 0 }
          },
          properties = {
            ["color"] = "#ff00aa00"
          }
        },
        {
          id = 20,
          name = "",
          type = "Bee",
          shape = "rectangle",
          x = 292.5,
          y = 133.5,
          width = 40,
          height = 66,
          rotation = 0,
          gid = 42,
          visible = true,
          properties = {}
        }
      }
    }
  }
}

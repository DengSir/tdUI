-- .index.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/20/2020, 10:00:50 AM

---@class tdUICollectButtonEnv
---@field collected boolean
---@field points table
---@field frameLevelDelta number

---@class tdUICollectFrame: Frame
---@field buttonList Button[]
---@field buttonEnv table<Button, tdUICollectButtonEnv>

---@class tdUIAuctionQueryParams
---@field text string
---@field minLevel number
---@field maxLevel number
---@field page number
---@field usable boolean
---@field quality number
---@field filters any
---@field queryAll boolean

---@class tdUIAuctionBrowse: ScrollFrame
---@field prevSearchParams tdUIAuctionQueryParams
---@field buttons tdUIAuctionBrowseItem[]

---@class tdUIAuctionBrowseItem: Button
---@field Bg Texture
---@field Selected Texture
---@field Icon Texture
---@field Name FontString
---@field Level FontString
---@field Time FontString
---@field Seller FontString
---@field Bid FontString
---@field Buyout FontString
---@field UnitPrice FontString

---@class ns
---@field profile Profile
---@field global Global

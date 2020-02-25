-- WorldMap.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 12:32:21 PM

WorldMapFrame:HookScript('OnShow', UpdateMicroButtons)
WorldMapFrame:HookScript('OnHide', UpdateMicroButtons)

UIErrorsFrame:SetPoint('TOP', 0, -302)

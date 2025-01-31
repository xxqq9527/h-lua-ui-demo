hdzui.wideScreen()
-- hdzui.hideInterface()

    UI = function()
        print_r("66666666666")
        hdzui.loadToc("UI\\frame.toc")

        SINGLUAR_UI_ABILITY_MAX = 11 * 2 --最大buff数,偶数

        local bagRx = 0.016
        local bagRy = bagRx * (8 / 6)

        local SLBuffBtns = {}
        local SLBuffTxt = {}
        local SLBuffExts = {}
        local SLBuffBorders = {}

        for i = 1, SINGLUAR_UI_ABILITY_MAX do
            local x = -0.084 + bagRx * (i - 1)
            local y = 0.142
            local half = SINGLUAR_UI_ABILITY_MAX / 2
            if (i > half) then
                x = -0.084 + bagRx * (i - half - 1)
                y = 0.142 + bagRy
            end


            --buff图标
            SLBuffExts[i] = hdzui.frameTag("BACKDROP","sdk_buff->ext->" .. i,hdzui.origin.game(),"")
            hjapi.DzFrameSetPoint(SLBuffExts[i],7,hdzui.origin.game(),7,x,y)
            hjapi.DzFrameSetSize(SLBuffExts[i],bagRx,bagRy)
            hjapi.DzFrameShow(SLBuffExts[i],false)

            --三角图标
            SLBuffBorders[i] = hdzui.frameTag("BACKDROP","sdk_buff->border->" .. i,SLBuffExts[i],"")
            hjapi.DzFrameSetPoint(SLBuffBorders[i],4, SLBuffExts[i],4,0,0)
            hjapi.DzFrameSetSize(SLBuffBorders[i],bagRx,bagRy)
            hjapi.DzFrameShow(SLBuffBorders[i],true)

            --时间文本
            SLBuffTxt[i] = hdzui.frameTag("TEXT","T666",SLBuffExts[i])
            hjapi.DzFrameSetText(SLBuffTxt[i],"")
            hjapi.DzFrameSetPoint(SLBuffTxt[i],4, SLBuffExts[i],4,0,0)
            hjapi.DzFrameShow(SLBuffTxt[i],true)

            --按钮
            SLBuffBtns[i] = hdzui.frameTag("BUTTON","sdk_buff->btn->" .. i,SLBuffExts[i],nil)
            hjapi.DzFrameSetPoint(SLBuffBtns[i],4,SLBuffExts[i],4,0,0)
            hjapi.DzFrameSetSize(SLBuffBtns[i],bagRx,bagRy)
            hjapi.DzFrameShow(SLBuffBtns[i],true)
            --
            hplayer.forEach(function(enumPlayer, _)
                if (his.playing(enumPlayer)) then
                    hdzui.onMouse(SLBuffBtns[i],2,"expOn",enumPlayer)
                    hdzui.onMouse(SLBuffBtns[i],3,"expOff",enumPlayer)
                end
            end)
        end

        --说明框
        cg.expTxt = hdzui.frame("explain",hdzui.origin.game(),0)
        hjapi.DzFrameSetAbsolutePoint( cg.expTxt,4,0.388,0.350)
        hjapi.DzFrameShow( cg.expTxt,false)

        htime.setInterval(0.1,function(_)
            hplayer.forEach(function(enumPlayer, idx)
                local selection = selectedUnit[idx]
                local show = false
                local showIdx = {}
                if (his.playing(enumPlayer) and selection ~= nil) then
                    if (his.alive(selection)) then
                        local buffHandle = hcache.get(selection, CONST_CACHE.BUFF)
                        if (buffHandle ~= nil) then
                            show = true
                            local buffTab = {}
                            local sort = {}
                            for bi, b in ipairs(CONST_ATTR_KEYS) do
                                local keys = nil
                                local symbol = ""
                                if (buffHandle["attr." .. b .. "+"] ~= nil) then
                                    keys = "attr." .. b .. "+"
                                    symbol = "+"
                                end
                                if (buffHandle["attr." .. b .. "-"] ~= nil) then
                                    keys = "attr." .. b .. "-"
                                    symbol = "-"
                                end
                                --
                                if (keys ~= nil) then
                                    for _, buffKey in ipairs(buffHandle[keys]._idx) do
                                        buffHandle[keys][buffKey].num = bi
                                        buffHandle[keys][buffKey].symbol = symbol
                                        buffTab[buffKey] = buffHandle[keys][buffKey]
                                        local s = {key = buffKey}
                                        table.insert(sort,s)
                                    end
                                end
                            end
                            ----
                            --排序
                            table.sort(sort,function(a, b)
                                return a.key < b.key
                            end)

                            if (show) then
                                for idx, v in ipairs(sort) do
                                    if (idx < SINGLUAR_UI_ABILITY_MAX) then
                                        showIdx[idx] = true
                                        local time = buffTab[v.key].times
                                        local bi = buffTab[v.key].num
                                        local icon = BUFF_DISPLAY_KEYS[bi].icon
                                        local name = BUFF_DISPLAY_KEYS[bi].name
                                        local t = math.round(htime.getRemainTime(time),1)
                                        local difference = 0
                                        hjapi.DzFrameSetText(SLBuffTxt[idx],t)
                                        hjapi.DzFrameSetTexture(SLBuffExts[idx],icon,false)
                                        if (buffTab[v.key].symbol == "+") then
                                            hjapi.DzFrameSetTexture(SLBuffBorders[idx],"buffIcon\\up.tga",false)
                                            difference = hcolor.green(buffTab[v.key].symbol .. buffTab[v.key].difference)
                                        else
                                            hjapi.DzFrameSetTexture(SLBuffBorders[idx],"buffIcon\\down.tga",false)
                                            difference = hcolor.red(buffTab[v.key].difference)
                                        end
                                        local txtUi = name .. ":" .. difference .. "|n" .. hcolor.greenLight("持续:" .. t .. "秒")
                                        cj.SaveStr(cg.txtUI,SLBuffBtns[idx],1,txtUi)
                                        if (t <= 3) then
                                            local transparency = 50 + 255 * t / 3
                                            hjapi.DzFrameSetAlpha(SLBuffTxt[idx],transparency)
                                            hjapi.DzFrameSetAlpha(SLBuffExts[idx],transparency)
                                            hjapi.DzFrameSetAlpha(SLBuffBorders[idx],transparency)
                                        else
                                            hjapi.DzFrameSetAlpha(SLBuffTxt[idx],255)
                                            hjapi.DzFrameSetAlpha(SLBuffExts[idx],255)
                                            hjapi.DzFrameSetAlpha(SLBuffBorders[idx],255)
                                        end
                                    end
                                end
                            end

                        end
                    end
                    for k, _ in ipairs(SLBuffBtns) do
                        if (enumPlayer == hplayer.loc()) then
                            if (show and showIdx[k] == true) then
                                hjapi.DzFrameShow(SLBuffExts[k],true)
                            else
                                hjapi.DzFrameShow(SLBuffExts[k],false)
                            end
                        end
                    end
                end
            end)
        end)


    end

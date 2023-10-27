

local grenade_thrown = function(events)

    -->> 获取当前事件能够返回我们的信息
    print("触发手雷投掷事件")
    print("投掷者的ID是：" .. events.userid)
    print("投掷者的武器是：" .. events.weapon)
    -->> 更多事件API可参考 [[https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#grenade_thrown]]


    local player = entity.get_local_player()
    -->> 获取本地玩家
    
    local player_index = player:get_player_info().userid
    print("本地玩家的ID是:"..player_index)
    -->> 拿ID

    local is_in_air = (player.m_fFlags == 256)
    -->> 检测玩家是否在空中, 其中256是空中的标志位, 255是玩家站在地上的标志位

    local is_localplayer = (events.userid == player_index)
    -->> 检测当前事件是否是本地玩家触发的, 请解释为什么要这样做

    local is_player_dt = ui.find('Aimbot', 'Ragebot', 'Main', 'Double Tap'):get()
    -->> 检测玩家的菜单是否打开了DT按钮

    if is_in_air and is_localplayer and is_player_dt then
        rage.exploit:force_teleport()
        -->> 强制对本地玩家进行TP
    end
end

events.grenade_thrown:set(grenade_thrown)
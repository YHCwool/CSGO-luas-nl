local http_lib = require("neverlose/http_lib")
local http = http_lib.new({
    task_interval = 0.3, -- polling intervals
    enable_debug = true, -- print http request s to the console
    timeout = 10 -- request expiration time
})

local images = {
    -- 缓存图片
    content = nil,
    is_downloaded = false,
    -- 图片地址
    url = "https://i.imgur.com/P3w2OOZ.png"
}
local image_grabber = function()
    http:get(images.url, function(data)
        if data:success() and data.status == 200 and data.body then
            -->> 将图片缓存到变量 (data.body该网页的所有内容)
            images.content = data.body
            -->> 如果图片下载完成，返回True
            images.is_downloaded = true
        end
    end)
end

local render_images = function()
    if not images.is_downloaded then return end
    local image = images.content
end

image_grabber()
events.render:set(render_images)
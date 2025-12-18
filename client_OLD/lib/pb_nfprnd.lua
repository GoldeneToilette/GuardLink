return {init=function(box,_,_,_,_,_)
    local blit_to_palette = {}
    for i=0,15 do
        blit_to_palette[("%x"):format(i)] = 2^i
    end

    local function parse_nfp_string(image_data)
        local image_scanlines = {}
        for image_line in (image_data.."\n"):gmatch("(.-)\n") do
            local scanline_length = #image_line
            local scanline        = {width=scanline_length}

            image_scanlines[#image_scanlines+1] = scanline

            for pixel_index=1,scanline_length do
                local pixel_data = image_line:sub(pixel_index,pixel_index)

                scanline[pixel_index] = blit_to_palette[pixel_data]
            end
        end

        return image_scanlines
    end

    local function load_nfp_file(path)
        local file_handle = fs.open(path,"rb")

        if file_handle then
            local nfp_data = file_handle.readAll()
            file_handle.close()

            return parse_nfp_string(nfp_data)
        end
    end

    local function blit_nfp_at(x,y,image,width,height)
        local box_canvas = box.canvas

        for y_index=1,math.min(#image,height or math.huge) do
            local nfp_scanline = image[y_index]
            local box_scanline = box_canvas[y+y_index-1]

            for x_index=1,math.min(nfp_scanline.width,width or math.huge) do
                local nfp_pixel = nfp_scanline[x_index]

                if nfp_pixel then
                    box_scanline[x+x_index-1] = nfp_scanline[x_index]
                end
            end
        end
    end

    return {nfprnd = {
        blit_at = blit_nfp_at,
        load = {
            string = parse_nfp_string,
            file   = load_nfp_file
        },
        internal = {
            blit_to_palette = blit_to_palette
        }
    }},{}
end,
    id         = "PB_MODULE:nfprnd",
    name       = "PB_NFPRender",
    author     = "9551",
    contact    = "https://devvie.cc/contact",
    report_msg = "\n__name: module error, report issues at\n-> __contact"
}
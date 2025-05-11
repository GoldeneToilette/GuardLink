-- Loads UIs from xml files. 

local themes = require("utils.themes")
local utils = require("utils.uihelper")
local xml = require("lib.simpleXML").newParser()

local xmlParser = {}

-- Helper function to resolve colors based on string names
local function resolveColor(color)
    if color == "primary" then 
        return colors.orange
    elseif color == "secondary" then
        return colors.magenta
    elseif color == "third" then
        return colors.lightBlue   
    elseif color == "highlight" then
        return colors.yellow
    elseif color == "subtle" then
        return colors.lime
    elseif color == "black" then
        return colors.black
    elseif color == "red" then
        return colors.black
    else
        return colors.white    
    end
end

-- Main XML loading function
function xmlParser.loadXML(frame, filePath)
    local parsedXml, err = xml:loadFile(filePath)
    local elements = {}

    if not parsedXml then
        print("Error parsing XML: " .. err)
        return
    end

    -- iterates through each element and adds it to the frame
    for _, child in ipairs(parsedXml.ui:children()) do
        local elementName = child:name()
        local id = child["@id"]

        if elementName == "label" then
            elements[id] = utils.createLabel(frame,
                child["@text"],
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"]),
                resolveColor(child["@foreground"])
            )
        elseif elementName == "textfield" then
            elements[id] = utils.createTextfield(frame,
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"]),
                resolveColor(child["@foreground"])
            )
        elseif elementName == "button" then
            elements[id] = utils.createButton(frame,
                child["@text"],
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"]),
                resolveColor(child["@foreground"])
            )
        elseif elementName == "pane" then
            elements[id] = utils.createPane(frame,
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"])
            )
        elseif elementName == "checkbox" then
            elements[id] = utils.createCheckbox(frame,
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"]),
                resolveColor(child["@foreground"])
            )
        elseif elementName == "input" then
            elements[id] = utils.createInput(frame,
                tonumber(child["@x"]),
                tonumber(child["@y"]),
                tonumber(child["@width"]),
                tonumber(child["@height"]),
                resolveColor(child["@background"]),
                resolveColor(child["@foreground"])                
            )
        end
    end

    return elements
end

return xmlParser

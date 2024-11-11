local ErrorHandler = {}

function ErrorHandler.tryCatch(tryBlock, catchBlock)
    local function errorHandler(err)
        local stackTrace = debug.traceback(err)  -- xpcall gives the error as argument
        if catchBlock then
            catchBlock(err, stackTrace)
        else
            _G.logger:fatal("Caught error: " .. tostring(err) .. "\nStack Trace:\n" .. stackTrace)
        end
    end
    
    -- Use xpcall to catch errors and pass the custom errorHandler
    local success = xpcall(tryBlock, errorHandler)
    
    if not success then
        _G.logger:fatal("Error handling failed.")
    end
end

return ErrorHandler
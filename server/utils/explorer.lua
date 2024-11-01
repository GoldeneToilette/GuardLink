-- Very simple file explorer i made a WHILE ago, i will update it one day

local currentPath = "/"
local terminate = false
 
local function listFiles(path)
  local success, files = pcall(fs.list, path)
  return success and files or {}
end
 
local function isDirectory(path)
  return fs.isDir(path)
end
 
local function isLuaFile(path)
  return string.match(path, "%.lua$")
end
 
local function isTxtFile(path)
  return string.match(path, "%.txt$")
end
 
local function printFiles(files)
  term.clear()
  term.setCursorPos(1, 1)
 
  term.setTextColor(colors.lightBlue)
  print("  GuardLink File Explorer")
  term.setTextColor(colors.yellow)
  print("Enter a command ('help' for list of commands): ")
  term.setTextColor(colors.white)
  print("------------------------------")
  term.setTextColor(colors.lime)
  print("Current Path: " .. currentPath)
 
  local lineIndex = 5
 
  local luaFiles = {}
 
  for _, file in ipairs(files) do
    local fullPath = fs.combine(currentPath, file)
    local fileSize = fs.getSize(fullPath)
 
    if isDirectory(fullPath) then
      term.setTextColor(colors.green)
      print("[" .. file .. "]")
    else
      local isLua = isLuaFile(fullPath)
      local fileDisplay = isLua and "- " .. file or file
 
      if isLua then
        table.insert(luaFiles, { display = fileDisplay, size = fileSize })
      else
        term.setTextColor(colors.blue)
        print(fileDisplay)
      end
    end
 
    lineIndex = lineIndex + 1
  end
 
  for _, luaFile in ipairs(luaFiles) do
    term.setTextColor(colors.white)
    print(luaFile.display)
 
    term.setTextColor(colors.orange)
    print("  (Size: " .. luaFile.size .. " bytes)")
 
    lineIndex = lineIndex + 1
  end
 
  term.setTextColor(colors.white)
  for _ = 1, 30 do
    write("-")
  end
  print()
end
 
local function handleInput()
  term.setTextColor(colors.lightGray)
  local input = read()
  term.setTextColor(colors.white)
 
  if input == "exit" or input == "quit" then
    terminate = true
  elseif input == "help" then
    term.setTextColor(colors.yellow)
    print("List of Commands:")
    print("- exit: Exit the file explorer.")
    print("- back: Move to the parent directory.")
    print("- help: Show this list of commands.")
    print("- create directory/file: Create a new directory or file.")
    term.setTextColor(colors.white)
    print("------------------------------")
 
    sleep(5)
  elseif isDirectory(fs.combine(currentPath, input)) then
    currentPath = fs.combine(currentPath, input)
  elseif input == "back" then
    if currentPath ~= "/" then
      currentPath = fs.getDir(currentPath)
    end
  elseif string.match(input, "^create%s+(%a+)/(.+)$") then
    local _, _, createType, createPath = string.find(input, "^create%s+(%a+)/(.+)$")
    if createType and createPath then
      createType = createType:lower()
 
      local fullPath = fs.combine(currentPath, createPath)
 
      if createType == "directory" then
        fs.makeDir(fullPath)
      elseif createType == "file" then
        local file = fs.open(fullPath, "w")
        if file then
          file.close()
        else
          print("Failed to create file.")
        end
 
        local files = listFiles(currentPath)
        table.insert(files, 1, createPath)
 
        printFiles(files)
      end
    else
      print("Invalid create command. Use 'create directory/file <path>'.")
    end
  elseif string.match(input, "^create%s+(.+)$") then
    local _, _, createPath = string.find(input, "^create%s+(.+)$")
    if createPath then
      local fullPath = fs.combine(currentPath, createPath)
 
      if not fs.exists(fullPath) then
        local success
 
        if string.sub(createPath, -1) == "/" then
          success = fs.makeDir(fullPath)
        else
          local file = fs.open(fullPath, "w")
          if file then
            file.close()
            success = true
          end
        end
 
        if success then
          local files = listFiles(currentPath)
          table.insert(files, 1, createPath)
 
          printFiles(files)
        else
          print("Failed to create. Check the path and try again.")
end
else
print("The specified file or directory already exists.")
end
else
print("Invalid create command. Use 'create <path>'.")
end
else
print("Invalid command. Type 'help' for a list of commands.")
end
end
 
while not terminate do
local files = listFiles(currentPath)
printFiles(files)
handleInput()
end
 
 
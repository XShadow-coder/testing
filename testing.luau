local CoreGui = game:GetService("CoreGui")
local targetParent = (gethui and gethui()) or CoreGui

local output = {}

table.insert(output, "TARGET PARENT")
table.insert(output, "Name: " .. tostring(targetParent.Name))
table.insert(output, "Class: " .. tostring(targetParent.ClassName))
table.insert(output, "FullName: " .. tostring(targetParent:GetFullName()))
table.insert(output, "")
table.insert(output, "SCREEN GUIS")
table.insert(output, "================================")

for _, obj in ipairs(targetParent:GetDescendants()) do
    if obj:IsA("ScreenGui") then

        table.insert(output,
            "Name: " .. tostring(obj.Name)
            .. "\nFullName: " .. tostring(obj:GetFullName())
            .. "\nDisplayOrder: " .. tostring(obj.DisplayOrder)
            .. "\nResetOnSpawn: " .. tostring(obj.ResetOnSpawn)
            .. "\nIgnoreGuiInset: " .. tostring(obj.IgnoreGuiInset)
            .. "\nEnabled: " .. tostring(obj.Enabled)
            .. "\nDescendants: " .. tostring(#obj:GetDescendants())
            .. "\n--------------------------------"
        )
    end
end

local result = table.concat(output, "\n")

if setclipboard then
    setclipboard(result)
else
    error("setclipboard non supportato")
end
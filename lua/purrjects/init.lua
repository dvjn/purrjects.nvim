local M = {}

M._opts = {}

local create_projects_find_command = function(workspace)
    local workspace_path = workspace[1]
    workspace_path = vim.fs.normalize(workspace_path)
    workspace_path = vim.fn.shellescape(workspace_path)

    local max_depth = workspace.max_depth or 1

    local command = "find"
    command = command .. " " .. workspace_path
    command = command .. " -type d"
    command = command .. " -mindepth 1"
    command = command .. " -maxdepth " .. tostring(max_depth)

    if workspace.patterns then
        command = command .. " \\( "
        for _, pattern in ipairs(workspace.patterns) do
            command = command .. "-exec test -e '{}/" .. pattern .. "' \\; -o "
        end
        command = command:sub(1, -4) .. " \\) -print"
    end

    return command
end

M.list_projects = function()
    local projects = {}

    for _, workspace in ipairs(M._opts.workspaces) do
        local workspace_path = vim.fs.normalize(workspace[1])

        local projects_find_command = create_projects_find_command(workspace)
        local projects_find_output = vim.fn.system(projects_find_command)

        if vim.v.shell_error ~= 0 then goto continue end

        for project_path in projects_find_output:gmatch("[^\r\n]+") do
            project_path = vim.fs.normalize(project_path)
            local project_name = project_path:sub(#workspace_path + 2, -1)
            table.insert(projects, { name = project_name, path = project_path })
        end

        ::continue::
    end

    return projects
end

M.switch_to_project = function(project)
    vim.cmd("noautocmd cd " .. vim.fn.fnameescape(project.path))
    vim.cmd([[
        silent! %bdelete
        clearjumps
    ]])
end

M.setup = function(opts)
    M._opts = opts
end

return M
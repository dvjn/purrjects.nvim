local M = {}

M._opts = {}
M._projects = nil

local create_projects_find_command = function(workspace)
    local workspace_path = workspace[1]
    workspace_path = vim.fs.normalize(workspace_path)
    workspace_path = vim.fn.shellescape(workspace_path)

    local has_patterns = workspace.patterns and #workspace.patterns > 0
    local max_depth = workspace.max_depth or 1

    if not has_patterns then max_depth = 1 end

    local command = "find"
    command = command .. " " .. workspace_path
    command = command .. " -type d"
    command = command .. " -mindepth 1"
    command = command .. " -maxdepth " .. tostring(max_depth)

    if has_patterns then
        command = command .. " \\( "
        for _, pattern in ipairs(workspace.patterns) do
            command = command .. "-exec test -e '{}/" .. pattern .. "' \\; -o "
        end
        command = command:sub(1, -4) .. " \\) -print"
    end

    return command
end

M._load_projects = function()
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

    M._projects = projects
end

M.refresh_projects = function()
    M._load_projects()
end

M.list_projects = function()
    if M._projects == nil then M._load_projects() end
    return M._projects
end

M.switch_to_project = function(project)
    vim.cmd("noautocmd cd " .. vim.fn.fnameescape(project.path))
    vim.cmd([[
        silent! %bdelete
        clearjumps
    ]])
end

-- Fowler-Noll-Vo (FNV) hash algorithm
M._hash = function(input)
    local fnv_offset_basis = 2166136261
    local fnv_prime = 16777619
    local hash = fnv_offset_basis

    for i = 1, #input do
        local char = string.byte(input, i)
        hash = bit.bxor(hash, char)
        hash = bit.band(hash * fnv_prime, 0xFFFFFFFF)
    end

    return hash
end

M._get_project_at_path = function(path)
    local projects = M.list_projects()

    local matching_project = nil
    local longest_match_length = 0

    for _, project in ipairs(projects) do
        local project_path = project.path

        -- check if project path is prefix of current_path
        if string.sub(path, 1, #project_path) ~= project_path then goto continue end

        -- check if prefix ends with / or end of string to verify it matched whole directory name
        local next_char = string.sub(path, #project_path + 1, #project_path + 1)
        if next_char ~= "/" and next_char ~= "" then goto continue end

        if #project_path > longest_match_length then
            matching_project = project
            longest_match_length = #project_path
        end

        ::continue::
    end

    return matching_project
end

M._get_current_project = function()
    return M._get_project_at_path(vim.loop.cwd())
end

M._get_sessions_path = function()
    return M._opts.sessions_path or (vim.fn.stdpath("data") .. "/" .. "purrjects/sessions")
end

M._get_project_session_file_name = function(project)
    return string.format("%u_%u.vim", M._hash(project.name), M._hash(project.path))
end

M._save_session = function(session_file_path)
    if M._opts.pre_session_save_hook then M._opts.pre_session_save_hook() end
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_file_path))
end

M._restore_session = function(session_file_path)
    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file_path))
    if M._opts.post_session_restore_hook then M._opts.post_session_restore_hook() end
end

M.save_project_session = function()
    local sessions_path = M._get_sessions_path()

    local project = M._get_current_project()
    if not project then return false end

    local session_file_name = M._get_project_session_file_name(project)
    local session_file_path = sessions_path .. "/" .. session_file_name

    vim.fn.mkdir(sessions_path, "p")
    M._save_session(session_file_path)

    return true
end

M.restore_project_session = function()
    local sessions_path = M._get_sessions_path()

    local project = M._get_current_project()
    if not project then return false end

    local session_file_name = M._get_project_session_file_name(project)
    local session_file_path = sessions_path .. "/" .. session_file_name

    if vim.fn.filereadable(session_file_path) ~= 1 then return false end
    M._restore_session(session_file_path)

    return true
end

M._get_last_modified_session_file = function(sessions_path)
    local latest_modified_file = nil
    local latest_modification_time = 0

    for _, filename in ipairs(vim.fn.readdir(sessions_path)) do
        local file_path = sessions_path .. "/" .. filename
        local extension = string.match(file_path, "%.([^%.]+)$")
        if vim.fn.isdirectory(file_path) == 0 and extension == "vim" then
            local modification_time = vim.fn.getftime(file_path)
            if modification_time > latest_modification_time then
                latest_modification_time = modification_time
                latest_modified_file = file_path
            end
        end
    end

    return latest_modified_file
end

M.restore_last_session = function()
    local sessions_path = M._get_sessions_path()

    local last_session_file = M._get_last_modified_session_file(sessions_path)
    if last_session_file == nil then return false end

    M._restore_session(last_session_file)

    return true
end

M.setup = function(opts)
    M._opts = opts

    if M._opts.save_session_on_exit then
        vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
            callback = function()
                M.save_project_session()
            end,
        })
    end

    if M._opts.restore_session_on_enter then
        vim.api.nvim_create_autocmd({ "VimEnter" }, {
            callback = function()
                if vim.fn.argc() ~= 0 then return end
                local session_restored = M.restore_project_session()
                if not session_restored and M._opts.restore_last_session_on_enter then
                    M.restore_last_session()
                end
            end,
        })
    end
end

return M

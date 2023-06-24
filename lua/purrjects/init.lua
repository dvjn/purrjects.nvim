local M = {}

M._opts = {}

local join_path = function(a, b)
    return vim.fs.normalize(a .. "/" .. b)
end

local scan_dir = function(path, opts)
    opts = opts or {}
    opts.include_non_directory = opts.include_non_directory or false

    local dirs = {}
    local dir_scanner = vim.loop.fs_scandir(path)

    if not dir_scanner then return dirs end

    while true do
        local file, filetype = vim.loop.fs_scandir_next(dir_scanner)

        if file == nil then return dirs end
        if filetype == "directory" or opts.include_non_directory then table.insert(dirs, file) end
    end
end

local is_project = function(project_path, children_to_match)
    local empty_children = true

    for _, child_to_match in ipairs(children_to_match) do
        empty_children = false
        local project_children = scan_dir(project_path, { include_non_directory = true })

        for _, project_child in ipairs(project_children) do
            if child_to_match == project_child then return true end
        end
    end

    -- if empty children than this is a project, else not
    return empty_children
end

M.list_projects = function()
    local projects = {}

    for _, workspace in ipairs(M._opts.workspaces) do
        local workspace_path, children_to_match = unpack(workspace)
        workspace_path = vim.fs.normalize(workspace_path)

        for _, potential_project in ipairs(scan_dir(workspace_path)) do
            local project_path = join_path(workspace_path, potential_project)
            if is_project(project_path, children_to_match) then
                table.insert(projects, { name = potential_project, path = project_path })
            end
        end
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

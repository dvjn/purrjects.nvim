# 🐱 purrjects.nvim

> a tiny project and session manager

- manages projects and sessions
- integrates with telescope
- written in lua


## terminology

- **workspace**: a workspace is a directory that contains projects
- **project**: a project is any directory that contains a file/directory with name in configured patterns
- **session**: a session is a saved state of a project that can be saved and restored


## installation

using **lazy.nvim**:

```lua
{
    'dvjn/purrjects.nvim',
    config = function()
        -- run setup
        require("purrjects").setup({
            workspaces = {
                { "~/projects", patterns = { ".git" } }, -- patterns are the children files and directories that mark a directory as a project
                { "~/repos", max_depth = 2, patterns = { ".git", ".svn" } }, -- you can find projects nested in workspace using max_depth value
                { "~/scratch" }, -- when patterns is empty, all directories in workspace are considered as a project
            },
        })

        -- loading telescope plugin
        require("telescope").load_extension("purrjects")

        -- set telescope plugin keymap
        vim.keymap.set("n", "<leader>fp", function()
            vim.cmd("Telescope purrjects")
        end)
    end
}
```

**note:** this requires telescope to be installed.


## inspiration

- [projections.nvim](https://github.com/GnikDroy/projections.nvim)

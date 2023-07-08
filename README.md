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
            -- plugin configuration
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


## configuration

```lua
require("purrjects").setup({
    workspaces = {
        -- patterns are the children files and directories that mark a directory as a project
        { "~/projects", patterns = { ".git" } },

        -- you can find projects nested in workspace using max_depth value
        { "~/repos", max_depth = 2, patterns = { ".git", ".svn" } },

        -- when patterns is empty, all directories in workspace are considered as a project
        { "~/scratch" },
    },

    -- automatically save the current session before exiting vim if you are inside a project directory
    save_session_on_exit = false,
    -- automatically restore session on vim startup when current working directory is in a project
    restore_session_on_enter = false,
    -- automatically restore last session from any project when opening vim outside any project directory
    restore_last_session_on_enter = false,

    -- function to run before saving the current session
    pre_session_save_hook = function() end,
    -- function to run after restoring the current session
    post_session_restore_hook = function() end,

})
```

## inspiration

- [projections.nvim](https://github.com/GnikDroy/projections.nvim)

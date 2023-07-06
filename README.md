# 🐱 purrjects.nvim

> a tiny project and session manager

- manages projects and sessions
- integrates with telescope
- written in lua


## terminology

**workspace**: a workspace is a folder that contains projects
**project**: a project is any folder that contains a file/folder with name in configured patterns
**session**: a session is a saved state of a project that can be saved and restored


## installation

using **lazy.nvim**:

```lua
{
    'dvjn/purrjects.nvim',
    config = function()
        -- run setup
        require("purrjects").setup({
            workspaces = {
                -- { "~/projects", patterns = { ".git" } },
                -- { "~/repos", max_depth = 2, patterns = { ".git", ".svn" } },
                -- { "~/scratch" },
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


## configuration

### setup parameters

| parameter    | default | type | description               |
| ------------ | ------- | ---- | ------------------------- |
| `workspaces` | {}      | list | list of workspace configs |

### workspace

| parameter   | default | type   | description                                             |
| ----------- | ------- | ------ | ------------------------------------------------------- |
| `path`      | nil     | string | path to your workspace                                  |
| `max_depth` | 1       | number | maximum depth to sejrch for project folders             |
| `patterns`  | nil     | list   | names of child files/directories to find project folder |

**note**: when patterns is empty, all directories in workspace are considered as a project.


## inspiration

- [projections.nvim](https://github.com/GnikDroy/projections.nvim)

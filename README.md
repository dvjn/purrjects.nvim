# 🐱 purrjects.nvim

> a tiny project and session manager

- manage projects and sessions
- telescope integration
- written in lua


## installation

installing using **lazy.nvim**:

```lua
{
    'dvjn/purrjects.nvim',
    config = function()
        require("purrjects").setup({
            workspaces = {
                -- { "~/projects", patterns = { ".git" } },
                -- { "~/repos", max_depth = 2, patterns = { ".git", ".svn" } },
                -- { "~/scratch" },
            },
        })

        require("telescope").load_extension("purrjects")
        vim.keymap.set("n", "<leader>fp", function()
            vim.cmd("Telescope purrjects")
        end)
    end
}
```


## inspiration

- [projections.nvim](https://github.com/GnikDroy/projections.nvim)

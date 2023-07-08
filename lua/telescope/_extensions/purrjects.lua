local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local entry_display = require("telescope.pickers.entry_display")
local purrjects = require("purrjects")

local find_projects_prompt = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Purrjects",
            finder = finders.new_table({
                results = purrjects.list_projects(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        ordinal = entry.path,
                        display = function(e)
                            return entry_display.create({
                                items = { { width = 35 }, { remaining = true } },
                                separator = " ",
                            })({
                                e.value.name,
                                { e.value.path, "Comment" },
                            })
                        end,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_buffer, _)
                actions.select_default:replace(function()
                    actions.close(prompt_buffer)
                    local selection = action_state.get_selected_entry()
                    purrjects.save_project_session()
                    purrjects.switch_to_project(selection["value"])
                    purrjects.restore_project_session()
                end)
                return true
            end,
        })
        :find()
end

return require("telescope").register_extension({
    setup = function(_, _) end,
    exports = {
        purrjects = find_projects_prompt,
    },
})

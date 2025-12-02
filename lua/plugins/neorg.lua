return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        -- Remove the nvim-cmp completion module
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/neorg/notes",
              work = "~/neorg/work",
            },
            default_workspace = "work",
          },
        },
        ["core.journal"] = {
          config = {
            workspace = "work",
            journal_folder = "journal",
            strategy = "flat",
          },
        },
      },
    })

    -- Calculate Star Trek stardate
    -- Format: [year - 2323].[day of year].[time fraction]
    local function get_stardate()
      local date = os.date("*t")
      local year = date.year - 2323 -- TNG era started ~2364
      local day_of_year = os.date("%j")
      local time_fraction = string.format("%.2f", (date.hour * 3600 + date.min * 60 + date.sec) / 86400)
      time_fraction = time_fraction:sub(3) -- Remove "0."
      return string.format("%d.%s.%s", year + 41, day_of_year, time_fraction)
    end

    -- Keybindings for journal
    vim.keymap.set("n", "<leader>jt", ":Neorg journal today<CR>", { desc = "Journal today" })
    vim.keymap.set("n", "<leader>jy", ":Neorg journal yesterday<CR>", { desc = "Journal yesterday" })
    vim.keymap.set("n", "<leader>jm", ":Neorg journal tomorrow<CR>", { desc = "Journal tomorrow" })

    -- Insert stardate at cursor
    vim.keymap.set("n", "<leader>js", function()
      local stardate = get_stardate()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local new_line = line:sub(1, col) .. stardate .. line:sub(col + 1)
      vim.api.nvim_set_current_line(new_line)
    end, { desc = "Insert stardate" })

    -- Create journal with stardate header
    vim.keymap.set("n", "<leader>jc", function()
      local stardate = get_stardate()
      local real_date = os.date("%Y-%m-%d")
      vim.cmd("e ~/neorg/work/journal/" .. real_date .. ".norg")

      -- Check if file is empty
      if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
        local header = string.format(
          "* Stardate %s - Captain's Log\n\n"
            .. "** 🎯 Mission Objectives\n"
            .. "   - ( ) \n\n"
            .. "** 📝 Captain's Log\n"
            .. "*** Alpha Shift (Morning)\n"
            .. "    \n\n"
            .. "*** Beta Shift (Afternoon)\n"
            .. "    \n\n"
            .. "*** Gamma Shift (Evening)\n"
            .. "    \n\n"
            .. "** 💭 Observations & Tactical Analysis\n"
            .. "   \n\n"
            .. "** 🚧 Engineering Reports (Blockers)\n"
            .. "   \n\n"
            .. "** ✅ Mission Accomplished\n"
            .. "   - (x) \n\n"
            .. "** 📚 New Discoveries\n"
            .. "   \n\n"
            .. "** 🔄 Next Mission Parameters\n"
            .. "   - ( ) \n\n"
            .. "---\n"
            .. "/End log entry/\n",
          stardate
        )
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(header, "\n"))
        vim.cmd("write")
      end
    end, { desc = "Captain's log with stardate" })
  end,
}

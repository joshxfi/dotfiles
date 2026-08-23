return {
	{
		"nvim-telescope/telescope.nvim",
		-- Track master: the 0.1.8 tag predates telescope's support for the
		-- nvim-treesitter `main` branch. On 0.1.8 the previewer calls the removed
		-- `nvim-treesitter.parsers.ft_to_lang`, which crashes the preview. Master
		-- uses the native vim.treesitter APIs. (lazy-lock still pins the commit.)
		branch = "master",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>gf", builtin.git_files, {})
			vim.keymap.set("n", "<leader>ps", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
		end,
	},
}

-- Parsers to install up front. Add languages here as you need them.
local ensure_installed = {
	"bash",
	"json",
	"yaml",
	"c",
	"css",
	"diff",
	"html",
	"javascript",
	"typescript",
	"tsx",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
}

return {
	{
		-- NOTE: The `main` branch is the rewrite required for Neovim 0.11+/0.12.
		-- The old `master` branch is frozen and crashes on 0.12 (get_node_text /
		-- "attempt to call method 'range'"). The API is completely different:
		-- there is no `configs.setup()`, no `highlight`/`indent`/`ensure_installed`
		-- opts. Parsers are installed via `install()` and features are turned on
		-- per-buffer with Neovim's built-in `vim.treesitter.*`.
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- Install the baseline parser set (async; safe to call every startup).
			ts.install(ensure_installed)

			-- Set of parsers nvim-treesitter can install, so auto-install never
			-- fires on pseudo-filetypes (e.g. plugin UI buffers like fidget).
			local available = {}
			for _, lang in ipairs(ts.get_available()) do
				available[lang] = true
			end

			-- Enable highlighting + indentation per buffer. This replaces the old
			-- `highlight.enable` / `indent.enable` / `auto_install` options.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("joshxfi-treesitter", { clear = true }),
				callback = function(ev)
					local buf = ev.buf
					local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
					if not lang or not available[lang] then
						return
					end

					-- Start built-in treesitter highlighting if the parser is present.
					if pcall(vim.treesitter.start, buf, lang) then
						-- Indentation (experimental, provided by nvim-treesitter).
						-- Disabled for ruby, which relies on vim's regex indent.
						if lang ~= "ruby" then
							vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						end
					else
						-- Parser available but not installed yet: auto-install (async).
						-- Highlighting takes effect next time this filetype is opened.
						pcall(ts.install, lang)
					end
				end,
			})
		end,
	},
}

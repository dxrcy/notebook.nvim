local M = {}

function M.gitsigns_override_trick()
	local has_gitsigns_git, gitsigns_git = pcall(require, "gitsigns.git")

	if
		not has_gitsigns_git --
		or not gitsigns_git
		or not gitsigns_git.Obj
		or not gitsigns_git.Obj.get_show_text
	then
		return
	end

	local old_get_show_text = gitsigns_git.Obj.get_show_text

	gitsigns_git.Obj.get_show_text = function(self, revision, relpath)
		local text = old_get_show_text(self, revision, relpath)

		-- use the parsed content as the previous text
		if self.file and vim.endswith(self.file, ".ipynb") then
			local ok, nb = pcall(require, "notebook.notebook")
			if ok then
				text, _ = nb.parse_notebook_data(text)
			end
		end

		return text
	end
end

function M.setup()
	local options = require("notebook.options").get()
	if options.override_gitsigns then
		pcall(M.gitsigns_override_trick)
	end
end

return M

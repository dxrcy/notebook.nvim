local M = require("lualine.component"):extend()
local highlight = require("lualine.highlight")
local lualine = require("notebook.lualine")

function M:init(options)
	M.super.init(self, options)

	self.colors = {}
end

local function to_hex(color)
	if not color then
		return nil
	end
	return string.format("#%06x", color)
end

local function get_lualine_bg()
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "lualine_c_normal" })
	if ok and hl and hl.bg then
		return to_hex(hl.bg)
	end
	local fallback = vim.api.nvim_get_hl(0, { name = "StatusLine" })
	return to_hex(fallback.bg or 0)
end

function M:get_highlight(name)
	if self.colors[name] then
		return self.colors[name]
	end

	local src = vim.api.nvim_get_hl(0, { name = name, link = false })
	local group_name = "NotebookLualine_" .. name

	vim.api.nvim_set_hl(0, group_name, {
		fg = to_hex(src.fg),
		bg = get_lualine_bg(),
	})
	self.colors[name] = highlight.create_component_highlight_group(group_name, "notebook", self.options)

	return group_name
end

function M:update_status()
	local text = lualine.section()

	text = text:gsub("%%#(.-)#", function(name)
		return highlight.component_format_highlight(self:get_highlight(name))
	end)

	text = text:gsub("%%%*", "")

	return text
end

return M

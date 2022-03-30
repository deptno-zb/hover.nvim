local fn = vim.fn

local async = require('hover.async')
local job = require('hover.async.job').job
local util = require('vim.lsp.util')

local function enabled()
  return vim.tbl_contains({
    'sh', 'zsh', 'tcl', 'make',
  }, vim.bo.filetype)
end

local function process(result)
  if not result then
    return
  end
  return vim.split(result, '\n')
end

local execute = async.void(function(config, done)
  local is_tcl = vim.bo.filetype == 'tcl'

  local output = job {
    'man', is_tcl and 'n' or '1', fn.expand('<cword>')
  }

  async.scheduler()

  local results = process(output)
  if results then
    util.open_floating_preview(results, "man", config.preview_opts)
  end
  done(results and true or false)
end)

require('hover').register {
  name = 'Man',
  priority = 150,
  enabled = enabled,
  execute = execute,
}
local M = {}

local default_bin = 'dc'

local defaults = {
  bin = default_bin,
  win = {
    relative = 'editor',
    border = 'rounded',
    style = 'minimal',
    title = default_bin,
  },
}

local function open_window()
  local opts = M.options

  vim.validate {
    bin = { opts.bin, 'string' },
  }

  local height = math.ceil(vim.o.lines * 0.5)
  local width = math.ceil(vim.o.columns * 0.7)

  local buffer = vim.api.nvim_create_buf(false, true)

  local win_opts = opts.win

  local win = vim.api.nvim_open_win(buffer, true, {
    relative = win_opts.relative,
    border = win_opts.border,
    style = win_opts.style,
    title = win_opts.style,
    height = win_opts.height or height,
    width = win_opts.width or width,
    row = win_opts.row or math.ceil((vim.o.lines - height) * 0.5),
    col = win_opts.col or math.ceil((vim.o.columns - width) * 0.5),
  })

  return win
end

function M.open()
  local opts = M.options

  if vim.fn.executable(opts.bin) ~= 1 then
    vim.api.nvim_err_write(opts.bin .. ' not found')
    return
  end

  local last_win = vim.api.nvim_get_current_win()
  local win = open_window()

  vim.fn.termopen(opts.bin, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_win(last_win)
    end,
  })
  vim.cmd.startinsert()
end

function M.setup(options)
  M.options = vim.tbl_deep_extend('force', defaults, options or {})
  vim.api.nvim_create_user_command('Rp', M.open, { nargs = 0 })
end

return M

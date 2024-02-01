local M = {}

local defaults = {
  bin = 'dc',
}

local function open_window()
  local opts = M.options

  vim.validate {
    bin = { opts.bin, 'string' },
  }

  local height = math.ceil(vim.o.lines * 0.5)
  local width = math.ceil(vim.o.columns * 0.7)

  local win_opts = {
    relative = 'editor',
    border = 'rounded',
    style = 'minimal',
    title = opts.bin,
    height = height,
    width = width,
    row = math.ceil((vim.o.lines - height) * 0.5),
    col = math.ceil((vim.o.columns - width) * 0.5),
  }

  local buffer = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buffer, true, win_opts)

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

  local command = vim.api.nvim_create_user_command
  command('Rp', M.open, { nargs = 0 })
  vim.keymap.set('n', '<leader>rp', M.open)
end

return M

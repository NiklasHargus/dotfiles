return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'rcarriga/nvim-dap-ui',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = 'OpenDebugAD7',
    }

    dap.adapters.lldb = {
      type = 'executable',
      command = '/usr/bin/codelldb', -- adjust as needed, must be absolute path
      -- command = 'codelldb', -- adjust as needed, must be absolute path
      name = 'lldb'
    }

    dap.configurations.cpp = {
      {
        name = 'Launch',
        type = 'cppdbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},

        -- 💀
        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        -- runInTerminal = false,
      },
    }
    -- dap.configurations.cpp = {{
    --   name = "Launch file",
    --   type = "cppdbg",
    --   request = "launch",
    --   setupCommands = {{
    --      text = '-enable-pretty-printing',
    --      description =  'enable pretty printing',
    --      ignoreFailures = false
    --    }},
    --   program = function()
    --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --   end,
    --   cwd = '${workspaceFolder}',
    --   stopAtEntry = true,}
    -- }

    require('dap.ext.vscode').load_launchjs()
    -- require('dap.ext.vscode').load_launchjs("./launch.json")

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸ [F1]',
          play = '▶ [F1]',
          step_into = '↧ [F2]',
          step_over = '≫ [F3]',
          step_out = '≪ [F4]',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹ [d-t]',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = '[D]ebug: [T]erminate Program' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })


    -- Install golang specific config
    require('dap-python').setup("python")
  end,
}

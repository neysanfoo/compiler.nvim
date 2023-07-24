--- Python language actions
-- Unlike most languages, python can be:
--   * interpreted
--   * compiled to machine code
--   * compiled to bytecode

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1  - Run this file (interpreted)", value = "option1" },
  { text = "2  - Run program (interpreted)", value = "option2" },
  { text = "3  - Run solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "4  - Build and run program (machine code)", value = "option4" },
  { text = "5  - Build program (machine code)", value = "option5" },
  { text = "6  - Run program (machine code)", value = "option6" },
  { text = "7  - Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "8  - Build and run program (bytecode)", value = "option8" },
  { text = "9  - Build program (bytecode)", value = "option9" },
  { text = "10 - Run program (bytecode)", value = "option10" },
  { text = "11 - Build solution (bytecode)", value = "option11" },
  { text = "", value = "separator" },
  { text = "12 - Run Makefile", value = "option12" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local entry_point = utils.osPath(vim.fn.getcwd() .. "/main.py")            -- working_directory/main.py
  local files = utils.find_files_to_compile(entry_point, "*.py")             -- *.py files under entry_point_dir (recursively)
  local output_dir = utils.osPath(vim.fn.getcwd() .. "/bin/")                -- working_directory/bin/
  local output = utils.osPath(vim.fn.getcwd() .. "/bin/program")             -- working_directory/bin/program
  local final_message = "--task finished--"
  -- For python, parameters are not globally defined,
  -- as we have 3 different ways to run the code.


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Python interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd =  "python " .. current_file ..                                -- run (interpreted)
                " && echo " .. current_file ..                               -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Python interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = "python3 " .. entry_point ..                                  -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(utils.osPath(vim.fn.getcwd() .. "/.solution"))

      for entry, variables in pairs(config) do
        local entry_point = utils.osPath(variables.entry_point)
        local parameters = variables.parameters or "" -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "python3 " .. parameters .. " " .. entry_point ..             -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({
        name = "- Python interpreter", strategy = { "orchestrator",
          tasks = {
            tasks, -- Run all the programs in the solution in parallel
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")
      local parameters = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.osPath(entry_point)
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "python3 " .. parameters .. " " .. entry_point ..             -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Python interpreter", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end












  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local parameters = "--warn-implicit-exceptions --warn-unusual-code"                -- optional
    local task = overseer.new_task({
      name = "- Python machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                  -- clean
            " && mkdir -p " .. output_dir ..                                           -- mkdir
            " && nuitka3 --no-pyi-file --remove-output --follow-imports"  ..           -- compile to machine code
              " --output-filename=" .. output  ..
              " " .. parameters .. " " .. entry_point ..
            " && " .. output ..                                                        -- run
            " && echo " .. entry_point ..                                              -- echo
            " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option5" then
    local parameters = "--warn-implicit-exceptions --warn-unusual-code"                 --optional
    local task = overseer.new_task({
      name = "- Python machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && nuitka3 --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                  " --output-filename=" .. output  ..
                  " " .. parameters .. " " .. entry_point ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option6" then
    local task = overseer.new_task({
      name = "- Python machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = output ..                                                             -- run
                  " && echo " .. output ..                                              -- echo
                  " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option7" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(utils.osPath(vim.fn.getcwd() .. "/.solution"))
      local executable

      for entry, variables in pairs(config) do
        if variables.executable then
          executable = utils.osPath(variables.executable)
          goto continue
        end
        entry_point = utils.osPath(variables.entry_point)
        output = utils.osPath(variables.output)
        output_dir = utils.osPath(output:match("^(.-[/\\])[^/\\]*$"))
        local parameters = variables.parameters or "--warn-implicit-exceptions --warn-unusual-code" -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && nuitka3 --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                  " --output-filename=" .. output  ..
                  " " .. parameters .. " " .. entry_point ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Python machine code compiler",
          cmd = executable ..                                                           -- run
                " && echo " .. executable ..                                            -- echo
                " && echo '" .. final_message .. "'"
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Build program → " .. entry_point, strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.osPath(entry_point)
        output_dir = utils.osPath(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")     -- entry_point/bin
        output = utils.osPath(output_dir .. "/program")                                 -- entry_point/bin/program
        local parameters = "--warn-implicit-exceptions --warn-unusual-code"             -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && nuitka3 --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                  " --output-filename=" .. output  ..
                  " " .. parameters .. " " .. entry_point ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Python machine code compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end












  --============================ BYTECODE ===================================--
  elseif selected_option == "option8" then
    local cache_dir = utils.osPath(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
    local output_filename = vim.fn.fnamemodify(output, ":t")
    local parameters = "--log-level WARN --python-option W" -- optional
    local task = overseer.new_task({
      name = "- Python bytecode compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && mkdir -p " .. cache_dir ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath " .. cache_dir ..
                  " --specpath " .. cache_dir ..
                  " --onefile --distpath " .. output_dir .. " " .. parameters ..
                " && " .. output ..                                                     -- run
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option9" then
    local cache_dir = utils.osPath(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
    local output_filename = vim.fn.fnamemodify(output, ":t")
    local parameters = "--log-level WARN --python-option W" -- optional
    local task = overseer.new_task({
      name = "- Python machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && mkdir -p " .. cache_dir ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath " .. cache_dir ..
                  " --specpath " .. cache_dir ..
                  " --onefile --distpath " .. output_dir .. " " .. parameters ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option10" then
    local task = overseer.new_task({
      name = "- Python bytecode compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = output ..                                                             -- run
                " && echo " .. output ..                                                -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option11" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(utils.osPath(vim.fn.getcwd() .. "/.solution"))
      local executable

      for entry, variables in pairs(config) do
        if variables.executable then
          executable = utils.osPath(variables.executable)
          goto continue
        end
        local cache_dir = utils.osPath(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
        entry_point = utils.osPath(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, "*.py")
        output = utils.osPath(variables.output)
        local output_filename = vim.fn.fnamemodify(output, ":t")
        output_dir = utils.osPath(output:match("^(.-[/\\])[^/\\]*$"))
        local parameters = variables.parameters or "--log-level WARN --python-option W" -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && mkdir -p " .. cache_dir ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath " .. cache_dir ..
                  " --specpath " .. cache_dir ..
                  " --onefile --distpath " .. output_dir .. " " .. parameters ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Python bytecode compiler",
          cmd = executable ..                                                           -- run
                " && echo " .. executable ..                                            -- echo
                " && echo '" .. final_message .. "'"
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Build program → " .. entry_point, strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.osPath(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.py")
        output_dir = utils.osPath(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")     -- entry_point/bin
        output = utils.osPath(output_dir .. "/program")                                 -- entry_point/bin/program
        local cache_dir = utils.osPath(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
        local output_filename = vim.fn.fnamemodify(output, ":t")
        local parameters = "--log-level WARN --python-option W"                         -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                   -- clean
                " && mkdir -p " .. cache_dir ..                                         -- mkdir
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath " .. cache_dir ..
                  " --specpath " .. cache_dir ..
                  " --onefile --distpath " .. output_dir .. " " .. parameters ..
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Python bytecode compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end











  --=============================== MAKE ====================================--
  elseif selected_option == "option12" then
    require("compiler.languages.make").run_makefile()                        -- run
  end

end

return M

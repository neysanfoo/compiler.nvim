--- This test run "Build solution" for all languages when no .solution file is found.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/build.lua

local ms = 0 -- wait
local language = nil
local data_dir = vim.fn.stdpath "data"

-- test c
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/c")
language = require("compiler.languages.c")
language.action("option4")
vim.wait(ms)
-- c++
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/cpp")
language = require("compiler.languages.cpp")
language.action("option4")
vim.wait(ms)
-- cs
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/cs")
language = require("compiler.languages.cs")
language.action("option4")
vim.wait(ms)
-- java
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/java")
language = require("compiler.languages.java")
language.action("option4")
vim.wait(ms)
-- asm
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/asm")
language = require("compiler.languages.asm")
language.action("option4")
vim.wait(ms)
-- python (interpreted)
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/python/interpreted")
language = require("compiler.languages.python")
language.action("option3")
vim.wait(ms)
-- python (machine code)
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/python/machine-code")
language = require("compiler.languages.python")
language.action("option7")
vim.wait(ms)
-- python (bytecode)
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/python/bytecode")
language = require("compiler.languages.python")
language.action("option11")
vim.wait(ms)
-- ruby
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/ruby")
language = require("compiler.languages.ruby")
language.action("option3")
vim.wait(ms)
-- rust
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/rust")
language = require("compiler.languages.rust")
language.action("option4")
vim.wait(ms)
-- shell
vim.api.nvim_set_current_dir(data_dir .. "/lazy/compiler.nvim/tests/examples/sh")
language = require("compiler.languages.sh")
language.action("option2")
vim.wait(ms)
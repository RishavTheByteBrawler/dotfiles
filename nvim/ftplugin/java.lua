local home = os.getenv("HOME")
local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name
local function arginp()
	return coroutine.create(function(dap_run_co)
		vim.ui.input({ prompt = "Args: " }, function(argstr)
			coroutine.resume(dap_run_co, argstr)
		end)
	end)
end

local status, jdtls = pcall(require, "jdtls")
if not status then
	return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities
local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=TRACE",
		"-Xms1g",
		"-Xmx2g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
		"-jar",
		vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		home .. "/.local/share/nvim/mason/packages/jdtls/config_mac_arm",
		"-data",
		workspace_dir,
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

	settings = {
		java = {
			signatureHelp = { enabled = true },
			extendedClientCapabilities = extendedClientCapabilities,
			eclipse = {
				downloadSources = true,
			},
			maven = {
				downloadSources = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all", -- literals, all, none
				},
			},
			saveActions = {
				organizeImports = true,
			},
			completion = {
				-- When using an unimported static method, how should the LSP rank possible places to import the static method from
				favoriteStaticMembers = {
					"java.util.*",
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				importOrder = {
					"java",
					"jakarta",
					"javax",
					"com",
					"org",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
			},
			sources = {
				-- How many classes from a specific package should be imported before automatic imports combine them all into a single import
				organizeImports = {
					starThreshold = 9999,
					staticThreshold = 9999,
				},
			},
			compile = {
				nullAnalysis = {
					nonnull = {
						"lombok.NonNull",
						"javax.annotation.Nonnull",
						"org.eclipse.jdt.annotation.NonNull",
						"org.springframework.lang.NonNull",
					},
				},
			},
			-- How should different pieces of code be generated?
			codeGeneration = {
				-- When generating toString use a json format
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				-- When generating hashCode and equals methods use the java 7 objects method
				hashCodeEquals = {
					useJava7Objects = true,
				},
				-- When generating code use code blocks
				useBlocks = true,
			},
			-- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
			configuration = {
				updateBuildConfiguration = "interactive",
			},
			-- enable code lens in the lsp
		},
		format = {
			enabled = false,
		},
	},
	on_attach = function(client, bufnr)
		jdtls.setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs({
			config_overrides = {
				args = arginp,
				stepFilters = {
					skipClasses = { "java.lang.ClassLoader" },
				},
			},
		})
	end,
	init_options = {
		bundles = {
      vim.fn.glob( home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar"),
			vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar"),
			vim.fn.glob(
				vim.fn.stdpath("data")
					.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
			),
		},
	},
}
require("jdtls").start_or_attach(config)

-- keymaps and init_options
vim.keymap.set("n", "<leader>co", "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = "Organize Imports" })
vim.keymap.set("n", "<leader>crv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = "Extract Variable" })
vim.keymap.set(
	"v",
	"<leader>crv",
	"<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
	{ desc = "Extract Variable" }
)
vim.keymap.set("n", "<leader>crc", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "Extract Constant" })
vim.keymap.set(
	"v",
	"<leader>crc",
	"<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
	{ desc = "Extract Constant" }
)
vim.keymap.set(
	"v",
	"<leader>crm",
	"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
	{ desc = "Extract Method" }
)

vim.lsp.codelens.refresh()

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.java" },
	callback = function()
		local _, _ = pcall(vim.lsp.codelens.refresh)
	end,
})

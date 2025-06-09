TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/
DEPS_DIR=deps/

.PHONY: plenary test

default: test

# Install dependencies
deps: plenary devicons

plenary:
	@if [ ! -d "$(DEPS_DIR)plenary.nvim" ]; then \
		echo "Cloning plenary.nvim..."; \
		git clone --quiet --depth 1 --branch master https://github.com/nvim-lua/plenary.nvim.git $(DEPS_DIR)plenary.nvim; \
	fi

devicons:
	@if [ ! -d "$(DEPS_DIR)nvim-web-devicons" ]; then \
		echo "Cloning nvim-web-devicons..."; \
		git clone --quiet --depth 1 --branch master https://github.com/nvim-tree/nvim-web-devicons.git $(DEPS_DIR)nvim-web-devicons; \
	fi

test: deps
	@echo "Running tests..."
	nvim --headless --noplugin -u ${TESTS_INIT} -c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }"

lint:
	luacheck lua/telescope

clean:
	@echo "Cleaning dependencies..."
	@rm -rf $(DEPS_DIR)
# Clone plenary.nvim if it doesn't exist
# $(PLENARY_DIR)
# mkdir -p $(DEPS_DIR)plenary.nvim;


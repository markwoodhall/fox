FOX=fox
LUA_DIR=lua
LUA=lua/src/lua
SRC=main.fnl org.fnl args.fnl display.fnl log.fnl template.fnl fox.fnl file.fnl

$(FOX): $(SRC) $(LUA) $(LUA_DIR)/src/liblua.a
	@echo "Building.."
	./fennel --compile-binary $< $(FOX) $(LUA_DIR)/src/liblua.a $(LUA_DIR)/src
	chmod 755 $@
	strip $@

$(LUA): $(LUA_DIR) ; make -C $^

clean:
	@echo "Cleaning.."
	rm -rf fox
	make -C lua clean

repl: $(LUA)
	@echo "Launching repl.."
	./fennel

example: $(FOX)
	@echo "Running.."
	./fox html \
		--org readme.org \
		--css https://cdn.simplecss.org/simple.min.css \
		--footer "This website was generated with Fox" \
		> out.html

.PHONY: clean install repl

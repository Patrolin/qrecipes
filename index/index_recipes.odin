package main
import "core:fmt"
import "core:strings"
import "lib"

main :: proc() {
	file, ok := lib.open_file_for_writing_and_truncate("index.yaml")
	assert(ok)

	lib.walk_files("src", on_walk, file)
	on_walk :: proc(file_path: string, data: rawptr) {
		if !strings.ends_with(file_path, ".yaml") {return}

		recipe, ok := lib.read_entire_file(file_path)
		assert(ok)
		i := strings.index_any(recipe, ":\r\n")
		recipe_name := recipe[:i]

		file := lib.FileHandle(data)
		line_to_write := fmt.tprintfln("- %v: %v", file_path[4:], recipe_name)
		fmt.print(line_to_write)
		lib.write(file, line_to_write)
	}
}

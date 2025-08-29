# Graphics API (Lua)

This document lists the available **graphics functions** exposed to Lua.
These allow you to draw shapes, render text, and manage colors.

Each function is called directly from Lua, without needing to look into the underlying Odin code.

---

## Functions

### `gfx.draw_rect(x, y, w, h [, mode])`

Draws a rectangle on the screen.

* **x, y**: Position (top-left corner)
* **w, h**: Width and height
* **mode** *(optional)*: `"fill"` (default) or `"line"`

**Example:**

```lua
gfx.draw_rect(100, 50, 200, 80, "line")
```

---

### `gfx.set_color(r, g, b, a)`

Sets the current draw color for shapes.

* **r, g, b**: Red, Green, Blue (0–255)
* **a**: Alpha (0–255)

**Example:**

```lua
gfx.set_color(255, 0, 0, 255) -- solid red
```

---

### `gfx.load_font(filename, size, font_id) -> font_id`

Loads a font for text rendering.

* **filename**: Path to the font file
* **size**: Font size in pixels
* **font\_id**: Identifier to reference the font later

Returns the `font_id` if successful.

**Example:**

```lua
local id = gfx.load_font("assets/Roboto.ttf", 24, "roboto24")
```

---

### `gfx.draw_text(font_id, text, x, y)`

Draws text using a previously loaded font.

* **font\_id**: Font identifier (from `load_font`)
* **text**: String to display
* **x, y**: Screen position

**Example:**

```lua
gfx.draw_text("roboto24", "Hello World!", 50, 100)
```

---

### `gfx.draw_text_colored(font_id, text, x, y, r, g, b, a)`

Draws text with a specific color.

* **font\_id**: Font identifier
* **text**: String to display
* **x, y**: Screen position
* **r, g, b, a**: Text color (0–255)

**Example:**

```lua
gfx.draw_text_colored("roboto24", "Warning!", 50, 100, 255, 0, 0, 255)
```

---

### `gfx.get_text_size(font_id, text) -> width, height`

Returns the size (width and height) of rendered text.

* **font\_id**: Font identifier
* **text**: String to measure
* **Returns**: `width`, `height` (or `nil, nil` if failed)

**Example:**

```lua
local w, h = gfx.get_text_size("roboto24", "Hello")
```

---

### `gfx.set_text_color(r, g, b, a)`

Sets a **global text color** used by text drawing functions.

* **r, g, b, a**: Color values (0–255)

**Example:**

```lua
gfx.set_text_color(0, 255, 0, 255) -- green text
```

---

## Notes

* Always load a font before drawing text. Also, do not load the font on the `draw` or `update` calls. Use it in the `load` function.
* Colors are **RGBA**, with each component in the range `0–255`.
* You can mix `set_color` and `set_text_color` depending on whether you’re drawing shapes or text.

class_name TouchScroll
extends Node
## Lets a finger scroll a ScrollContainer even when it lands on one of its
## buttons. Godot only scrolls when the touch reaches the container itself,
## and rows of tabs or cards are buttons wall to wall, so they did not
## scroll on phones and tablets. A slide past a few pixels scrolls (along
## the directions the container allows); the button under the finger is
## then not pressed. A tap still presses it.
##   TouchScroll.attach($Scroll)

## How far the finger moves before it counts as a scroll, in pixels.
const THRESHOLD := 12.0

var _scroll: ScrollContainer
var _finger := -1
var _start := Vector2.ZERO
var _start_scroll := Vector2.ZERO
var _dragging := false
## A scroll just ended: the mouse release that touch emulates is swallowed.
var _swallow_release := false


static func attach(scroll: ScrollContainer) -> TouchScroll:
	var helper := TouchScroll.new()
	helper._scroll = scroll
	scroll.add_child(helper)
	return helper


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and _scroll.is_visible_in_tree() \
				and _scroll.get_global_rect().has_point(event.position):
			_finger = event.index
			_start = event.position
			_start_scroll = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
			_dragging = false
		elif not event.pressed and event.index == _finger:
			_finger = -1
			_swallow_release = _dragging
			_dragging = false
	elif event is InputEventScreenDrag and event.index == _finger:
		var moved: Vector2 = event.position - _start
		var horizontal := _scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
		var vertical := _scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
		if not _dragging:
			_dragging = (horizontal and absf(moved.x) > THRESHOLD) or (vertical and absf(moved.y) > THRESHOLD)
		if _dragging:
			if horizontal:
				_scroll.scroll_horizontal = int(_start_scroll.x - moved.x)
			if vertical:
				_scroll.scroll_vertical = int(_start_scroll.y - moved.y)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		# The mouse events made from the touch: none of them reach the buttons
		# while scrolling, nor the release that ends it.
		if _dragging and event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
		elif _swallow_release and event is InputEventMouseButton and not event.pressed:
			_swallow_release = false
			get_viewport().set_input_as_handled()

@tool
extends StaticBody2D

func _ready() -> void:
	# Long flat road for launch -> collision -> crate slide
	var surface_points: PackedVector2Array = PackedVector2Array([
		Vector2(0, 500),
		Vector2(3200, 500)
	])
	
	var full_polygon: PackedVector2Array = PackedVector2Array([
		Vector2(0, 500),
		Vector2(3200, 500),
		Vector2(3200, 650),
		Vector2(0, 650)
	])
	
	var col: CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")
	if not col:
		col = CollisionPolygon2D.new()
		col.name = "CollisionPolygon2D"
		add_child(col)
	col.polygon = full_polygon
	
	var fill: Polygon2D = get_node_or_null("Polygon2D")
	if not fill:
		fill = Polygon2D.new()
		fill.name = "Polygon2D"
		add_child(fill)
	fill.polygon = full_polygon
	fill.color = Color("#2b2d42")
	
	var line: Line2D = get_node_or_null("Line2D")
	if not line:
		line = Line2D.new()
		line.name = "Line2D"
		add_child(line)
	line.points = surface_points
	line.width = 6.0
	line.default_color = Color("#4ade80")

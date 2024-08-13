class_name DisasterInfo extends Resource

enum Severity { LOW, MEDIUM, HIGH, VERY_HIGH, YOUR_MOTHER }

@export var display_name: String
@export var icon_texture: Texture2D
@export var severity: Severity

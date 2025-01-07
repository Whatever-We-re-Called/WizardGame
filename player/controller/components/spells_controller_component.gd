class_name SpellsControllerComponent extends Node


func execute_spell(spell_execution: SpellExecution, delta: float):
	spell_execution.process(delta)

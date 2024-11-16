extends HBoxContainer


func setup(player_name: String, player_score: int, goal_score: int):
	%PlayerNameLabel.text = player_name
	
	%ScoreProgressBar.value = player_score
	%ScoreProgressBar.max_value = goal_score
	
	%CurrentPointsLabel.text = str(player_score)
	%GoalPointsLabel.text = str(goal_score)


func update(player_score: int):
	%CurrentPointsLabel.text = str(player_score)

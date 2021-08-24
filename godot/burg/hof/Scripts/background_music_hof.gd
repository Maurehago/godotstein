extends AudioStreamPlayer

func _ready():
	self.play()
	$"../Test/Level_test".connect("body_entered", self, "play_musik")
	$"../Test/Level_test2".connect("body_entered", self, "play_musik")
	if has_node("/root/Level/T1/Level_test"):
		if not $"/root/Level/T1/Level_test".is_connected("body_entered", self, "stop_musik"):
			$"/root/Level/T1/Level_test".connect("body_entered", self, "stop_musik")
	if has_node("/root/Level/T8/Level_test2"):
		if not $"/root/Level/T8/Level_test2".is_connected("body_entered", self, "stop_musik"):
			$"/root/Level/T8/Level_test2".connect("body_entered", self, "stop_musik")

func play_musik(_body):
	if not self.playing:
		self.play()

func stop_musik(_body):
	self.stop()

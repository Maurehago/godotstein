extends AudioStreamPlayer

func _ready():
	$"../Test/Level_test".connect("body_entered", self, "play_musik")
	$"../Test/Level_test2".connect("body_entered", self, "play_musik")
	
func _process(delta):
	if 	$"/root/Level/T1/Level_test" != null:
		if $"/root/Level/T1/Level_test".is_connected("body_entered", self, "stop_musik") == false:
			$"/root/Level/T1/Level_test".connect("body_entered", self, "stop_musik")
	if 	$"/root/Level/T2/Level_test" != null:
		if $"/root/Level/T2/Level_test".is_connected("body_entered", self, "stop_musik") == false:
			$"/root/Level/T2/Level_test".connect("body_entered", self, "stop_musik")

func play_musik(_body):
	if self.playing == false:
		self.play()

func stop_musik(_body):
	self.stop()

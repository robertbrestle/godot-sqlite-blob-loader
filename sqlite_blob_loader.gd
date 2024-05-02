extends Node

var database : SQLite

func open_database():
	$OutputText.text = ""
	database = SQLite.new()
	database.path = $DatabaseText.text
	var result = database.open_db()
	if result == true:
		$OutputText.text += "Database opened"
	else:
		$OutputText.text += "Error opening database"
	return result;


func close_database():
	if database == null:
		$OutputText.text += "Error: database not open"
		return false
	var result = database.close_db()
	if result == true:
		$OutputText.text += "Database closed"
		database = null
	else:
		$OutputText.text += "Error closing database"
	return result


func _on_load_blobs_pressed():
	# open table
	if not open_database():
		return
	
	$OutputText.text = ""
	
	if $TableText.text == "":
		$OutputText.text = "Missing table name. Aborting."
		return
		
	if $ImagePathText.text == "":
		$OutputText.text = "Missing image path field name. Aborting."
		return
	
	# query database
	database.query("select * from characters")
	if database.query_result.size() == 0:
		$OutputText.text = "No records found. Aborting."
		return
		
	#
	var isFileTypePNG = $FileType.button_pressed
	
	$ProgressBar.value = 0
	$ProgressBar.max_value = database.query_result.size()
	print($ProgressBar.max_value)
	var i = 1
	for record in database.query_result:
		i += 1
		
		if record.name == "Hazel":
			var x = 0
		
		# if no imagePath, skip
		if record.imagePath == "":
			$ProgressBar.value += 1
			$OutputText.text += "Missing path: " + record.name + "\n"
			$OutputText.set_caret_line(i)
			continue
		
		# if blob is already set
		if $SkipExisting.button_pressed and str(record.imageBlob) != "":
			$ProgressBar.value += 1
			$OutputText.text += "Skipping: " + record.name + "\n"
			$OutputText.set_caret_line(i)
			continue
		
		# load image
		var image = load(record[$ImagePathText.text])
		var packedByteArray : PackedByteArray
		if (isFileTypePNG):
			packedByteArray = image.get_image().save_png_to_buffer()
		else:
			packedByteArray = image.get_image().save_jpg_to_buffer()
		
		# update row
		database.update_rows($TableText.text, $IdText.text + " = '" + str(record[$IdText.text]) + "'", {$ImageBlobText.text: packedByteArray})
		
		# progress bar and output
		$ProgressBar.value += 1
		$OutputText.text += "Loading: " + record.name + "\n"
		$OutputText.set_caret_line(i)
	
	# close
	close_database()

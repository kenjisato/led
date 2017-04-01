--Select from where you will pick up the pages files
set theFolder to choose folder with prompt "Select folder with original pages files :"
--Do it
tell application "Finder"
	set theNames to name of files of theFolder Â
		whose name extension is "key"
end tell

set pdf_Folder to choose folder with prompt "Select folder where PDF files will go :"

-- How many files to export
set item_count to (get count of items in theNames)

--Get files and export them
repeat with i from 1 to item_count
	
	set current_file to item i of theNames -- get a file
	set lean_file to text 1 thru -5 of current_file & ".pdf" -- change the originalfile (.key) to a .pdf name
	set out_file to (pdf_Folder as Unicode text) & (lean_file) -- get the fully qualified output name
	set in_file to (theFolder as Unicode text) & (current_file) -- get the fully qualified input file name
	
	tell application "Keynote"
		set mydoc to open file in_file -- open input file in Keynote
		export mydoc to file out_file as PDF --do the exporting
		close mydoc saving no -- close the original file without saving
	end tell
	
end repeat


display dialog "done"
'GRABBING STATS----------------------------------------------------------------------------------------------------
name_of_script = "NOTES - BABY BORN.vbs"
start_time = timer

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN		'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF default_directory = "C:\DHS-MAXIS-Scripts\Script Files\" OR default_directory = "" THEN			'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		ELSEIF beta_agency = "" or beta_agency = True then							'If you're a beta agency, you should probably use the beta branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/BETA/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else																		'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message, tells user to try to reach github.com, otherwise instructs to contact Veronica with details (and stops script).
			MsgBox 	"Something has gone wrong. The code stored on GitHub was not able to be reached." & vbCr &_ 
					vbCr & _
					"Before contacting Veronica Cary, please check to make sure you can load the main page at www.GitHub.com." & vbCr &_
					vbCr & _
					"If you can reach GitHub.com, but this script still does not work, ask an alpha user to contact Veronica Cary and provide the following information:" & vbCr &_
					vbTab & "- The name of the script you are running." & vbCr &_
					vbTab & "- Whether or not the script is ""erroring out"" for any other users." & vbCr &_
					vbTab & "- The name and email for an employee from your IT department," & vbCr & _
					vbTab & vbTab & "responsible for network issues." & vbCr &_
					vbTab & "- The URL indicated below (a screenshot should suffice)." & vbCr &_
					vbCr & _
					"Veronica will work with your IT department to try and solve this issue, if needed." & vbCr &_ 
					vbCr &_
					"URL: " & FuncLib_URL
					script_end_procedure("Script ended due to error connecting to GitHub.")
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================

'DIALOGS-------------------------------------------------------------------------------------------------------------
BeginDialog baby_born_dialog, 0, 0, 211, 250, "NOTES - BABY BORN"
  EditBox 60, 5, 80, 15, case_number
  EditBox 60, 25, 95, 15, babys_name
  EditBox 50, 45, 80, 15, date_of_birth
  DropListBox 85, 65, 70, 15, "Select One"+chr(9)+"Yes"+chr(9)+"No", father_in_household
  EditBox 75, 85, 80, 15, fathers_employer
  EditBox 75, 105, 80, 15, mothers_employer
  DropListBox 35, 125, 70, 15, "Select One"+chr(9)+"Yes"+chr(9)+"No", other_health_insurance
  EditBox 115, 145, 80, 15, OHI_source
  EditBox 50, 165, 105, 15, other_notes
  EditBox 55, 185, 105, 15, actions_taken
  EditBox 155, 210, 40, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 95, 230, 50, 15
    CancelButton 150, 230, 50, 15
  Text 5, 5, 55, 15, "Case Number: "
  Text 5, 25, 55, 15, "Baby's Name:"
  Text 5, 45, 45, 15, "Date of Birth:"
  Text 5, 65, 75, 15, "Father In Household?"
  Text 5, 85, 70, 15, "Father's Employer:"
  Text 5, 105, 70, 10, "Mother's Employer: "
  Text 5, 125, 25, 15, "OHI?"
  Text 5, 145, 110, 15, "If yes to OHI, source of the OHI:"
  Text 5, 165, 45, 15, "Other Notes:"
  Text 5, 185, 50, 15, "Actions Taken:"
  Text 90, 210, 65, 15, "Worker Signature:"
EndDialog


'THE SCRIPT---------------------------------------------------------------------------------------------------------------
'connecting to MAXIS
EMConnect ""
'grabbing case number
Call MAXIS_case_number_finder(case_number)

Do
	Dialog baby_born_dialog
	cancel_confirmation
	If case_number = "" then MsgBox "You must have a case number to continue!"
	If worker_signature = "" then MsgBox "You must sign your case note!"
	If father_in_household = "Select One" then MsgBox "You must select 'yes' or 'no' regarding whether or not the father is in the household."
	If other_health_insurance = "Select One" then MsgBox "You must select 'yes' or 'no' to availability of other health insurance." 
Loop until case_number <> "" and worker_signature <> "" and father_in_household <> "Select One" and other_health_insurance <> "Select One"    

'checking to see if still in an active MAXIS session
Call check_for_MAXIS(False)
 
'THE CASE NOTE----------------------------------------------------------------------------------------------------
Call start_a_blank_CASE_NOTE 	'Function to start new case note
call write_variable_in_CASE_NOTE("***Baby Born***")
call write_bullet_and_variable_in_CASE_NOTE("Baby's Name", babys_name)
call write_bullet_and_variable_in_CASE_NOTE("Date of Birth", date_of_birth)
call write_bullet_and_variable_in_CASE_NOTE("Father in Household?", father_in_household)
call write_bullet_and_variable_in_CASE_NOTE("Father's Employer", fathers_employer)
call write_bullet_and_variable_in_CASE_NOTE("Mother's Employer", mothers_employer)
call write_bullet_and_variable_in_CASE_NOTE("Other OHI?", other_health_insurance)
call write_bullet_and_variable_in_CASE_NOTE("Source of OHI", OHI_source)
call write_bullet_and_variable_in_CASE_NOTE("Other Notes", other_notes)
call write_bullet_and_variable_in_CASE_NOTE("Actions Taken", actions_taken)
call write_variable_in_CASE_NOTE("---")
call write_variable_in_CASE_NOTE(worker_signature)

script_end_procedure("")
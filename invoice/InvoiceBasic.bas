REM  *****  BASIC  *****

sub NewInvoice
	on error goto crap
	
	oSheet = ThisComponent.Sheets(0)

	dim invNum as Integer
	dim invMonth as Date
	dim invDate as String
	
    confirmDateAndSave(invNum, invMonth, invDate)

	generateDefaultHours(invMonth)

	exit sub

	crap:
		msgbox("Oops. Error " + Err + ": " + Error$ + " Try again." )

end sub

sub confirmDateAndSave(invNum as Integer, invMonth as Date, invDate as String)
	oSheet = ThisComponent.Sheets(0)
	
	today=Now()
	
	oCell = oSheet.getCellRangeByName("InvoiceNumber")
	invNum = int(right(oCell.String,2))+1
	chosenVal = InputBox("Confirm or change:", "Invoice Number", invNum)
	invNum = CInt(chosenVal)
	oCell.String = "BK-CV-" + Format(invNum,"000")	
	
	chosenVal = InputBox("Confirm or change:", "Invoice Date", Format(today, "dd/mmm/yy"))
	invDate = chosenVal
	oSheet.getCellRangeByName("InvoiceDate").String = invDate

	mnth = Month(today)
	yr = Year(today)
	today_day = Day(today)
	if  (today_day < 15 ) then
		mnth = (mnth + 11) mod 12
		if mnth = 12 then
			yr = yr -1
		end if
	end if
	tmpDate = DateSerial(yr, mnth, 1)
	chosenVal = InputBox("Confirm or change:", "Invoice Month", Format(tmpDate,"MMM")
	tmpDate = DateValue("1 "+chosenVal +" 2000")
	invMonth = DateSerial(yr, Month(tmpDate), 1)
	
	fn = fSaveFile(invNum, invMonth)
	
end sub

Sub generateDefaultHours(invMonth as Date)
	oSheet = ThisComponent.Sheets(0)
	
	first_day = invMonth
	wkday=WeekDay(first_day)
	while (not (wkday = 4 or wkday = 6))
		first_day = DateAdd("d", 1, first_day)
		wkday=WeekDay(first_day)
	wend
	
	oCell = oSheet.getCellRangeByName("FirstDay")
	if isempty(oCell) then exit sub

	mth = Month(invMonth)
	dt = first_day
	do while(Month(dt) = mth)
		row = oCell.CellAddress.Row

		dy = WeekDay(dt)
		if (dy = 4) then 
			' Weds
			hours = 7.5
			desc = "8:30am – 1:00pm  2:00pm – 5:00pm"
			nd = 2
		elseif (dy = 6) then
			' Friday
			hours = 6.5
			desc = "8:30am – 1:00pm  2:00pm – 4:00pm"
			nd = 5
		end if
		oCell.String = Format(dt, "DDD dd MMM YY")
		oSheet.getCellByPosition(2, row).Value = hours
		oSheet.getCellByPosition(3, row).String = desc
		dt = DateAdd("d", nd, dt)

		oCell = oSheet.getCellByPosition(1, row+1)
	loop 
	
End Sub

sub fSaveFile(invNum as Integer, invMonth as Date)
 	BasicLibraries.loadLibrary("Tools")
	dName = DirectoryNameoutofPath(ThisComponent.getURL(), "/")
	fName = dName + "/" + invNum +"-Invoice"+Format(invMonth, "MMMYY")+".xlsm"
	fName2 = inputBox("File to save", "Save As", fName)
	if fName2<>"" then
	   	thisComponent.storeAsURL(fname2, array())
   	end if

   'Set the Dialog Arguments to a Template for FILESAVE
'   sFilePickerArgs = Array(_
'   com.sun.star.ui.dialogs.TemplateDescription.FILESAVE_AUTOEXTENSION )

   'register the Service for Filepicker
   
'   oFilePicker = CreateUnoService( "com.sun.star.ui.dialogs.FilePicker" )

   'Pass some arguments to it

'   With oFilePicker
'      .Initialize( sFilePickerArgs() )
'      .setDisplayDirectory( "C:/" )
'      .appendFilter("XML Files (.xml)", "*.xml" )
'      .setTitle( "Save As ..." )
'   End With

   'If the savepath is selected return the complete path and display it in an messagebox   

'   If oFilePicker.execute() Then
'      sFiles = oFilePicker.getFiles()
'      fSaveFile = sFiles(0)
''      MsgBox( sFileURL )
'

   
'   End If

   ' Close the Dialog
'   oFilePicker.Dispose()
   
End sub

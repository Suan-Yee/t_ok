' Path to the existing Excel file
Dim filePath
filePath = "C:\Suan Yee Aung\automation\detailWork\testing.xlsx" ' Ensure the file extension is correct

' Array of strings
Dim dataArray
dataArray = Array("K08,2,2", "K08,1,1", "K09,2,3", "K09,1,10", "K0D,2,9", "K0D,1,17", _
                  "K0H,2,1", "K0H,1,42", "K14,2,7", "K14,1,3", "K15,2,9", "K15,1,35", _
                  "K44,2,76", "K44,1,1", "K53,2,2", "K53,1,8")

' Create Excel application object
Dim excelApp, workbook, sheet
Set excelApp = CreateObject("Excel.Application")

' Open the existing Excel file
Set workbook = excelApp.Workbooks.Open(filePath)

' Access a specific sheet by name or index
Set sheet = workbook.Sheets("data02.csv")

' Clear the previous content
sheet.Range("F4:G" & sheet.Cells(sheet.Rows.Count, "F").End(-4162).Row).ClearContents ' -4162 is the constant for xlUp

' Initialize variables
Dim currentRow, i, parts, companyCode, lastCompanyCode
currentRow = 4 ' Start from row 4
currentColumn = 6 ' From Column F
lastCompanyCode = ""

' Loop through the array
For i = 0 To UBound(dataArray)
    ' Split the string into parts
    parts = Split(dataArray(i), ",")
    companyCode = parts(0) ' First part is the company code

    ' Check if the company code has changed
    If companyCode <> lastCompanyCode Then
        ' If not the first company, write "break" and skip 2 rows
        If lastCompanyCode <> "" Then
            currentRow = currentRow + 1
            ' sheet.Cells(currentRow, 1).Value = "break" ' Uncomment if you want to write "break"
            currentRow = currentRow + 2
        End If

        ' Write the new company code
        sheet.Cells(currentRow, currentColumn).Value = companyCode

        ' Write static data ("test1" in the next row and "test2" in the next column)
        sheet.Cells(currentRow + 1, currentColumn).Value = "test1"
        sheet.Cells(currentRow + 1, currentColumn + 1).Value = "test2"

        ' Write numeric data
        sheet.Cells(currentRow + 2, currentColumn).Value = parts(1) ' Second part
        sheet.Cells(currentRow + 2, currentColumn + 1).Value = parts(2) ' Third part

        ' Update the last company code
        lastCompanyCode = companyCode

        ' Advance currentRow to the next data row
        currentRow = currentRow + 3
    Else
        ' For the same company code, write data on the next line
        sheet.Cells(currentRow, currentColumn).Value = parts(1) ' Second part
        sheet.Cells(currentRow, currentColumn + 1).Value = parts(2) ' Third part

        ' Advance currentRow for the next data line
        currentRow = currentRow + 1
    End If
Next

' Save changes to the file
workbook.Save

' Close the workbook and quit the Excel application
workbook.Close False
excelApp.Quit

' Release objects
Set sheet = Nothing
Set workbook = Nothing
Set excelApp = Nothing

' Notify user
WScript.Echo "Data written to the Excel file successfully at " & filePath
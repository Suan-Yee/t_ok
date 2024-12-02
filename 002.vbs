' Path to the existing Excel file
Dim filePath
filePath = "C:\VBS\testing.xlsx"

' Array of strings
Dim dataArray
dataArray = Array("K08,2,2", "K08,2,54", "K0D,2,4", "K98,1,43",  "K12,45,22", "K12,11,87","K12,2,4", "K12,1,43", "K11,2,4", "KAB,1,43")

' Create Excel application object
Dim excelApp, workbook, sheet
Set excelApp = CreateObject("Excel.Application")

' Open the existing Excel file
Set workbook = excelApp.Workbooks.Open(filePath)

' Access a specific sheet by name or index
Set sheet = workbook.Sheets("Sheet1")

' Initialize variables
Dim currentRow, i, parts, companyCode, lastCompanyCode
currentRow = 6 ' Start from row 6
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
            sheet.Cells(currentRow, 1).Value = "break"
            currentRow = currentRow + 2
        End If

        ' Write the new company code
        sheet.Cells(currentRow, 1).Value = companyCode

        ' Write static data ("test1" in A7 and "test2" in B7 relative to currentRow)
        sheet.Cells(currentRow + 1, 1).Value = "test1"
        sheet.Cells(currentRow + 1, 2).Value = "test2"

        ' Write numeric data
        sheet.Cells(currentRow + 2, 1).Value = parts(1) ' Second part
        sheet.Cells(currentRow + 2, 2).Value = parts(2) ' Third part

        ' Update the last company code
        lastCompanyCode = companyCode

        ' Advance currentRow to the next data row
        currentRow = currentRow + 3
    Else
        ' For the same company code, write data on the next line
        sheet.Cells(currentRow, 1).Value = parts(1) ' Second part
        sheet.Cells(currentRow, 2).Value = parts(2) ' Third part

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

' Path to the existing Excel file
Dim filePath
filePath = "C:\Suan Yee Aung\automation\code\testing2.xlsx" ' Ensure the file extension is correct

' Array of strings
Dim dataArray
dataArray = Array("K44,null,202410,0", "K08,3,202410,3", "K09,null,202410,0", _
                  "K09,null,202410,0", "K15,16,202410,16", "K14,1179,202410,1179", _
                  "K0D,null,202410,0", "K08,null,202410,0", "K53,null,202410,0")

' Create Excel application object
Dim excelApp, workbook, sheet
Set excelApp = CreateObject("Excel.Application")

' Open the existing Excel file
Set workbook = excelApp.Workbooks.Open(filePath)

' Access a specific sheet by name or index
Set sheet = workbook.Sheets("data07~08.csv")

' Clear the previous content
sheet.Range("G3:S100").ClearContents
sheet.Range("J3:V100").ClearContents
sheet.Range("K3:V100").ClearContents

' Initialize variables
Dim currentRow, i, parts, companyCode, lastCompanyCode
currentRow = 3 ' Start from row 3
currentColumn = 7 ' From Column G
lastCompanyCode = ""

' Loop through the array
For i = 0 To UBound(dataArray)
    ' Split the string into parts
    parts = Split(dataArray(i), ",")
    companyCode = "■" & parts(0) ' First part is the company code

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
        ' Write the new company code in column V
        sheet.Cells(currentRow, currentColumn + 3).Value = companyCode

        ' Write static data
        sheet.Cells(currentRow + 1, currentColumn).Value = "明細からの集計ページ数"
        sheet.Cells(currentRow + 1, currentColumn + 3).Value = "対象年月"
        sheet.Cells(currentRow + 1, currentColumn + 4).Value = "月間累積ページ数"

        ' Write numeric data
        sheet.Cells(currentRow + 2, currentColumn).Value = parts(1) ' Second part
        sheet.Cells(currentRow + 2, currentColumn + 3).Value = parts(2) ' Third part
        sheet.Cells(currentRow + 2, currentColumn + 4).Value = parts(3) ' Fourth part

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
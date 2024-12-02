' Path to the existing Excel file
Dim filePath
filePath = "C:\Suan Yee Aung\automation\code\testing2.xlsx" ' Ensure the file extension is correct

' Array of strings
Dim dataArray
dataArray = Array("K08,115,123232133", "K09,337,66051966", "K14,355,2116866370", _
                  "K15,232,17202000", "K0D,549,200085683", "K44,155,331931327", _
                  "K53,380,36706349", "K0H,33,66207383")

' Create Excel application object
Dim excelApp, workbook, sheet
Set excelApp = CreateObject("Excel.Application")

' Open the existing Excel file
Set workbook = excelApp.Workbooks.Open(filePath)

' Access a specific sheet by name or index
Set sheet = workbook.Sheets("data05~06.csv")

' Clear the previous content
sheet.Range("S30:S100").ClearContents
sheet.Range("V30:V100").ClearContents

' Initialize variables
Dim currentRow, i, parts, companyCode, lastCompanyCode
currentRow = 30 ' Start from row 30
currentColumn = 19 ' From Column S
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
        ' Write the new company code in column V
        sheet.Cells(currentRow, currentColumn + 3).Value = companyCode

        ' Write static data
        sheet.Cells(currentRow + 1, currentColumn).Value = "月間利用帳票数"
        sheet.Cells(currentRow + 1, currentColumn + 3).Value = "累計ページ数2011"

        ' Write numeric data
        sheet.Cells(currentRow + 2, currentColumn).Value = parts(1) ' Second part
        sheet.Cells(currentRow + 2, currentColumn + 3).Value = parts(2) ' Third part

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
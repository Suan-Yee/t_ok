' Function to process data and write to Excel
Sub setStaticDate(sheet, sheetName,currentRow,currentColumn)
    If sheetName = "data02.csv" Then
        sheet.Cells(currentRow + 1, currentColumn).Value = "権限レベル"
        sheet.Cells(currentRow + 1, currentColumn + 1).Value = "登録数"
    ElseIf sheetName = "data05~06.csv" Then
        sheet.Cells(currentRow + 1, currentColumn).Value = "月間利用帳票数"
        sheet.Cells(currentRow + 1, currentColumn + 3).Value = "累計ページ数2011"
    ElseIf sheetName = "data07~08.csv" Then
        sheet.Cells(currentRow + 1, currentColumn).Value = "明細からの集計ページ数"
        sheet.Cells(currentRow + 1, currentColumn + 3).Value = "対象年月"
        sheet.Cells(currentRow + 1, currentColumn + 4).Value = "月間累積ページ数"
    End If
End Sub

Sub ClearRanges(sheet, sheetName)
    If sheetName = "data02.csv" Then
        ' Clear the previous content
        ' sheet.Range("F4:G" & sheet.Cells(sheet.Rows.Count, "F").End(100).Row).ClearContents
    ElseIf sheetName = "data05~06.csv" Then
        ' Clear the previous content
        sheet.Range("S30:S100").ClearContents
        sheet.Range("V30:V100").ClearContents
    ElseIf sheetName = "data07~08.csv" Then
        ' Clear the previous content
        sheet.Range("G3:S100").ClearContents
        sheet.Range("J3:V100").ClearContents
        sheet.Range("K3:V100").ClearContents
    End If
End Sub

Sub ProcessData(filePath, sheetName, dataArray, startRow, startColumn)
    ' Create Excel application object
    Dim excelApp, workbook, sheet
    Set excelApp = CreateObject("Excel.Application")
    
    ' Open the existing Excel file
    Set workbook = excelApp.Workbooks.Open(filePath)
    
    ' Access a specific sheet by name or index
    Set sheet = workbook.Sheets(sheetName)
    
    ' Clear the previous content
    Call ClearRanges(sheet, sheetName)
    
    ' Initialize variables
    Dim currentRow, i, parts, companyCode, lastCompanyCode
    currentRow = startRow ' Start from the specified row
    currentColumn = startColumn ' From the specified column
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
            End If
            
            ' Write the new company code
            sheet.Cells(currentRow, currentColumn).Value = companyCode
            
            If sheetName <> "data02.csv" Then
                ' Write the new company code in column V
                sheet.Cells(currentRow, currentColumn + 3).Value = companyCode
            End If
            
            ' Write static data
            Call setStaticDate(sheet, sheetName,currentRow,currentColumn)
            
            ' Write numeric data
            sheet.Cells(currentRow + 2, currentColumn).Value = parts(1) ' Second part
            
            If sheetName <> "data02.csv" Then
                sheet.Cells(currentRow + 2, currentColumn + 3).Value = parts(2) ' Third part
            Else
                sheet.Cells(currentRow + 2, currentColumn + 1).Value = parts(2) ' Third part
            End If
            
            If sheetName = "data07~08.csv" Then
                sheet.Cells(currentRow + 2, currentColumn + 4).Value = parts(3) ' Fourth part
            End If
            
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
End Sub

' Main script execution

' First dataset
Dim filePath, sheetName1, dataArray1
filePath = "C:\Suan Yee Aung\automation\code\testing3.xlsx"
sheetName1 = "data02.csv"
dataArray1 = Array("K08,2,2", "K08,1,1", "K09,2,3", "K09,1,10", "K0D,2,9", "K0D,1,17", "K0H,2,1", "K0H,1,42", "K14,2,7", "K14,1,3", "K15,2,9", "K15,1,35", "K44,2,76", "K44,1,1", "K53,2,2", "K53,1,8")

' Process the first dataset
Call ProcessData(filePath, sheetName1, dataArray1, 4, 6)

' Second dataset
Dim sheetName2, dataArray2
sheetName2 = "data05~06.csv"
dataArray2 = Array("K08,115,123232133", "K09,337,66051966", "K14,355,2116866370", "K15,232,17202000", "K0D,549,200085683", "K44,155,331931327", "K53,380,36706349", "K0H,33,66207383")

' Process the second dataset
Call ProcessData(filePath, sheetName2, dataArray2, 30, 19)

' Third dataset
Dim sheetName3, dataArray3
sheetName3 = "data07~08.csv"
dataArray3 = Array("K44,null,202410,0", "K08,3,202410,3", "K09,null,202410,0", "K09,null,202410,0", "K15,16,202410,16", "K14,1179,202410,1179", "K0D,null,202410,0", "K08,null,202410,0", "K53,null,202410,0")

' Process the third dataset
Call ProcessData(filePath, sheetName3, dataArray3, 3, 7)

' Notify user
WScript.Echo "Data written to the Excel file successfully at " & filePath
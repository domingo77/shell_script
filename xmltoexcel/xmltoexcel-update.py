#coding=utf-8
from xml.etree import ElementTree
from win32com.client import Dispatch
import win32com.client
import sys,os

def ChangeReturnKeyInString(str):
    print("str:[",str,"]")
    retStr = ""
    if str is None:
        print("str:[", str, "]")
        retStr = "no"
    else:
        retStr = str.strip().replace('<p>','')
        retStr = retStr.replace('</p>','\n')
    print("final retStr:[",retStr,"]")
    return retStr

def ExecutionTypeMapInString(str):
    print("str:[",str,"]")
    retStr = ""
    if str == "1" :
        retStr = "Manual"
    elif str == "2" :
        retStr = "Automated"
    print("final execution_type:[",retStr,"]")
    return retStr
class easy_excel:
    def __init__(self,filename=None):
        self.xlApp=win32com.client.Dispatch('Excel.Application')
        if filename:
            self.filename=filename
            self.xlBook=self.xlApp.Workbooks.Open(self.filename)
        else:
            self.xlBook=self.xlApp.Workbooks.Add()
            self.filename=''
    def save(self,newfilename=None):
        if newfilename:
            self.filename=newfilename
            self.xlBook.SaveAs(newfilename)
        else:
            self.xlBook.Save()

    def close(self):
        self.xlBook.Close(SaveChanges=0)
    def getCell(self,sheet,row,col):
        sht=self.xlBook.Worksheets(sheet)
        return sht.Cell(row,col).Value
    def setCell(self,sheet,row,col,value):
        sht=self.xlBook.Worksheets(sheet)
        sht.Cells(row,col).Value=value
        sht.Cells(row,col).HorizontalAlignment=3
        sht.Rows(row).WrapText=True
    def mergeCells(self,sheet,row1,col1,row2,col2):
        sht=self.xlBook.Worksheets(sheet)
        sht.Range(sht.Cells(row1,col1),sht.Cells(row2,col2)).Merge()
    def setBorder(self,sheet,row,col):
        sht=self.xlBook.Worksheets(sheet)
        sht.Cells(row,col).Borders.LineStyle=1
    def set_col_width(self,sheet):
        sht=self.xlBook.Worksheets(sheet)
        sht.Columns("E:H").ColumnWidth=30
 
if __name__ =='__main__':   
    if (len(sys.argv) == 1):
        print("Please specified a xml file")
        os.system("pause")
        sys.exit(0)
    else:
        tmpInFile = os.getcwd()+"\\"+sys.argv[1]
        inFile = tmpInFile
        if not tmpInFile.endswith(".xml"):
            outFile = tmpInFile + "-tcexp.xlsx"
            inFile  = tmpInFile + ".xml"
        else:
            outFile =  tmpInFile[:-4] +"-tcexp.xlsx"
            
        
    xls=easy_excel()
    xls.setCell('Sheet1',1,1,u"一级目录")
    xls.setCell('Sheet1',1,2,u"二级目录")
    xls.setCell('Sheet1',1,3,u"用例名称")
    xls.setCell('Sheet1',1,4,u"用例编号")
    xls.setCell('Sheet1',1,5,u"用例概要说明")
    xls.setCell('Sheet1',1,6,u"预置条件")
    xls.setCell('Sheet1',1,7,u"操作步骤")
    xls.setCell('Sheet1',1,8,u"预期结果")
    xls.setCell('Sheet1',1,9,u"prefix-id")
    xls.setCell('Sheet1',1,10,u"Auto_or_Manual")
    xls.set_col_width('Sheet1')
    
    tree=ElementTree.parse(inFile)
    root = tree.getroot()

    row_flag=1
    #一级目录
    for sub1Testsuite in root.findall("testsuite"):
        sub1SuiteId = sub1Testsuite.get("id")
        sub1SuiteName = sub1Testsuite.get("name")
        print("sub1SuiteName:[",sub1SuiteName,"]")
        for sub1TestCase in sub1Testsuite.findall("testcase"):
            row_flag = row_flag + 1
            sub2SuiteName = ""
            title = sub1TestCase.get("name")
            print("sub1TestCase.title:[",title,"]")
            externalid = sub1TestCase.find("externalid").text
            fullexternalid = sub1TestCase.find("fullexternalid").text
            print("fullexternalid:[",fullexternalid,"]")
            summary = ChangeReturnKeyInString(sub1TestCase.find("summary").text)
            print("sub1TestCase:[",sub1TestCase,"]")
            preconditions = ChangeReturnKeyInString(sub1TestCase.find("preconditions").text)
            execution_type = ExecutionTypeMapInString(sub1TestCase.find("execution_type").text)
            print("execution_type:[",execution_type,"]")

            xls.setCell('Sheet1',row_flag,1,sub1SuiteName)
            xls.setCell('Sheet1',row_flag,2,sub2SuiteName)
            xls.setCell('Sheet1',row_flag,3,title)
            xls.setCell('Sheet1',row_flag,4,externalid)
            xls.setCell('Sheet1',row_flag,5,summary)
            xls.setCell('Sheet1',row_flag,6,preconditions)
            stepsNode=sub1TestCase.find("steps")
            actions = ""
            expectedresults = ""
            if stepsNode is None:
                print("stepsNode is None")
            else:
                for stepNode in stepsNode.findall("step"):
                    print("stepNode:[",stepNode,"]")
                    step_number = stepNode.find('step_number').text
                    actions = actions+stepNode.find('actions').text.strip()
                    if stepNode.find('expectedresults').text is None:
                        print("stepNode.find('expectedresults').text is None")
                    else:
                        expectedresults = expectedresults + stepNode.find('expectedresults').text.strip()
                actions = ChangeReturnKeyInString(actions)
                expectedresults = ChangeReturnKeyInString(expectedresults)
            xls.setCell('Sheet1',row_flag,7,actions)
            xls.setCell('Sheet1',row_flag,8,expectedresults)
            xls.setCell('Sheet1',row_flag,9,fullexternalid)
            xls.setCell('Sheet1',row_flag,10,execution_type)

        for sub2Testsuite in sub1Testsuite.findall("testsuite"):
            sub2SuiteId = sub2Testsuite.get("id")
            sub2SuiteName = sub2Testsuite.get("name")      
            for sub2TestCase in sub2Testsuite.findall("testcase"):
                row_flag = row_flag + 1
                title = sub2TestCase.get("name")
                externalid = sub2TestCase.find("externalid").text
                fullexternalid = sub2TestCase.find("fullexternalid").text
                summary = ChangeReturnKeyInString(sub2TestCase.find("summary").text)
                preconditions = ChangeReturnKeyInString(sub2TestCase.find("preconditions").text)
                execution_type = ExecutionTypeMapInString(sub2TestCase.find("execution_type").text)
                print("execution_type:[", execution_type, "]")

                xls.setCell('Sheet1',row_flag,1,sub1SuiteName)
                xls.setCell('Sheet1',row_flag,2,sub2SuiteName)
                xls.setCell('Sheet1',row_flag,3,title)
                xls.setCell('Sheet1',row_flag,4,externalid)
                xls.setCell('Sheet1',row_flag,5,summary)  
                xls.setCell('Sheet1',row_flag,6,preconditions)    
                actions = ""
                expectedresults = ""            
                stepsNode=sub2TestCase.find("steps")
                if stepsNode is None:
                    print("stepsNode is None")
                else:
                    for stepNode in stepsNode.findall("step"):
                        step_number = stepNode.find('step_number').text
                        actions =actions + stepNode.find('actions').text
                        if stepNode.find('expectedresults').text is None:
                            print("stepNode.find('expectedresults').text is None")
                        else:
                            expectedresults = expectedresults + stepNode.find('expectedresults').text.strip()
                    actions = ChangeReturnKeyInString(actions)
                    expectedresults = ChangeReturnKeyInString(expectedresults)
                xls.setCell('Sheet1',row_flag,7,actions)
                xls.setCell('Sheet1',row_flag,8,expectedresults)
                xls.setCell('Sheet1',row_flag,9,fullexternalid)
                xls.setCell('Sheet1',row_flag,10,execution_type)

    for row in range(2,row_flag):
        for col in range(1,11):
            xls.setBorder('Sheet1',row,col)    
    xls.save(outFile)
    xls.close()
    
    print("finished.")
    sys.exit(0)
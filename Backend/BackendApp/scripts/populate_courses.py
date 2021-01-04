

# run 'python manage.py shell<BackendApp/scripts/populate_courses.py'
# in CLI

from BackendApp.models import *
import openpyxl
from datetime import datetime


numRows = 518
numCols = 6 # "F"

# reading excel file from https://www.pythoncircle.com/post/591/how-to-upload-and-process-the-excel-file-in-django/

loc = ("BackendApp/staticfiles/S19_Course_List.xlsx")

wb = openpyxl.load_workbook(loc)
# getting a particular sheet by name out of many sheets
worksheet = wb.active

print(worksheet["A1"].value)

updated = worksheet["F1"].value

# iterating over the rows and
# getting value from each cell in row
for row in range(2,numRows):
    row_data = list()
    i = 0
    for column in range(numCols):
        x = str(1+row)
        y = chr(ord("A") + column)
        cell = worksheet["" + y + x]
        row_data.append(str(cell.value))
    new_course = Course(title=row_data[0], period=row_data[1], teacher=row_data[2], section=row_data[3],
                         room=row_data[4], days=row_data[5], updated=updated)
    new_course.save()

print("COMPLETED: " + str(datetime.now().time()))

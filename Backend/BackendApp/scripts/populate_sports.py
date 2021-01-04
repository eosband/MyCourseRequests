

# run 'python manage.py shell<BackendApp/scripts/populate_sports.py'
# in CLI

from BackendApp.models import *
import openpyxl
from datetime import datetime


numRows = 34
numCols = 4 # "D"

# reading excel file from https://www.pythoncircle.com/post/591/how-to-upload-and-process-the-excel-file-in-django/

loc = ("BackendApp/staticfiles/Sports.xlsx")

wb = openpyxl.load_workbook(loc)
# getting a particular sheet by name out of many sheets
worksheet = wb.active

print(worksheet["A1"].value)

updated = worksheet["F1"].value

# iterating over the rows and
# getting value from each cell in row
row = 2
while worksheet["A" + str(row)].value:
    row_data = list()
    i = 0
    for column in range(numCols):
        x = str(row)
        y = chr(ord("A") + column)
        cell = worksheet["" + y + x]
        row_data.append(str(cell.value))
    print(row_data[0])
    new_sport = Sport(title=row_data[0], description=row_data[1], days=row_data[2], teacher=row_data[3])
    new_sport.save()
    row += 1


print("COMPLETED: " + str(datetime.now().time()))

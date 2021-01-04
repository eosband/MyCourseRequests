import django.contrib.auth
from django.shortcuts import render
from django.views import View
from django.http import HttpResponse, JsonResponse, QueryDict
from django.urls import include, path
from rest_framework import routers
from BackendApp.models import *
from django.contrib.auth import login, logout
from django.contrib.auth import authenticate
#from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from datetime import datetime


# request data will be storied in request's body
def welcome(request):
    return HttpResponse("Welcome")

# handle all requests at .../loginStudent/
def auth_login(request):
    # Only POSTing to .../loginStudent/
    # from https://stackoverflow.com/questions/29780060/trying-to-parse-request-body-from-post-in-django

    if request.method == "POST":
        content = QueryDict(request.body.decode('utf-8')).dict() # content should be dict now
        student = django.contrib.auth.authenticate(username=content["username"], password=content["password"])
        if student:
            login(request,student) #django's built in
            # serializer = serializers.UserSerializer(user)
            # print(serializer)
            date = datetime.date()
            if 3 <= date.month <= 9:
                term = "Fall '" + str(date.year%100)
            elif 10 <= date.month <= 12:
                term = "Winter '" + str((date.year + 1)%100)
            else:
                term = "Spring '" + str(date.year%100)
            return JsonResponse({'status':'true','message':"Logged in", "hash_id":student.hash_id, "name":student.firstName + student.lastName, "term":term}, status=200)

        return JsonResponse({'status':'false','message':"Invalid username and/or password"}, status=406)


# handle all requests at .../newStudent/
def newStudent(request):
     # Only POST
    content = QueryDict(request.body.decode('utf-8')).dict() #access content from request

    try:
        firstName = content["firstName"]
        lastName = content["lastName"]
        username = content["studentEmail"]
        advisorEmail = content["advisorEmail"]
        password = content["password"]
    except:
        return JsonResponse({'status':'false', 'message':"Could not parse params dictionary"}, status=401)

    if request.method == "POST":
        if Students.objects.filter(username = username).exists():
            return JsonResponse({'status':'false','message':"This student email is already in use"}, status=406)
        try:
            new_student = Student(firstName = firstName, lastName = lastName, username = username,
                                    advisorEmail = advisorEmail)
            new_student.set_password(password)
        except:
            return JsonResponse({'status':'false', 'message':"Could not create account, please try again"}, status=406)
        # serializer = serializers.UserSerializer(new_user)
        new_student.save()
        return JsonResponse({'status':'true', 'message':"Your account has been created, please login", "hash_id": new_student.hash_id}, status=201) #201 -> new resource created

# WE MAY WANT TO UNCOMMENT THIS LATER, BUT FOR NOW WE NEED IT GONE
# @login_required # so that someone cannot access this method without having logged in
def handleData(request):
    # print(request.META)
    # hash_id = request.student.hash_id
    # Decode request body content
    content = QueryDict(request.body.decode('utf-8')).dict()
    if request.method == "GET":
        courses = {}
        sports = {}
        # Music lessons are text boxes filled in by user after they have spoken w/ music department

        # Propogate memories to return to frontend
        for course in Course.objects.all():
            courses[course.id] = {"title": course.title, "period": course.period, "teacher": course.teacher, "section": course.section, "room": course.room, "days": course.days}

        for sport in Sport.objects.all():
            sports[sport.id] = {"title": sport.title, "description": sport.description, "days": sport.days, "teacher": sport.teacher}

        data = {'status':'true', 'message':"Got GOT", 'courses':courses, 'sports':sports}

        # Return data to frontend
        return JsonResponse(data, status=200)

@login_required
def handleCourseRequests(request):

    hash_id = request.user.hash_id

    if request.method == "GET":
        data = {}

        # Propogate memories to return to frontend
        for courseRequest in CourseRequest.objects.filter(hash_id = hash_id):
            data[courseRequest.id] = {"courses": courseRequest.courses, "topPriority": courseRequest.topPriority, "sport": courseRequest.sport, "musicLesson": courseRequest.musicLesson, "comments": courseRequest.comments}

        # Return data to frontend
        return JsonResponse(data, status=200)

    if request.method == "POST":
        # Decode request body content
        content = QueryDict(request.body.decode('utf-8')).dict()

        # Determine a string representation of the term
        date = datetime.date()
        if 3 <= date.month <= 9:
            term = "Fall '" + str(date.year%100)
        elif 10 <= date.month <= 12:
            term = "Winter '" + str((date.year + 1)%100)
        else:
            term = "Spring '" + str(date.year%100)


        try:
            coursesString = content["courses"] # should be an array of the courses' IDs
            courses = []
            num = ""
            count = 0
            # parse string array, will look like "[[-1, 2, 3], [4, 5, 6]]"
            tempCourses = []
            for char in coursesString:
                if char == '[':
                    count += 1
                if char == ']':
                    courses.append(tempCourses)
                    tempCourses = []
                    count -= 1
                elif char.isdigit() or char == "-":
                    num += char
                elif char == ',' and count > 1:
                    tempCourses.append(int(num))
                    num = ""

            sixthCourse = int(content["sixthCourse"])
            topPriority = int(content["topPriority"])

            sport = content["sport"] # should be the sport's ID
            mL = content["musicLesson"] # should be a dict in the proper musiclesson format
            comments = content["comments"]
        except:
            return JsonResponse({'status':'false', 'message':"Unable to parse dictionary of params"}, status=401)

        try:
            musicLesson = MusicLession(instrument=mL["instrument"], teacher=mL["teacher"],length=mL["length"])
            musicLesson.save()
        except:
            musicLesson = -1
            return JsonResponse({'status':'false', 'message':"Unable to process music lesson"}, status=401)

        # Create a CourseRequest object and save its reference to access id
        try:
            courseRequest = CourseRequest(hash_id = hash_id, term = term, courses = courses, topPriority = topPriority, sport = sport, musicLesson = musicLesson.id, comments = comments)
            courseRequest.save()
        except:
            return JsonResponse({'status':'false', 'message':"Unable to save course request"}, status=401)

        returning = JsonResponse({'status':'true', 'message':"Your course request has been POSTed"}, status=200)

def auth_logout(request):
    logout(request)

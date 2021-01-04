from django.db import models
from django.conf import settings
from decimal import Decimal
from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField
import urllib
import json
from . import helper # we created this

# The Student model. The student_id is automatically generated
class Student(AbstractUser):

    hash_id = models.CharField(max_length=32, default=helper.create_hash, unique=True)

    firstName = models.CharField(max_length=30, default="none")
    lastName = models.CharField(max_length=30, default="none")
    advisorEmail = models.CharField(max_length=30, default="none")

    # studentEmail and password already in AbstractUser
        # studentEmail is called username
    # for printing a Student object
    def __str__(self):
        return self.username + " name: " + self.firstName + " " + self.lastName + ""

class Course(models.Model):
    title = models.CharField(max_length=90, default="none")
    period = models.CharField(max_length=30, default="none")
    teacher = models.CharField(max_length=30, default="none")
    section = models.CharField(max_length=30, default="none")
    room = models.CharField(max_length=30, default="none")
    days = models.CharField(max_length=30, default="none")
    updated = models.CharField(max_length=60, default="unknown")
    # for printing a Course object
    def __str__(self):
        return self.title + " (" + self.id + ")"

# Sports, like courses, should be a dropdown of sports offered
class Sport(models.Model):
    title = models.TextField()
    description = models.TextField()
    days = models.TextField()
    teacher = models.TextField()
    def __str__(self):
        return self.title + " (" + self.description + ")"


# Music lessons should be custom-filled out by user after they have talked to music department
class MusicLesson(models.Model):
    instrument = models.CharField(max_length=45, default="none")
    teacher = models.CharField(max_length=60, default="none")
    length = models.CharField(max_length=30, default="none")
    def __str__(self):
        return self.instrument + " (" + self.teacher + " | length: " + self.length + ")"

class CourseRequest(models.Model):
    # OneToOneField not allowed within ArrayField, thus 2D Array of CharField stores courses
    hash_id = models.CharField(max_length=32)
    term = models.CharField(max_length=30, default="Fall '19")
    courses = ArrayField(ArrayField(models.IntegerField(default=-1)))
    #courses = ArrayField(ArrayField(models.CharField(max_length=30, default="none"))) # ArrayFields from https://stackoverflow.com/questions/44630642/its-possible-to-store-an-array-in-django-model
    # should correspond to the id of the course
    topPriority = models.IntegerField(default=-1)
    sixthCourse = models.IntegerField(default=-1) #models.OneToOneField(Course, on_delete=models.PROTECT)
    # should correspond to the id of the sport
    sport = models.IntegerField(default=-1)
    # should correspond to the id of the music lesson
    musicLesson = models.IntegerField(default=-1)
    comments = models.TextField()
    def __str(self):
        return self.hash_id

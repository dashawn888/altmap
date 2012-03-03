from django.db import models

class Hash(models.Model):
  # stores the sha1 of the cordinate tuples.  Used to test if a route has been
  # used before
  hash = models.CharField(max_length=40)

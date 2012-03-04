import json

from django.http import HttpResponse
from django.template import Context, loader
from route.models import Hash

# Create your views here.
def Index(request):
  t = loader.get_template('route/home.html')
  return HttpResponse(t.render(Context({})))

def IsRouteUsed(request, hash_arg):

  for hash_object in Hash.objects.all():
    if hash_object.hash == hash_arg:
      return HttpResponse(json.dumps({"Used": True}), mimetype="application/json")

  Hash(hash=hash_arg).save()
  return HttpResponse(json.dumps({"Used": False}), mimetype="application/json")

def ClearRoutes(request):

  for hash_object in Hash.objects.all():
    Hash.delete(hash_object)

  return HttpResponse("Cleared")

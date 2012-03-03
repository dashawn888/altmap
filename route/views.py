from django.http import HttpResponse
from django.template import Context, loader
from route.models import Hash

# Create your views here.
def Index(request):
  t = loader.get_template('route/home.html')
  return HttpResponse(t.render(Context({})))

def IsRouteUsed(request, hash):
  return HttpResponse("Your Hash is %s" % hash)

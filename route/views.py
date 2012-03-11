"""Control the views for route."""
import json

from django.http import HttpResponse
from django.template import Context, loader
from route.models import Hash

# Create your views here.
def index(_):
    """Provide the default view for route."""
    template = loader.get_template('route/home.html')
    return HttpResponse(template.render(Context({})))

def is_route_used(_, hash_arg):
    """Return a json object if a route is used or not."""
    for hash_object in Hash.objects.all():
        if hash_object.hash == hash_arg:
            return HttpResponse(
                json.dumps({"Used": True}), mimetype="application/json")

    Hash(hash=hash_arg).save()
    return HttpResponse(
        json.dumps({"Used": False}), mimetype="application/json")

def clear_routes(_):
    """Clear the routes."""
    for hash_object in Hash.objects.all():
        Hash.delete(hash_object)

    return HttpResponse("Cleared")

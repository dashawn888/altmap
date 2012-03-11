from django.conf.urls.defaults import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'route.views.index'),
    url(r'^IsRouteUsed/(?P<hash_arg>.+)$', 'route.views.is_route_used'),
    url(r'^ClearRoutes', 'route.views.clear_routes'),
)

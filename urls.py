from django.conf.urls.defaults import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'route.views.Index'),
    url(r'^IsRouteUsed/(?P<hash>.+)$', 'route.views.IsRouteUsed'),
    url(r'^ClearRoutes', 'route.views.ClearRoutes'),
)

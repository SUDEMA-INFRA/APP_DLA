from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import VistoriaViewSet

router = DefaultRouter()
router.register(r'', VistoriaViewSet, basename='vistoria')

urlpatterns = [
    path('', include(router.urls)),
]

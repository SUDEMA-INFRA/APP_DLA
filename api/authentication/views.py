from .models import CustomUser
from rest_framework import generics, permissions
from .serializers import RegisterSerializer

class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    permission_classes = (permissions.IsAdminUser,)
    serializer_class = RegisterSerializer

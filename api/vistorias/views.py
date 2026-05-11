from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Vistoria, Municipio
from .serializers import VistoriaSerializer, MunicipioSerializer

class MunicipioViewSet(viewsets.ModelViewSet):
    serializer_class = MunicipioSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Municipio.objects.all()

class VistoriaViewSet(viewsets.ModelViewSet):
    serializer_class = VistoriaSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_staff:
            return Vistoria.objects.all()
        return Vistoria.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        local_id = request.data.get('local_id')
        
        # Lógica de idempotência: Verifica se já existe uma vistoria com este id para este usuário
        if local_id:
            existing = Vistoria.objects.filter(user=request.user, id=local_id).first()
            if existing:
                serializer = self.get_serializer(existing)
                return Response(serializer.data, status=status.HTTP_200_OK)
            
        return super().create(request, *args, **kwargs)

    @action(detail=False, methods=['get'], url_path='users/(?P<user_id>[^/.]+)')
    def by_user(self, request, user_id=None):
        vistorias = Vistoria.objects.filter(user_id=user_id)
        serializer = self.get_serializer(vistorias, many=True)
        return Response(serializer.data)

from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from .models import Vistoria
from .serializers import VistoriaSerializer

class VistoriaViewSet(viewsets.ModelViewSet):
    serializer_class = VistoriaSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Vistoria.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        local_id = request.data.get('local_id')
        
        # Lógica de idempotência: Verifica se já existe uma vistoria com este local_id para este usuário
        existing = Vistoria.objects.filter(user=request.user, local_id=local_id).first()
        if existing:
            serializer = self.get_serializer(existing)
            return Response(serializer.data, status=status.HTTP_200_OK)
            
        return super().create(request, *args, **kwargs)

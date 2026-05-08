from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
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
        return Vistoria.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        local_id = request.data.get('local_id')
        
        # Lógica de idempotência: Verifica se já existe uma vistoria com este local_id para este usuário
        if local_id:
            existing = Vistoria.objects.filter(user=request.user, local_id=local_id).first()
            if existing:
                serializer = self.get_serializer(existing)
                return Response(serializer.data, status=status.HTTP_200_OK)
            
        return super().create(request, *args, **kwargs)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


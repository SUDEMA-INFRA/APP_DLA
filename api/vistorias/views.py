from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import transaction, IntegrityError
from .models import Vistoria, Municipio
from .serializers import VistoriaSerializer, VistoriaListSerializer, MunicipioSerializer

class MunicipioViewSet(viewsets.ModelViewSet):
    serializer_class = MunicipioSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Municipio.objects.all()

class VistoriaViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'list':
            return VistoriaListSerializer
        return VistoriaSerializer

    def get_queryset(self):
        queryset = Vistoria.objects.select_related(
            'municipio', 'user', 'supressao', 'avicultura',
            'suinocultura', 'bovinocultura', 'aquicultura',
            'sucroalcooleiro', 'agricultura'
        )
        if self.request.user.is_staff:
            return queryset.all()
        return queryset.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        local_id = request.data.get('local_id') or request.data.get('id')
        
        # Lógica de idempotência: Verifica se já existe uma vistoria com este id para este usuário
        if local_id:
            existing = Vistoria.objects.filter(user=request.user, id=local_id).first()
            if existing:
                serializer = self.get_serializer(existing)
                return Response(serializer.data, status=status.HTTP_200_OK)
            
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            with transaction.atomic():
                self.perform_create(serializer)
        except IntegrityError:
            # Caso concorrência ocorra e outro thread tenha inserido o mesmo UUID
            if local_id:
                existing = Vistoria.objects.filter(user=request.user, id=local_id).first()
                if existing:
                    serializer = self.get_serializer(existing)
                    return Response(serializer.data, status=status.HTTP_200_OK)
            raise

        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        
        # Capture old state for diff
        old_serializer = self.get_serializer(instance)
        old_data = old_serializer.data
        
        # Standard update for root model
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        
        with transaction.atomic():
            self.perform_update(serializer)
            
            # Handle dynamic SubModel update
            tipo = request.data.get('data', {}).get('tipo') or request.data.get('tipo')
            if tipo:
                from .factories import VistoriaSubModelFactory
                
                nested_data = request.data.get('data', {})
                if not isinstance(nested_data, dict):
                    nested_data = {}
                merged_source = {**request.data, **nested_data}
                
                # Normalize keys
                normalized_source = {}
                for k, v in merged_source.items():
                    norm_k = k.replace('qnt_', 'qtd_').replace('quantidade_', 'qtd_')
                    normalized_source[norm_k] = v
                    
                VistoriaSubModelFactory.update_sub_model(instance, tipo, normalized_source)

        # Reload instance
        instance.refresh_from_db()
        new_serializer = self.get_serializer(instance)
        new_data = new_serializer.data
        
        # Generate Diff and AuditLog
        diff_json = self._generate_diff(old_data, new_data)
        if diff_json:
            from .models import AuditLog
            AuditLog.objects.create(
                user=request.user,
                action='UPDATE',
                entity_type='Vistoria',
                entity_id=instance.id,
                diff_json=diff_json
            )

        return Response(new_data)

    def _generate_diff(self, old_data, new_data):
        diff = {}
        for key in new_data:
            # Ignore auto fields
            if key in ['synced_at', 'updated_at', 'created_at']:
                continue
                
            if isinstance(new_data[key], dict) and isinstance(old_data.get(key, {}), dict):
                nested_diff = {}
                old_nested = old_data.get(key, {})
                for n_key in new_data[key]:
                    if new_data[key].get(n_key) != old_nested.get(n_key):
                        nested_diff[n_key] = {'from': old_nested.get(n_key), 'to': new_data[key].get(n_key)}
                if nested_diff:
                    diff[key] = nested_diff
            elif new_data.get(key) != old_data.get(key):
                diff[key] = {'from': old_data.get(key), 'to': new_data.get(key)}
        return diff

    @action(detail=False, methods=['get'], url_path='users/(?P<user_id>[^/.]+)')
    def by_user(self, request, user_id=None):
        vistorias = Vistoria.objects.filter(user_id=user_id)
        serializer = self.get_serializer(vistorias, many=True)
        return Response(serializer.data)

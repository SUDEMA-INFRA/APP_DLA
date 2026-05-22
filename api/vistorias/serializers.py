from rest_framework import serializers
from .models import (
    Vistoria, Municipio, VistoriaSupressao, VistoriaAvicultura,
    VistoriaSuinocultura, VistoriaBovinocultura, VistoriaAquicultura,
    VistoriaSucroalcooleiro, VistoriaAgricultura, Foto, AuditLog
)

class MunicipioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Municipio
        fields = ('id', 'nome')

class VistoriaSupressaoSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaSupressao
        fields = '__all__'

class VistoriaAviculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAvicultura
        fields = '__all__'

class VistoriaSuinoculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaSuinocultura
        fields = '__all__'

class VistoriaBovinoculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaBovinocultura
        fields = '__all__'

class VistoriaAquiculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAquicultura
        fields = '__all__'

class VistoriaSucroalcooleiroSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaSucroalcooleiro
        fields = '__all__'

class VistoriaAgriculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAgricultura
        fields = '__all__'

class FotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Foto
        fields = '__all__'

class AuditLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditLog
        fields = '__all__'

class VistoriaListSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    id = serializers.UUIDField(required=False)

    class Meta:
        model = Vistoria
        fields = '__all__'

    def to_representation(self, instance):
        ret = super().to_representation(instance)

        data_dict = {}
        for key in ['processo_n', 'requerente', 'latitude', 'longitude', 'status', 'dispositivo']:
            data_dict[key] = ret.get(key)
        
        data_dict['municipio'] = ret.get('municipio')
        if instance.municipio:
            data_dict['municipio_nome'] = instance.municipio.nome

        # Lightweight check to determine the type without loading the nested submodels' full schemas
        tipo = 'Geral'
        if hasattr(instance, 'supressao') and instance.supressao:
            tipo = 'Supressão Vegetal'
        elif hasattr(instance, 'avicultura') and instance.avicultura:
            tipo = 'Avicultura'
        elif hasattr(instance, 'suinocultura') and instance.suinocultura:
            tipo = 'Suinocultura'
        elif hasattr(instance, 'bovinocultura') and instance.bovinocultura:
            tipo = 'Bovinocultura'
        elif hasattr(instance, 'aquicultura') and instance.aquicultura:
            tipo = 'Aquicultura'
        elif hasattr(instance, 'sucroalcooleiro') and instance.sucroalcooleiro:
            tipo = 'Sucroalcooleiro'
        elif hasattr(instance, 'agricultura') and instance.agricultura:
            tipo = 'Agricultura'
        data_dict['tipo'] = tipo

        return {
            'local_id': str(instance.id),
            'user': instance.user_id,
            'data': data_dict,
            'created_at': ret.get('created_at'),
            'synced_at': ret.get('synced_at'),
            'updated_at': ret.get('updated_at'),
        }

class VistoriaSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True, default=serializers.CurrentUserDefault())
    supressao = VistoriaSupressaoSerializer(read_only=True)
    avicultura = VistoriaAviculturaSerializer(read_only=True)
    suinocultura = VistoriaSuinoculturaSerializer(read_only=True)
    bovinocultura = VistoriaBovinoculturaSerializer(read_only=True)
    aquicultura = VistoriaAquiculturaSerializer(read_only=True)
    sucroalcooleiro = VistoriaSucroalcooleiroSerializer(read_only=True)
    agricultura = VistoriaAgriculturaSerializer(read_only=True)
    fotos = FotoSerializer(many=True, read_only=True)

    # Allow writing of the UUID 'id' to support client-side UUID generation
    id = serializers.UUIDField(required=False)

    class Meta:
        model = Vistoria
        fields = '__all__'
        read_only_fields = ('synced_at', 'updated_at', 'user')

    def to_internal_value(self, data):
        internal_data = {}

        # 1. Map local_id or id to id
        local_id = data.get('local_id') or data.get('id')
        if local_id:
            internal_data['id'] = local_id

        # 2. Extract nested data if present or merge with root to handle BOTH flat and nested styles
        nested_data = data.get('data', {})
        if not isinstance(nested_data, dict):
            nested_data = {}
        
        merged_source = {**data, **nested_data}

        # Normalize common spelling variations (like 'qnt_' to 'qtd_')
        normalized_source = {}
        for k, v in merged_source.items():
            norm_k = k
            if k.startswith('qnt_'):
                norm_k = k.replace('qnt_', 'qtd_')
            elif k.startswith('quantidade_'):
                norm_k = k.replace('quantidade_', 'qtd_')
            elif k in ['device', 'device_info', 'dispositivo_info']:
                norm_k = 'dispositivo'
            normalized_source[norm_k] = v

        # Copy any matching fields belonging to the Vistoria root model
        for key, value in normalized_source.items():
            if hasattr(Vistoria, key) and key not in ['id', 'user']:
                # Handle blank/zero values gracefully for FK fields
                if key == 'municipio' and value == 0:
                    internal_data[key] = None
                else:
                    internal_data[key] = value

        # 3. Map created_at
        created_at = normalized_source.get('created_at')
        if created_at:
            internal_data['created_at'] = created_at

        return super().to_internal_value(internal_data)

    def to_representation(self, instance):
        ret = super().to_representation(instance)

        # Build the 'data' dict to return to the mobile client
        data_dict = {}
        for key in ['processo_n', 'requerente', 'latitude', 'longitude', 'status', 'dispositivo']:
            data_dict[key] = ret.get(key)
        
        data_dict['municipio'] = ret.get('municipio')
        if instance.municipio:
            data_dict['municipio_nome'] = instance.municipio.nome

        # Include sub-models if they exist
        if hasattr(instance, 'supressao') and instance.supressao:
            data_dict['supressao'] = VistoriaSupressaoSerializer(instance.supressao).data
        if hasattr(instance, 'avicultura') and instance.avicultura:
            data_dict['avicultura'] = VistoriaAviculturaSerializer(instance.avicultura).data
        if hasattr(instance, 'suinocultura') and instance.suinocultura:
            data_dict['suinocultura'] = VistoriaSuinoculturaSerializer(instance.suinocultura).data
        if hasattr(instance, 'bovinocultura') and instance.bovinocultura:
            data_dict['bovinocultura'] = VistoriaBovinoculturaSerializer(instance.bovinocultura).data
        if hasattr(instance, 'aquicultura') and instance.aquicultura:
            data_dict['aquicultura'] = VistoriaAquiculturaSerializer(instance.aquicultura).data
        if hasattr(instance, 'sucroalcooleiro') and instance.sucroalcooleiro:
            data_dict['sucroalcooleiro'] = VistoriaSucroalcooleiroSerializer(instance.sucroalcooleiro).data
        if hasattr(instance, 'agricultura') and instance.agricultura:
            data_dict['agricultura'] = VistoriaAgriculturaSerializer(instance.agricultura).data

        return {
            'local_id': str(instance.id),
            'user': instance.user_id,
            'data': data_dict,
            'created_at': ret.get('created_at'),
            'synced_at': ret.get('synced_at'),
            'updated_at': ret.get('updated_at'),
        }

    def create(self, validated_data):
        from django.db import transaction
        with transaction.atomic():
            validated_data['user'] = self.context['request'].user
            vistoria = super().create(validated_data)

            # Usar a Factory para criar o sub-modelo correspondente de forma dinâmica
            initial_data = self.initial_data
            if isinstance(initial_data, dict):
                nested_data = initial_data.get('data', {})
                if not isinstance(nested_data, dict):
                    nested_data = {}
                
                # Mescla dados raiz e aninhados para lidar com payloads planos e estruturados
                merged_source = {**initial_data, **nested_data}

                # Normaliza variações de nomes de chaves (como 'qnt_' para 'qtd_')
                normalized_source = {}
                for k, v in merged_source.items():
                    norm_k = k
                    if k.startswith('qnt_'):
                        norm_k = k.replace('qnt_', 'qtd_')
                    elif k.startswith('quantidade_'):
                        norm_k = k.replace('quantidade_', 'qtd_')
                    normalized_source[norm_k] = v

                tipo = normalized_source.get('tipo')
                if tipo:
                    from .factories import VistoriaSubModelFactory
                    VistoriaSubModelFactory.create_sub_model(vistoria, tipo, normalized_source)

            return vistoria

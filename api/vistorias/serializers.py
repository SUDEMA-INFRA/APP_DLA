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

    class Meta:
        model = Vistoria
        fields = '__all__'
        read_only_fields = ('id', 'synced_at', 'updated_at', 'user')

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

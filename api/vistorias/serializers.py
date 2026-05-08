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
        read_only_fields = ('vistoria',)

class VistoriaAviculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAvicultura
        fields = '__all__'
        read_only_fields = ('vistoria',)

class VistoriaSuinoculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaSuinocultura
        fields = '__all__'
        read_only_fields = ('vistoria',)

class VistoriaBovinoculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaBovinocultura
        fields = '__all__'
        read_only_fields = ('vistoria',)

class VistoriaAquiculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAquicultura
        fields = '__all__'
        read_only_fields = ('vistoria',)

class VistoriaSucroalcooleiroSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaSucroalcooleiro
        fields = '__all__'
        read_only_fields = ('vistoria',)

class VistoriaAgriculturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = VistoriaAgricultura
        fields = '__all__'
        read_only_fields = ('vistoria',)

class FotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Foto
        fields = '__all__'
        read_only_fields = ('vistoria',)

class AuditLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditLog
        fields = '__all__'

class VistoriaSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True, default=serializers.CurrentUserDefault())
    supressao = VistoriaSupressaoSerializer(required=False)
    avicultura = VistoriaAviculturaSerializer(required=False)
    suinocultura = VistoriaSuinoculturaSerializer(required=False)
    bovinocultura = VistoriaBovinoculturaSerializer(required=False)
    aquicultura = VistoriaAquiculturaSerializer(required=False)
    sucroalcooleiro = VistoriaSucroalcooleiroSerializer(required=False)
    agricultura = VistoriaAgriculturaSerializer(required=False)
    fotos = FotoSerializer(many=True, required=False)

    class Meta:
        model = Vistoria
        fields = '__all__'
        read_only_fields = ('id', 'synced_at', 'updated_at', 'user')

    def create(self, validated_data):
        supressao_data = validated_data.pop('supressao', None)
        avicultura_data = validated_data.pop('avicultura', None)
        suinocultura_data = validated_data.pop('suinocultura', None)
        bovinocultura_data = validated_data.pop('bovinocultura', None)
        aquicultura_data = validated_data.pop('aquicultura', None)
        sucroalcooleiro_data = validated_data.pop('sucroalcooleiro', None)
        agricultura_data = validated_data.pop('agricultura', None)
        fotos_data = validated_data.pop('fotos', [])

        validated_data['user'] = self.context['request'].user
        vistoria = Vistoria.objects.create(**validated_data)

        if supressao_data:
            VistoriaSupressao.objects.create(vistoria=vistoria, **supressao_data)
        if avicultura_data:
            VistoriaAvicultura.objects.create(vistoria=vistoria, **avicultura_data)
        if suinocultura_data:
            VistoriaSuinocultura.objects.create(vistoria=vistoria, **suinocultura_data)
        if bovinocultura_data:
            VistoriaBovinocultura.objects.create(vistoria=vistoria, **bovinocultura_data)
        if aquicultura_data:
            VistoriaAquicultura.objects.create(vistoria=vistoria, **aquicultura_data)
        if sucroalcooleiro_data:
            VistoriaSucroalcooleiro.objects.create(vistoria=vistoria, **sucroalcooleiro_data)
        if agricultura_data:
            VistoriaAgricultura.objects.create(vistoria=vistoria, **agricultura_data)
            
        for foto in fotos_data:
            Foto.objects.create(vistoria=vistoria, **foto)

        return vistoria

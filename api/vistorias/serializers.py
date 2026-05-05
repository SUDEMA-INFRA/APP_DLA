from rest_framework import serializers
from .models import Vistoria

class VistoriaSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True, default=serializers.CurrentUserDefault())

    class Meta:
        model = Vistoria
        fields = ('id', 'user', 'local_id', 'data', 'created_at', 'synced_at')
        read_only_fields = ('id', 'synced_at', 'user')

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

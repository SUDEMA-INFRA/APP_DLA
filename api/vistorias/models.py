from django.db import models
from django.conf import settings
import uuid

class Vistoria(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='vistorias')
    local_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False, db_index=True)
    data = models.JSONField()
    created_at = models.DateTimeField()
    synced_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Vistoria {self.local_id} - {self.user.cpf}"

from django.db import models
from django.conf import settings
import uuid

class Municipio(models.Model):
    id = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=100)
    
    def __str__(self):
        return self.nome
    
class Vistoria(models.Model):
    STATUS_CHOICES = [
        ('rascunho', 'Rascunho'),
        ('nao_sincronizada', 'Nâo Sincronizada'),
        ('sincronizada', 'Sincronizada'),
    ]
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    local_id = models.CharField(max_length=100, unique=True, null=True, blank=True)
    processo_n = models.CharField(max_length=20, null=True, blank=True)
    requerente = models.CharField(max_length=200, null=True, blank=True)
    municipio = models.ForeignKey(Municipio, on_delete=models.CASCADE, related_name='vistorias', null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='rascunho')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='vistorias')
    created_at = models.DateTimeField(null=True, blank=True)
    synced_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.id} - Vistoria {self.processo_n} - {self.user.cpf if hasattr(self.user, 'cpf') else self.user}"

class VistoriaSupressao(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='supressao')
    tem_curso_dagua = models.BooleanField(null=True, blank=True)
    app_preservada = models.BooleanField(null=True, blank=True)
    indicios_uso_app = models.BooleanField(null=True, blank=True)
    rl_isolada = models.BooleanField(null=True, blank=True)
    rl_nativa_compativel = models.BooleanField(null=True, blank=True)
    
    BIOMA_CHOICES = [
        ('MA', 'Mata Atlântica'), 
        ('CAATINGA', 'Caatinga')
        ]
    bioma = models.CharField(max_length=20, choices=BIOMA_CHOICES, null=True, blank=True)
    
    bloco_a_dap = models.BooleanField(null=True, blank=True)
    bloco_a_altura = models.BooleanField(null=True, blank=True)
    bloco_a_serapilheira = models.BooleanField(null=True, blank=True)
    bloco_a_epifitas = models.BooleanField(null=True, blank=True)
    bloco_a_subbosque = models.BooleanField(null=True, blank=True)
    
    bloco_b_estrutura = models.TextField(null=True, blank=True)
    
    presenca_invasoras = models.BooleanField(null=True, blank=True)
    presenca_exoticas = models.BooleanField(null=True, blank=True)
    especies = models.TextField(null=True, blank=True)
    grau_infestacao = models.TextField(null=True, blank=True)
    loc_app = models.TextField(null=True, blank=True)
    loc_rl = models.TextField(null=True, blank=True)
    loc_uas = models.TextField(null=True, blank=True)
    pastos_abandonados = models.BooleanField(null=True, blank=True)
    supressao_solo = models.BooleanField(null=True, blank=True)
    fogo_app = models.BooleanField(null=True, blank=True)
    fogo_rl = models.BooleanField(null=True, blank=True)
    fogo_uas = models.BooleanField(null=True, blank=True)
    fogo_outras = models.BooleanField(null=True, blank=True)
    foto_geo_ok = models.BooleanField(null=True, blank=True)
    infracao = models.TextField(null=True, blank=True)
    medida_sugerida = models.TextField(null=True, blank=True)
    observacoes = models.TextField(null=True, blank=True)

class VistoriaAvicultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='avicultura')
    
    MODELO_CHOICES = [('CORTE', 'Corte'), ('POSTURA', 'Postura')]
    modelo = models.CharField(max_length=20, choices=MODELO_CHOICES, null=True, blank=True)
    
    tipo_criacao = models.TextField(null=True, blank=True)
    qtd_animais = models.IntegerField(null=True, blank=True)
    qtd_galpoes = models.IntegerField(null=True, blank=True)
    qtd_modulos = models.IntegerField(null=True, blank=True)
    qtd_gaiolas_modulo = models.IntegerField(null=True, blank=True)
    aves_gaiola = models.IntegerField(null=True, blank=True)
    gera_residuos = models.BooleanField(null=True, blank=True)
    residuos_desc = models.TextField(null=True, blank=True)

class VistoriaSuinocultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='suinocultura')
    qtd_galpoes = models.IntegerField(null=True, blank=True)
    qtd_animais = models.IntegerField(null=True, blank=True)
    fase_producao = models.TextField(null=True, blank=True)
    dejetos_destinacao = models.TextField(null=True, blank=True)
    conformidade = models.BooleanField(null=True, blank=True)

class VistoriaBovinocultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='bovinocultura')
    
    MODELO_CHOICES = [('EXTENSIVO', 'Extensivo'), ('INTENSIVO', 'Intensivo')]
    modelo = models.CharField(max_length=20, choices=MODELO_CHOICES, null=True, blank=True)
    
    area_ha = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    dessedentacao = models.TextField(null=True, blank=True)

class VistoriaAquicultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='aquicultura')
    qtd_tanques = models.IntegerField(null=True, blank=True)
    hidrometro = models.BooleanField(null=True, blank=True)
    outorga = models.BooleanField(null=True, blank=True)
    fonte_agua = models.TextField(null=True, blank=True)

class VistoriaSucroalcooleiro(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='sucroalcooleiro')
    residuos_solidos = models.TextField(null=True, blank=True)
    bagaco = models.TextField(null=True, blank=True)
    equipamentos_conformes = models.BooleanField(null=True, blank=True)
    armazenamento_ok = models.BooleanField(null=True, blank=True)

class VistoriaAgricultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='agricultura')
    cultivo = models.TextField(null=True, blank=True)
    cursos_hidricos_entorno = models.TextField(null=True, blank=True)
    agrotoxicos = models.TextField(null=True, blank=True)

class Foto(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.ForeignKey(Vistoria, on_delete=models.CASCADE, related_name='fotos')
    modulo = models.CharField(max_length=10, null=True, blank=True) # ex: 'SUP','AVI','SUI'...
    file_path_local = models.TextField(null=True, blank=True)
    storage_path_remote = models.TextField(null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    captured_at = models.DateTimeField(null=True, blank=True)
    sync_status = models.CharField(max_length=50, null=True, blank=True)

class AuditLog(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='audit_logs')
    action = models.TextField(null=True, blank=True)
    entity_type = models.TextField(null=True, blank=True)
    entity_id = models.UUIDField(null=True, blank=True)
    diff_json = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
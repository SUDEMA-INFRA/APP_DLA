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
    processo_n = models.CharField(max_length=20, null=True, blank=True)
    requerente = models.CharField(max_length=200, null=True, blank=True)
    municipio = models.ForeignKey(Municipio, on_delete=models.CASCADE, related_name='vistorias', null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='rascunho')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='vistorias')
    dispositivo = models.CharField(max_length=150, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)
    synced_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Vistoria {self.processo_n} - {self.user.cpf if hasattr(self.user, 'cpf') else self.user}"

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
    
    bloco_a_estagio_sucessional = models.CharField(max_length=50, null=True, blank=True)
    bloco_a_dap_opcao = models.CharField(max_length=50, null=True, blank=True)
    bloco_a_altura_opcao = models.CharField(max_length=50, null=True, blank=True)
    bloco_a_serapilheira_opcao = models.CharField(max_length=100, null=True, blank=True)
    bloco_a_epifitas_opcao = models.CharField(max_length=100, null=True, blank=True)
    bloco_a_subbosque_opcao = models.CharField(max_length=100, null=True, blank=True)
    bloco_a_observacoes = models.TextField(null=True, blank=True)
    
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
    
    # Corte specific fields
    corte_sistema_criacao = models.TextField(null=True, blank=True)
    corte_aves_soltas_chao = models.BooleanField(null=True, blank=True)
    corte_cama_casca_arroz = models.BooleanField(null=True, blank=True)
    corte_galpoes_longos = models.BooleanField(null=True, blank=True)
    corte_galpoes_curtos = models.BooleanField(null=True, blank=True)
    corte_bebedouros_chao = models.BooleanField(null=True, blank=True)
    corte_bebedouros_suspensos = models.BooleanField(null=True, blank=True)
    corte_comedouros_chao = models.BooleanField(null=True, blank=True)
    corte_comedouros_suspensos = models.BooleanField(null=True, blank=True)
    corte_pintos = models.BooleanField(null=True, blank=True)
    corte_frangos = models.BooleanField(null=True, blank=True)
    corte_ventiladores = models.BooleanField(null=True, blank=True)
    corte_ventiladores_func = models.BooleanField(null=True, blank=True)
    corte_sem_ventiladores = models.BooleanField(null=True, blank=True)
    corte_info_adicional = models.TextField(null=True, blank=True)
    
    corte_comprimento = models.FloatField(null=True, blank=True)
    corte_largura = models.FloatField(null=True, blank=True)
    corte_area = models.FloatField(null=True, blank=True)
    corte_densidade = models.TextField(null=True, blank=True)
    corte_qtd_estimada = models.IntegerField(null=True, blank=True)
    
    corte_cama_destinacao = models.TextField(null=True, blank=True)
    corte_cama_outros = models.TextField(null=True, blank=True)
    
    # Postura specific fields
    postura_sistema_criacao = models.TextField(null=True, blank=True)
    postura_tipo_confinamento = models.TextField(null=True, blank=True)
    postura_info_adicional = models.TextField(null=True, blank=True)
    
    postura_fileiras = models.IntegerField(null=True, blank=True)
    postura_andares = models.IntegerField(null=True, blank=True)
    postura_gaiolas_modulo = models.IntegerField(null=True, blank=True)
    postura_aves_gaiola = models.IntegerField(null=True, blank=True)
    postura_qtd_estimada = models.IntegerField(null=True, blank=True)
    
    # Shared environmental fields
    gera_residuos = models.BooleanField(null=True, blank=True)
    residuos_detalhes = models.TextField(null=True, blank=True)
    mortos_incinerados = models.BooleanField(null=True, blank=True)
    mortos_destinacao_alt = models.TextField(null=True, blank=True)
    
    foto_geo_ok = models.BooleanField(null=True, blank=True)
    infracao_constatada = models.BooleanField(null=True, blank=True)
    medida_sugerida = models.TextField(null=True, blank=True)
    observacoes = models.TextField(null=True, blank=True)
    
    # Kept for backward compatibility
    tipo_criacao = models.TextField(null=True, blank=True)
    qtd_animais = models.IntegerField(null=True, blank=True)
    qtd_galpoes = models.IntegerField(null=True, blank=True)
    qtd_modulos = models.IntegerField(null=True, blank=True)
    qtd_gaiolas_modulo = models.IntegerField(null=True, blank=True)
    aves_gaiola = models.IntegerField(null=True, blank=True)
    residuos_desc = models.TextField(null=True, blank=True)

class VistoriaSuinocultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='suinocultura')
    
    MODELO_CHOICES = [('CAIPIRA', 'Caipira'), ('INDUSTRIAL', 'Industrial')]
    modelo = models.CharField(max_length=20, choices=MODELO_CHOICES, null=True, blank=True)
    
    qtd_galpoes = models.IntegerField(null=True, blank=True)
    qtd_medio_por_galpao = models.IntegerField(null=True, blank=True)
    
    # Fases de produção
    fase_terminacao = models.BooleanField(null=True, blank=True)
    fase_terminacao_qtd = models.TextField(null=True, blank=True)
    fase_matrizes = models.BooleanField(null=True, blank=True)
    fase_matrizes_qtd = models.TextField(null=True, blank=True)
    fase_reprodutores = models.BooleanField(null=True, blank=True)
    fase_reprodutores_qtd = models.TextField(null=True, blank=True)
    fase_adulto = models.BooleanField(null=True, blank=True)
    fase_adulto_qtd = models.TextField(null=True, blank=True)
    
    # Aspectos ambientais
    acumulo_residuos = models.BooleanField(null=True, blank=True)
    vazamento_dejetos = models.BooleanField(null=True, blank=True)
    odor_extremo = models.BooleanField(null=True, blank=True)
    dejetos_transbordando = models.BooleanField(null=True, blank=True)
    impermeabilizacao_contencao = models.BooleanField(null=True, blank=True)
    destinacao_adequada = models.BooleanField(null=True, blank=True)
    
    # Manejo / Porte
    indicios_porte_maior = models.BooleanField(null=True, blank=True)
    indicios_porte_maior_detalhe = models.TextField(null=True, blank=True)
    
    # Animais mortos
    mortos_incinerados = models.BooleanField(null=True, blank=True)
    mortos_destino = models.TextField(null=True, blank=True)
    
    # Finais
    foto_geo_ok = models.BooleanField(null=True, blank=True)
    infracao_constatada = models.BooleanField(null=True, blank=True)
    medida_sugerida = models.TextField(null=True, blank=True)
    observacoes = models.TextField(null=True, blank=True)

    # Kept for backward compatibility
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
    
    qtd_cochos = models.IntegerField(null=True, blank=True)
    tamanho_cochos = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    qtd_animais = models.IntegerField(null=True, blank=True)
    
    foto_geo_ok = models.BooleanField(null=True, blank=True)
    infracao_constatada = models.BooleanField(null=True, blank=True)
    medida_sugerida = models.TextField(null=True, blank=True)
    observacoes = models.TextField(null=True, blank=True)

class VistoriaAquicultura(models.Model):
    id = models.UUIDField(default=uuid.uuid4, unique=True, primary_key=True, editable=False, db_index=True)
    vistoria = models.OneToOneField(Vistoria, on_delete=models.CASCADE, related_name='aquicultura')
    
    qtd_tanques = models.IntegerField(null=True, blank=True)
    area_tanques = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    possui_aeradores = models.BooleanField(null=True, blank=True)
    qtd_aeradores = models.IntegerField(null=True, blank=True)
    
    bomba_identificada = models.BooleanField(null=True, blank=True)
    bomba_situacao = models.TextField(null=True, blank=True)
    
    tubulacao_identificada = models.BooleanField(null=True, blank=True)
    tubulacao_situacao = models.TextField(null=True, blank=True)
    
    captacao_identificada = models.BooleanField(null=True, blank=True)
    captacao_situacao = models.TextField(null=True, blank=True)
    
    hidrometro = models.BooleanField(null=True, blank=True)
    hidrometro_situacao = models.TextField(null=True, blank=True)
    
    outros_itens_identificados = models.BooleanField(null=True, blank=True)
    outros_itens_situacao = models.TextField(null=True, blank=True)
    
    outorga = models.BooleanField(null=True, blank=True)
    outorga_identificacao = models.TextField(null=True, blank=True)
    
    DESCARTE_CHOICES = [('COMPOSTEIRA', 'Composteira'), ('OUTRO', 'Outro')]
    descarte_residuos = models.CharField(max_length=50, choices=DESCARTE_CHOICES, null=True, blank=True)
    descarte_residuos_outro = models.TextField(null=True, blank=True)
    
    fonte_agua = models.TextField(null=True, blank=True)
    
    foto_geo_ok = models.BooleanField(null=True, blank=True)
    infracao_constatada = models.BooleanField(null=True, blank=True)
    medida_sugerida = models.TextField(null=True, blank=True)
    observacoes = models.TextField(null=True, blank=True)

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
from django.contrib import admin
from .models import (
    Municipio,
    Vistoria,
    VistoriaSupressao,
    VistoriaAvicultura,
    VistoriaSuinocultura,
    VistoriaBovinocultura,
    VistoriaAquicultura,
    VistoriaAgroindustrial,
    VistoriaAgricultura,
    Foto
)

# --- INLINE CONFIGURATIONS ---
# These allow sub-model forms to be viewed and edited directly inside the Vistoria page!

class VistoriaSupressaoInline(admin.StackedInline):
    model = VistoriaSupressao
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Supressão Vegetal"
    verbose_name_plural = "Formulário de Supressão Vegetal"

class VistoriaAviculturaInline(admin.StackedInline):
    model = VistoriaAvicultura
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Avicultura"
    verbose_name_plural = "Formulário de Avicultura"

class VistoriaSuinoculturaInline(admin.StackedInline):
    model = VistoriaSuinocultura
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Suinocultura"
    verbose_name_plural = "Formulário de Suinocultura"

class VistoriaBovinoculturaInline(admin.StackedInline):
    model = VistoriaBovinocultura
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Bovinocultura"
    verbose_name_plural = "Formulário de Bovinocultura"

class VistoriaAquiculturaInline(admin.StackedInline):
    model = VistoriaAquicultura
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Aquicultura"
    verbose_name_plural = "Formulário de Aquicultura"

class VistoriaAgroindustrialInline(admin.StackedInline):
    model = VistoriaAgroindustrial
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Atividades Agroindustriais"
    verbose_name_plural = "Formulário de Atividades Agroindustriais"

class VistoriaAgriculturaInline(admin.StackedInline):
    model = VistoriaAgricultura
    extra = 0
    max_num = 1
    verbose_name = "Formulário de Agricultura"
    verbose_name_plural = "Formulário de Agricultura"

class FotoInline(admin.TabularInline):
    model = Foto
    extra = 0
    verbose_name = "Foto Georreferenciada"
    verbose_name_plural = "Fotos Georreferenciadas"


# --- MAIN ADMIN REGISTRATIONS ---

@admin.register(Municipio)
class MunicipioAdmin(admin.ModelAdmin):
    list_display = ('id', 'nome')
    search_fields = ('nome',)
    ordering = ('nome',)

@admin.register(Vistoria)
class VistoriaAdmin(admin.ModelAdmin):
    # What columns show up on the main list table
    list_display = (
        'short_id', 
        'processo_n', 
        'requerente', 
        'municipio', 
        'user', 
        'dispositivo', 
        'status', 
        'created_at', 
        'synced_at'
    )
    
    # Filtering side panels
    list_filter = (
        'status', 
        'user', 
        'municipio', 
        'dispositivo',
        'created_at', 
        'synced_at'
    )
    
    # Real-time search inputs
    search_fields = (
        'id', 
        'processo_n', 
        'requerente', 
        'user__username', 
        'dispositivo'
    )
    
    # Inlines showing all child forms
    inlines = [
        VistoriaSupressaoInline,
        VistoriaAviculturaInline,
        VistoriaSuinoculturaInline,
        VistoriaBovinoculturaInline,
        VistoriaAquiculturaInline,
        VistoriaAgroindustrialInline,
        VistoriaAgriculturaInline,
        FotoInline
    ]
    
    # Read-only attributes
    readonly_fields = ('id', 'synced_at', 'updated_at')
    
    # Elegant grouping of main vistoria attributes
    fieldsets = (
        ('Identificação e Processo', {
            'fields': ('id', 'processo_n', 'requerente', 'municipio', 'user')
        }),
        ('Informações de Origem e Geolocalização', {
            'fields': ('latitude', 'longitude', 'dispositivo')
        }),
        ('Status e Datas de Controle', {
            'fields': ('status', 'created_at', 'synced_at', 'updated_at')
        }),
    )

    def short_id(self, obj):
        return str(obj.id)[:8] + "..."
    short_id.short_description = "UUID"

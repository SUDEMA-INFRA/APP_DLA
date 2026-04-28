from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('cpf', 'username', 'email', 'is_staff', 'is_active')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'groups')
    search_fields = ('cpf', 'username', 'email')
    ordering = ('cpf',)
    
    fieldsets = UserAdmin.fieldsets + (
        ('Informações Adicionais', {'fields': ('cpf',)}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Informações Adicionais', {'fields': ('cpf',)}),
    )

admin.site.register(CustomUser, CustomUserAdmin)

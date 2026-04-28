from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self, cpf, password=None, **extra_fields):
        if not cpf:
            raise ValueError('The CPF field must be set')
        user = self.model(cpf=cpf, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, cpf, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(cpf, password, **extra_fields)

class CustomUser(AbstractUser):
    cpf = models.CharField(max_length=11, unique=True)
    
    objects = CustomUserManager()
    
    USERNAME_FIELD = 'cpf'
    REQUIRED_FIELDS = ['username', 'email']

    def __str__(self):
        return self.cpf

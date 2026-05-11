import urllib.request
import json
import gzip
from django.core.management.base import BaseCommand
from vistorias.models import Municipio, Vistoria

class Command(BaseCommand):
    help = 'Populates the database with all 223 municipalities of Paraiba from the official IBGE API'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Iniciando carga de municípios da Paraíba a partir da API do IBGE..."))
        
        # 1. Traduz registros antigos (ID 1 a 7) para os códigos IBGE oficiais
        mapping = {
            1: 2507507,  # João Pessoa
            2: 2504009,  # Campina Grande
            3: 2503209,  # Cabedelo
            4: 2513703,  # Santa Rita
            5: 2510808,  # Patos
            6: 2516201,  # Sousa
            7: 2503704,  # Cajazeiras
        }
        
        for old_id, ibge_id in mapping.items():
            old_mun = Municipio.objects.filter(id=old_id).first()
            if old_mun:
                # Cria a nova cidade IBGE se não existir
                new_mun, _ = Municipio.objects.get_or_create(id=ibge_id, defaults={'nome': old_mun.nome})
                # Atualiza todas as vistorias que apontavam para o id antigo
                vistorias_to_update = Vistoria.objects.filter(municipio_id=old_id)
                count = vistorias_to_update.count()
                if count > 0:
                    vistorias_to_update.update(municipio_id=ibge_id)
                    self.stdout.write(self.style.WARNING(
                        f"Traduzidas {count} vistorias do município provisório ID {old_id} para {ibge_id} ({new_mun.nome})."
                    ))
                # Exclui o ID antigo obsoleto para limpar o banco
                old_mun.delete()

        # 2. Requisita municípios de Paraíba do IBGE (código do estado da PB = 25)
        url = "https://servicodados.ibge.gov.br/api/v1/localidades/estados/25/municipios"
        
        req = urllib.request.Request(
            url, 
            headers={'Accept-Encoding': 'gzip, deflate'}
        )

        try:
            response = urllib.request.urlopen(req)
            content = response.read()
            
            if response.info().get('Content-Encoding') == 'gzip':
                content = gzip.decompress(content)
                
            data = json.loads(content.decode('utf-8'))
            
            # Ordena alfabeticamente
            data.sort(key=lambda x: x['nome'])
            
            total_created = 0
            total_updated = 0
            
            for item in data:
                ibge_id = int(item['id'])
                nome = item['nome']
                
                municipio, created = Municipio.objects.update_or_create(
                    id=ibge_id,
                    defaults={'nome': nome}
                )
                if created:
                    total_created += 1
                else:
                    total_updated += 1
            
            self.stdout.write(self.style.SUCCESS(
                f"Sincronização concluída com sucesso! {len(data)} municípios processados.\n"
                f"Novas cidades cadastradas: {total_created}\n"
                f"Cidades atualizadas: {total_updated}"
            ))
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Erro ao carregar municípios da API do IBGE: {e}"))

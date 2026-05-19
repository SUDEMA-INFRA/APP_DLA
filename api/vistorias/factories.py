from .models import (
    Vistoria, VistoriaSupressao, VistoriaAvicultura, VistoriaSuinocultura,
    VistoriaBovinocultura, VistoriaAquicultura, VistoriaSucroalcooleiro,
    VistoriaAgricultura
)

class VistoriaSubModelFactory:
    _MAPPING = {
        'supressao': VistoriaSupressao,
        'ambiental': VistoriaSupressao,  # Mapping 'Ambiental' to Supressao as default or fallback
        'avicultura': VistoriaAvicultura,
        'suinocultura': VistoriaSuinocultura,
        'bovinocultura': VistoriaBovinocultura,
        'aquicultura': VistoriaAquicultura,
        'sucroalcooleiro': VistoriaSucroalcooleiro,
        'agricultura': VistoriaAgricultura,
    }

    @classmethod
    def get_model_class(cls, tipo):
        if not tipo:
            return None
        return cls._MAPPING.get(str(tipo).lower().strip())

    @classmethod
    def create_sub_model(cls, vistoria, tipo, payload_data):
        """
        Creates and links the correct sub-model to the Vistoria instance 
        based on the 'tipo' and pre-fills its fields from the payload_data.
        """
        model_class = cls.get_model_class(tipo)
        if not model_class:
            return None

        # Extract nested data if it exists under the tipo name (e.g. 'bovinocultura')
        tipo_key = str(tipo).lower().strip()
        data_to_extract = payload_data.get(tipo_key, payload_data)
        if not isinstance(data_to_extract, dict):
            data_to_extract = payload_data

        # Filter the data to only include fields that belong to the target sub-model
        sub_model_fields = {}
        for key, value in data_to_extract.items():
            # Exclude id and vistoria primary relations
            if hasattr(model_class, key) and key not in ['id', 'vistoria']:
                sub_model_fields[key] = value

        # Create the sub-model instance linked to the vistoria
        sub_model_instance = model_class.objects.create(vistoria=vistoria, **sub_model_fields)
        return sub_model_instance

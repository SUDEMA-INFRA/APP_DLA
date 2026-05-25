from .models import (
    Vistoria, VistoriaSupressao, VistoriaAvicultura, VistoriaSuinocultura,
    VistoriaBovinocultura, VistoriaAquicultura, VistoriaAgroindustrial,
    VistoriaAgricultura
)

class VistoriaSubModelFactory:
    _MAPPING = {
        'supressao': VistoriaSupressao,
        'supressão vegetal': VistoriaSupressao,
        'supressao vegetal': VistoriaSupressao,
        'supressao_vegetal': VistoriaSupressao,
        'ambiental': VistoriaSupressao,  # Mapping 'Ambiental' to Supressao as default or fallback
        'avicultura': VistoriaAvicultura,
        'suinocultura': VistoriaSuinocultura,
        'bovinocultura': VistoriaBovinocultura,
        'aquicultura': VistoriaAquicultura,
        'sucroalcooleiro': VistoriaAgroindustrial,
        'agroindustrial': VistoriaAgroindustrial,
        'atividades agroindustriais': VistoriaAgroindustrial,
        'agroindustriais': VistoriaAgroindustrial,
        'agricultura': VistoriaAgricultura,
    }

    _PAYLOAD_KEYS = {
        'supressao': 'supressao',
        'supressão vegetal': 'supressao',
        'supressao vegetal': 'supressao',
        'supressao_vegetal': 'supressao',
        'ambiental': 'supressao',
        'avicultura': 'avicultura',
        'suinocultura': 'suinocultura',
        'bovinocultura': 'bovinocultura',
        'aquicultura': 'aquicultura',
        'sucroalcooleiro': 'agroindustrial',
        'agroindustrial': 'agroindustrial',
        'atividades agroindustriais': 'agroindustrial',
        'agroindustriais': 'agroindustrial',
        'agricultura': 'agricultura',
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

        # Extract nested data if it exists under the normalized payload key
        tipo_normalized = str(tipo).lower().strip()
        payload_key = cls._PAYLOAD_KEYS.get(tipo_normalized, tipo_normalized)
        data_to_extract = payload_data.get(payload_key)
        if not isinstance(data_to_extract, dict):
            # Try other potential keys for sucroalcooleiro/agroindustrial to be extremely resilient
            if payload_key == 'agroindustrial':
                for alt_key in ['agroindustrial', 'sucroalcooleiro', 'atividades agroindustriais', 'agroindustriais']:
                    alt_data = payload_data.get(alt_key)
                    if isinstance(alt_data, dict):
                        data_to_extract = alt_data
                        break
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

    @classmethod
    def update_sub_model(cls, vistoria, tipo, payload_data):
        """
        Updates the existing sub-model linked to the Vistoria instance 
        based on the 'tipo' and new payload_data.
        """
        model_class = cls.get_model_class(tipo)
        if not model_class:
            return None

        # Extract nested data if it exists under the normalized payload key
        tipo_normalized = str(tipo).lower().strip()
        payload_key = cls._PAYLOAD_KEYS.get(tipo_normalized, tipo_normalized)
        data_to_extract = payload_data.get(payload_key)
        if not isinstance(data_to_extract, dict):
            # Try other potential keys for sucroalcooleiro/agroindustrial to be extremely resilient
            if payload_key == 'agroindustrial':
                for alt_key in ['agroindustrial', 'sucroalcooleiro', 'atividades agroindustriais', 'agroindustriais']:
                    alt_data = payload_data.get(alt_key)
                    if isinstance(alt_data, dict):
                        data_to_extract = alt_data
                        break
            if not isinstance(data_to_extract, dict):
                data_to_extract = payload_data

        # Try to fetch the existing sub-model
        sub_model_instance = model_class.objects.filter(vistoria=vistoria).first()
        if not sub_model_instance:
            # If it doesn't exist for some reason, create it
            return cls.create_sub_model(vistoria, tipo, payload_data)

        # Update fields
        for key, value in data_to_extract.items():
            if hasattr(model_class, key) and key not in ['id', 'vistoria']:
                setattr(sub_model_instance, key, value)

        sub_model_instance.save()
        return sub_model_instance

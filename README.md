
# Generador de Modulefile

Este script Bash se encarga de crear un archivo *modulefile* a partir de una ruta proporcionada, el cual puede ser cargado mediante herramientas de *environment modules*. El *modulefile* resultante configura variables de entorno para facilitar el uso de un software instalado en una ubicación específica.

## Descripción

El script:
- Verifica que se hayan pasado los parámetros necesarios.
- Comprueba la existencia y validez de la ruta del directorio.
- Genera el *modulefile* con rutas a directorios comunes (por ejemplo, `bin`, `lib`, `include`, `man`).
- Permite configurar si el *modulefile* creado se establece como la versión por defecto.
- Ofrece la opción de configurar la salida en color para mensajes informativos y de error.

## Requisitos

- **Bash**: El script está escrito para Bash y utiliza sintaxis y utilidades propias de este intérprete.
- **Utilidades del sistema**: Comandos como `realpath`, `mkdir`, `dirname`, `cat`, `awk`, entre otros.
- **Acceso a directorios**: Se requiere que el usuario tenga permisos para leer la ruta especificada y escribir en la ubicación donde se creará el archivo.

## Uso

Ejecute el script pasando los parámetros obligatorios y opcionales de la siguiente manera:

```bash
./create-module_env.sh -d "ruta_del_directorio" -f "nombre_del_archivo" [--default] [-c|--color auto|none|always] [ -h|--help ]

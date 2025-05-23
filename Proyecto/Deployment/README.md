## Terraform y Ansible

### Credenciales AWS

La maquina local debe tener configuradas las credenciales de AWS de EC2, ya sea en ~/.aws/credential o en las variables de entorno del sistema.

### Configuracion Terraform

En el archivo `main.tf` en el apartado de `locals` se deben configurar los datos de la VPC a utilizar tanto el ID de la VPC como el ID de la subred de la VPC, adicional se debe configurar el par de claves creadas en AWS, el usuario para la conexion y el path donde se encuentra la llave en la maquina local para la conexion ssh.

```
    locals {
        vpc_id           = "<vpc>"
        subnet_id        = "<subnet>"
        ssh_user         = "<user>"
        key_name         = "<key>"
        private_key_path = "C:/.../<key>.pem"
    }
```

En el archivo `variable.tf` se encuentra una variable que es utilizada para la clonacion del repositorio con Ansible, por lo que antes de aplicar cualquier comando se debe colocar el valor de un token con permisos de lectura de repositorio en el valor de la variable.

La aplicacion de la infraestructura consiste en la creacion de una nueva instancia de `EC2` con las configuracion de la capa gratuita, asi como la creacion de un grupo de seguridad para permitir el trafico SSH y el trafico TCP/IP al puerto donde corre la aplicacion.

Una vez creada la `EC2` se aplican recursos nulos, lo cuales se encargan de subir el playbook de `Ansible` a la instancia y su posterior ejecucion.

### Ejecucion

Antes de aplicar la infraestructura dentro del directorio se debe ejecutar el comando `terraform init` para la aplicacion de configuraciones y proveedores, una vez aplicado se debe aplicar la infraestructura con el comando `terraform apply` esto comenzara con la creacion de los recursos y la ejecucion de los comandos necesarios.

Si es necesario deshacer los recursos se debe ejecutar el comando `terraform destroy`.

### Ansible

Una vez creados los recursos se procede a la ejecucion del playbook de `Ansible` el cual realiza las siguientes acciones:
- Instalacion y verificacion de Git
- Clonacion del repositorio.
- Buildeo de la imagen de Docker para el despliegue del frontend.
- Despliegue de un nuevo contenedor del frontend.
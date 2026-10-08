# 01 - Configuración del servidor

## HOSPLab Guardian

### Preparación del servidor

Para empezar con el proyecto, he preparado una máquina virtual con Windows Server, que utilizaré como controlador de dominio del entorno hospitalario.

La configuración de red que he utilizado es la siguiente:

- Nombre del servidor: SRV-AD01
- Dirección IP interna: 10.10.10.10
- Máscara de subred: 255.255.255.0
- DNS preferido: 10.10.10.10
- Dominio: hosplab.local

### Active Directory y DNS

Una vez configurado el servidor, he instalado los roles de Active Directory (AD DS) y DNS.

Después he promocionado el servidor a controlador de dominio, creando un nuevo bosque con el dominio hosplab.local.

De esta forma, podré gestionar los usuarios, equipos y permisos del laboratorio desde un mismo servidor.

### Estructura organizativa

Dentro de Active Directory he creado una unidad organizativa principal llamada HOSPLAB.

A partir de ella, he organizado las siguientes unidades organizativas:

- Usuarios
  - Personal IT
  - Personal Sanitario
- Equipos
- Grupos

He separado los usuarios en diferentes unidades organizativas para simular la estructura de un hospital y facilitar su administración.

### Grupos de seguridad

También he creado dos grupos de seguridad de ámbito global:

- GG_IT
- GG_Personal_Sanitario

Estos grupos servirán para organizar a los usuarios según su departamento y, más adelante, poder asignarles diferentes permisos.

### Usuarios de prueba

Para comprobar el funcionamiento de Active Directory, he creado dos usuarios ficticios:

- Prueba IT
- Prueba Sanitario

Cada usuario está creado dentro de su unidad organizativa correspondiente y añadido a su grupo de seguridad.

He utilizado usuarios de prueba porque el objetivo es simular un entorno hospitalario sin utilizar datos personales reales.

### Estado actual

Por el momento, ya tengo configurado el controlador de dominio, el servicio DNS y la estructura inicial de Active Directory.

También he creado los primeros usuarios y grupos de seguridad.

El siguiente paso será configurar la máquina virtual de Windows 11 y unirla al dominio hosplab.local para comprobar que los equipos pueden autenticarse correctamente contra el servidor.

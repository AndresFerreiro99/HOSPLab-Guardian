# HOSPLab Guardian

Este repositorio lo voy a utilizar para ir guardando y documentando mi proyecto de TFG de ASIR.

La idea del proyecto es montar un pequeño entorno hospitalario utilizando máquinas virtuales. He elegido este tipo de entorno porque trabajo en informática dentro de un hospital y quería hacer un proyecto relacionado con situaciones que me puedo encontrar en el día a día, pero creando todo desde cero y sin utilizar ningún dato ni configuración real.

## ¿Qué quiero montar?

En principio el laboratorio va a tener 3 máquinas virtuales:

- Windows Server: será el servidor principal. Tendrá Active Directory, DNS, usuarios, grupos y carpetas compartidas.
- Windows: será un equipo cliente unido al dominio y simulará uno de los ordenadores del hospital.
- Ubuntu Server: lo utilizaré para instalar Zabbix y monitorizar los equipos y servicios del laboratorio.

Todo el entorno se va a montar utilizando VirtualBox.

## HOSPLab Guardian

Además de montar las máquinas y los servicios, quiero crear una pequeña herramienta en PowerShell llamada Guardian.

La idea es que desde el equipo del técnico pueda ejecutar Guardian cuando exista algún problema y que el script haga varias comprobaciones automáticamente.

Por ejemplo:

- Comprobar si hay conexión con un servidor.
- Comprobar que el DNS funciona correctamente.
- Comprobar si un servicio o recurso compartido está disponible.

Después de realizar las pruebas, Guardian generará un pequeño informe con los resultados para ayudar a localizar dónde puede estar el problema.

No quiero crear un sistema completo de resolución de incidencias, ya que sería demasiado grande para el tiempo que tengo. La idea es preparar unas 3 incidencias concretas y utilizarlas para demostrar cómo funciona el laboratorio y la herramienta.

## Tecnologías que voy a utilizar

- VirtualBox
- Windows Server
- Windows
- Ubuntu Server
- Active Directory
- DNS
- PowerShell
- Zabbix
- Git y GitHub

----------------

Andrés Ferreiro Martínez  
TFG - Administración de Sistemas Informáticos en Red (ASIR)

## Estado actual del proyecto (09 / 10 / 2026)

- Servidor Windows Server (SRV-AD01) con Active Directory y DNS operativos.
- Cliente Windows 11 (W11-CL01) configurado en la red interna HospLab.
- Comunicación verificada entre servidor y cliente.
- Windows 11 unido al dominio hosplab.local.
- Inicio de sesión en el dominio verificado con `whoami = hosplab\administrador`.
- Evidencia subida en docs/capturas.

## Avances del proyecto (22 / 11 / 2026)

### Organización de Active Directory

He seguido configurando Active Directory para que el dominio tenga una estructura parecida a la que podría encontrar en un hospital.

Primero creé varias unidades organizativas para separar los departamentos de Admisión, Enfermería, Urgencias, Laboratorio e Informática.

Después creé una cuenta de usuario para cada departamento, con una contraseña temporal que tenían que cambiar al iniciar sesión por primera vez.

Los usuarios que he creado son:

| Departamento | Usuario |
|---|---|
| Admisión | lgarciam |
| Enfermería | mfernandezr |
| Urgencias | dlopezs |
| Laboratorio | promerod |
| Informática | jtorresm |

Para comprobar que funcionaban, inicié sesión en Windows 11 con el usuario de Admisión. Windows me pidió cambiar la contraseña y después pude entrar al escritorio.

También ejecuté `whoami` y comprobé que aparecía `hosplab\lgarciam`, por lo que el usuario estaba iniciando sesión correctamente en el dominio.

### Creación de grupos de seguridad

Después creé un grupo de seguridad para cada departamento.

La idea es que más adelante pueda utilizar estos grupos para dar permisos a carpetas compartidas sin tener que configurar los permisos usuario por usuario.

Los grupos que he creado son:

- GG_Admision
- GG_Enfermeria
- GG_Urgencias
- GG_Laboratorio
- GG_Informatica

He añadido a cada usuario al grupo correspondiente a su departamento.

Además, he conservado los grupos GG_IT y GG_Personal_Sanitario que había creado anteriormente para las primeras pruebas con los usuarios Prueba IT y Prueba Sanitario.

De momento los grupos están configurados, pero todavía tengo pendiente crear las carpetas compartidas y probar los permisos de acceso.

### Reorganización de Active Directory

Mientras estaba configurando los usuarios y los grupos, me di cuenta de que tenía dos estructuras diferentes dentro del dominio.

Una era HOSPLAB, que había utilizado para las primeras pruebas, y otra era Hospital, donde estaba creando los nuevos departamentos.

Para dejarlo más organizado decidí juntar todo dentro de Hospital.

He dejado tres unidades organizativas principales:

- Equipos: donde he movido W11-CL01.
- Grupos: donde están los grupos de seguridad.
- Usuarios: donde he organizado los cinco departamentos y sus usuarios.

La estructura ha quedado así:

```text
hosplab.local
└── Hospital
    ├── Equipos
    │   └── W11-CL01
    ├── Grupos
    └── Usuarios
        ├── Admision
        ├── Enfermeria
        ├── Informatica
        ├── Laboratorio
        └── Urgencias
```

También he movido los usuarios y grupos de las primeras pruebas para no perderlos.

Después comprobé que la estructura antigua estaba vacía y la eliminé.

Por último, volví a activar la protección contra eliminación accidental de las unidades organizativas que había tenido que mover.

### Primeras pruebas de Guardian

Una vez terminada esta parte de Active Directory, he empezado a programar Guardian en PowerShell desde W11-CL01.

La primera versión solo comprobaba si había conexión con el servidor SRV-AD01, utilizando su dirección IP 10.10.10.10.

Después añadí una comprobación DNS para revisar si el nombre del servidor resolvía correctamente.

Durante esta prueba apareció un problema, ya que el DNS devolvía dos direcciones IP:

- 10.10.10.10, que es la dirección de la red interna.
- 10.0.2.15, que corresponde al adaptador NAT de VirtualBox.

He revisado los adaptadores de red y eliminado algunos registros DNS que no deberían aparecer. También he desactivado el registro automático del adaptador NAT.

Aun así, Guardian sigue detectando la segunda dirección, por lo que tengo pendiente terminar de solucionar este problema.

Después añadí una tercera comprobación para revisar los servicios DNS, NTDS y Netlogon del servidor.

Con estas tres pruebas terminé Guardian v1.1.

Actualmente Guardian puede comprobar:

- Si el servidor responde.
- Si el DNS devuelve las direcciones esperadas.
- Si los servicios principales del dominio están funcionando.

El script está guardado en `scripts/Guardian.ps1`.

### Primera incidencia simulada

Para comprobar si Guardian era capaz de detectar un problema real dentro del laboratorio, hice una primera simulación apagando SRV-AD01.

Dejé Windows 11 encendido y ejecuté Guardian.

El resultado fue que Guardian detectó que no había conexión con el servidor, que no podía resolver su nombre DNS y que tampoco podía consultar los servicios.

Después volví a encender el servidor y ejecuté otra vez el script.

Esta vez Guardian volvió a detectar conexión con el servidor y comprobó que los servicios DNS y NTDS estaban funcionando. La alerta del DNS seguía apareciendo por la dirección 10.0.2.15.

Con esta prueba he podido comprobar que Guardian sirve para detectar una caída del servidor y verificar que vuelve a estar disponible después de recuperarlo.

He guardado capturas de las pruebas para poder utilizarlas en la documentación del proyecto.

### Próximos pasos

Lo siguiente que quiero hacer es:

- Terminar de solucionar el problema de los registros DNS.
- Crear carpetas compartidas para los departamentos.
- Configurar permisos utilizando los grupos de seguridad.
- Añadir nuevas comprobaciones a Guardian.
- Preparar más incidencias simuladas.
- Conseguir que Guardian genere informes de los resultados.
- Montar Ubuntu Server e instalar Zabbix.
- Continuar documentando los avances en GitHub y en la memoria del TFG.

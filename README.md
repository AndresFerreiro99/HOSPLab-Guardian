
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

Estos grupos los he utilizado después para organizar los permisos de las carpetas compartidas.

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

He revisado los adaptadores de red y eliminado los registros DNS que no deberían aparecer. También he desactivado el registro automático del adaptador NAT.

Después comprobé que el problema continuaba y revisé las interfaces del servicio DNS de Windows Server.

Configuré el servidor DNS para que escuchase únicamente en la dirección IP interna 10.10.10.10.

Finalmente volví a ejecutar Guardian desde Windows 11 y comprobé que la resolución DNS ya funcionaba correctamente.

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

Esta vez Guardian volvió a detectar conexión con el servidor y comprobó que los servicios estaban funcionando.

Además, terminé de corregir el problema del DNS y conseguí que todas las comprobaciones de Guardian apareciesen correctamente.

Con esta prueba he podido comprobar que Guardian sirve para detectar una caída del servidor y verificar que vuelve a estar disponible después de recuperarlo.

He guardado capturas de las pruebas para poder utilizarlas en la documentación del proyecto.

### Configuración de carpetas compartidas

Después de configurar los usuarios y grupos, he empezado a preparar las carpetas compartidas del hospital.

Al principio creé una carpeta para Admisión y la compartí directamente en la red.

Sin embargo, después decidí cambiar la estructura porque me parecía más útil tener una única carpeta compartida principal, en lugar de crear un acceso de red diferente para cada departamento.

Por ejemplo, un trabajador podría necesitar acceso a las carpetas de Admisión y Hospitalización. En ese caso, prefiero que tenga un único acceso de red donde aparezcan las carpetas que puede utilizar.

Por eso creé la carpeta `C:\Hospital` en SRV-AD01 y dentro añadí las carpetas de los cinco departamentos.

La estructura es la siguiente:

```text
C:\Hospital
├── Admision
├── Enfermeria
├── Informatica
├── Laboratorio
└── Urgencias
```

Después compartí la carpeta principal con el nombre `Hospital`.

Desde Windows 11 se puede acceder utilizando la ruta:

`\\SRV-AD01\Hospital`

Así los usuarios solamente necesitan un acceso directo o una unidad de red para entrar a los recursos compartidos del hospital.

### Configuración de permisos

Una vez creadas las carpetas, empecé a configurar los permisos para que cada departamento tuviese acceso únicamente a sus archivos.

Para hacerlo, utilicé los grupos de seguridad que había creado anteriormente en Active Directory.

En cada carpeta he configurado los permisos NTFS desde la pestaña Seguridad de Windows Server.

He quitado los permisos generales heredados del grupo Usuarios para evitar que cualquier trabajador del dominio pueda acceder a las carpetas de otros departamentos.

Después he añadido el grupo correspondiente a cada carpeta con permiso de Modificar.

La configuración es la siguiente:

| Carpeta | Grupo con acceso | Permiso |
|---|---|---|
| Admision | GG_Admision | Modificar |
| Enfermeria | GG_Enfermeria | Modificar |
| Urgencias | GG_Urgencias | Modificar |
| Laboratorio | GG_Laboratorio | Modificar |
| Informatica | GG_Informatica | Modificar |

También he conservado los permisos necesarios de SYSTEM y Administradores para no perder la administración de las carpetas.

De esta manera, si un trabajador necesita acceso a otra carpeta, no tendría que modificar sus permisos individualmente. Bastaría con añadirlo al grupo correspondiente desde Active Directory.

### Ocultar carpetas sin permisos mediante ABE

Además de configurar los permisos, quería que los trabajadores no pudiesen ver las carpetas de los departamentos a los que no tienen acceso.

Por ejemplo, si un usuario trabaja en Admisión, no tiene por qué saber que existen otras carpetas con documentación de diferentes servicios.

Para conseguirlo he activado la opción de **enumeración basada en el acceso (ABE)** en el recurso compartido Hospital.

Esta función permite que Windows oculte las carpetas para las que un usuario no tiene permisos.

Durante las primeras pruebas comprobé que el usuario de Admisión podía ver todas las carpetas.

El problema estaba en que las carpetas todavía tenían permisos generales heredados del grupo Usuarios.

Después de quitar esos permisos en las opciones avanzadas de seguridad, las carpetas dejaron de aparecer automáticamente.

Finalmente comprobé que, al iniciar sesión en Windows 11 con el usuario `lgarciam`, únicamente aparecía la carpeta Admision.

Esta configuración me parece importante porque no solo evita que los usuarios entren en carpetas sin autorización, sino que también impide que puedan verlas desde el recurso compartido.

Hay que tener en cuenta que ABE sirve para ocultar las carpetas, mientras que los permisos NTFS son los que realmente controlan el acceso a los archivos.

### Administración de carpetas desde Windows 11

Después de terminar los permisos por departamentos, quise añadir otra funcionalidad.

La idea era que una persona del departamento de Informática pudiese administrar las carpetas compartidas sin tener que entrar directamente en Windows Server.

Por ejemplo, si se crea un departamento nuevo en el hospital, el administrador de ficheros debería poder crear su carpeta y configurar los permisos desde su propio ordenador.

Para hacerlo creé un grupo de seguridad llamado `GG_Admin_Ficheros`.

He separado este grupo de `GG_Informatica` porque no todos los trabajadores de Informática necesitan administrar las carpetas de los demás departamentos.

Después creé mi usuario de prueba `andresferreiro` y lo añadí a `GG_Admin_Ficheros`.

Este grupo tiene Control total sobre la carpeta principal Hospital y sobre las carpetas de los departamentos.

También tuve que configurar los permisos del recurso compartido, porque al principio Windows 11 no me permitía crear carpetas aunque el grupo tuviese Control total en los permisos NTFS.

El problema estaba en que los permisos de uso compartido todavía no permitían realizar esa operación.

Finalmente dejé los permisos del recurso compartido de esta manera:

- Todos: Lectura.
- GG_Admin_Ficheros: Control total.

Con esta configuración los usuarios normales pueden acceder al recurso compartido, pero sus permisos sobre las subcarpetas siguen dependiendo de los grupos de Active Directory.

En cambio, los miembros de GG_Admin_Ficheros pueden administrar los recursos compartidos.

### Pruebas de administración de ficheros

Para comprobar que todo funcionaba, inicié sesión en W11-CL01 con mi usuario `andresferreiro`.

Primero comprobé que podía ver las cinco carpetas del hospital, algo que los usuarios de los departamentos no pueden hacer si no tienen los permisos correspondientes.

Después ejecuté el comando `whoami /groups` y confirmé que mi usuario pertenecía al grupo `GG_Admin_Ficheros`.

A continuación intenté crear una carpeta nueva desde Windows 11 dentro del recurso compartido Hospital.

Al principio apareció un mensaje de acceso denegado.

Después de revisar los permisos del recurso compartido y dar Control total a GG_Admin_Ficheros, conseguí crear la carpeta correctamente.

Para continuar con la prueba, creé una carpeta llamada `Prueba_Admin`.

Desde el propio Windows 11 entré en sus opciones avanzadas de seguridad y añadí el grupo `GG_Admision` con permiso de Modificar.

Windows me permitió guardar los cambios sin solicitar credenciales de administrador del dominio.

Por último, eliminé la carpeta Prueba_Admin para dejar el entorno como estaba.

Con estas pruebas he comprobado que puedo crear carpetas, modificar sus permisos y eliminarlas desde el equipo cliente, sin tener que iniciar sesión directamente en el servidor.

Además, mi usuario no necesita pertenecer al grupo Administradores del dominio, porque los permisos se conceden mediante un grupo específico para administrar ficheros.

Esto permite separar las tareas de administración del servidor de las tareas de gestión de recursos compartidos.

### Próximos pasos

Lo siguiente que quiero hacer es:

- Añadir a Guardian una comprobación de las carpetas compartidas.
- Preparar una segunda incidencia simulada relacionada con los permisos o el acceso a los recursos compartidos.
- Conseguir que Guardian genere informes de los resultados.
- Montar Ubuntu Server e instalar Zabbix.
- Integrar la monitorización de los equipos y servicios del hospital.
- Continuar documentando los avances en GitHub y en la memoria del TFG.

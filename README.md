
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

Finalmente conseguí que el grupo GG_Admin_Ficheros tuviese Control total tanto en los permisos NTFS como en los del recurso compartido.

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

### Segunda incidencia simulada: caída del recurso compartido

Después de terminar la configuración de las carpetas compartidas, he continuado desarrollando Guardian para que también pueda comprobar si los recursos de red están disponibles.

Hasta ahora Guardian comprobaba la conexión con el servidor, la resolución DNS y el estado de los servicios de Active Directory.

En esta nueva versión, Guardian v1.2, he añadido una cuarta comprobación relacionada con las carpetas compartidas.

La herramienta utiliza dos comandos de PowerShell:

- Test-NetConnection: para comprobar si el puerto 445 del servidor está disponible.
- Test-Path: para comprobar si el usuario puede acceder a la carpeta compartida del hospital.

El puerto 445 es el que utiliza SMB para permitir el acceso a los archivos compartidos en Windows.

La idea de esta comprobación es poder diferenciar entre una caída completa del servidor y un problema que afecte únicamente a una carpeta compartida.

#### Prueba inicial

Primero comprobé desde W11-CL01 que podía acceder correctamente a la ruta `\\SRV-AD01\Hospital`.

Después verifiqué que el puerto 445 del servidor estaba disponible.

Las dos pruebas funcionaron correctamente, así que añadí estas comprobaciones al script de Guardian.

Al ejecutar Guardian v1.2, todas las comprobaciones aparecían en verde.

#### Simulación de la incidencia

Para simular el problema, decidí eliminar temporalmente el recurso compartido Hospital desde Windows Server.

Antes de hacerlo comprobé que el recurso apuntaba a `C:\Hospital` y que tenía activada la enumeración basada en el acceso (ABE).

Después utilicé el comando `Remove-SmbShare` para quitar el recurso compartido sin eliminar la carpeta ni modificar los permisos NTFS.

De esta manera conseguí simular una situación en la que el servidor seguía encendido y funcionando, pero los trabajadores ya no podían acceder a la carpeta compartida del hospital.

A continuación ejecuté Guardian desde W11-CL01.

El resultado fue el siguiente:

- La conexión con SRV-AD01 funcionaba correctamente.
- El DNS resolvía correctamente el nombre del servidor.
- Los servicios DNS, NTDS y Netlogon estaban en ejecución.
- El puerto SMB 445 seguía disponible.
- Guardian mostraba una alerta porque no podía acceder a `\\SRV-AD01\Hospital`.

Con esto pude comprobar que Guardian era capaz de detectar un problema específico del recurso compartido sin confundirlo con una caída general del servidor.

#### Recuperación del recurso compartido

Después de guardar la evidencia, volví a crear el recurso Hospital mediante PowerShell.

Configuré de nuevo su ruta, activé ABE y restauré los permisos de uso compartido.

Al ejecutar Guardian otra vez, el recurso aparecía disponible y todas las comprobaciones volvieron a mostrarse en verde.

También comprobé desde Windows Server que el recurso compartido tenía activada la opción AccessBased.

#### Problema con los permisos de escritura

Durante las comprobaciones posteriores me encontré con otro problema.

Al iniciar sesión en W11-CL01 con el usuario de Admisión, podía ver únicamente su carpeta, pero Windows no me permitía crear archivos dentro de ella.

Al principio pensé que podía ser un problema de los permisos NTFS, pero comprobé que el grupo GG_Admision tenía permiso de Modificar.

Después revisé los permisos del recurso compartido principal y descubrí que, al restaurarlo, el grupo Todos había quedado configurado únicamente con permiso de Lectura.

Como Windows combina los permisos del recurso compartido con los permisos NTFS y aplica los más restrictivos, el usuario podía acceder a la carpeta, pero no escribir en ella.

Para solucionarlo cambié el permiso de Todos de Lectura a Cambiar, manteniendo Control total para GG_Admin_Ficheros.

Esta configuración no permite que todos los trabajadores modifiquen las carpetas de los demás departamentos, porque los permisos NTFS siguen controlando el acceso a cada una.

#### Comprobación final

Después de corregir los permisos, volví a realizar las pruebas con el usuario lgarciam.

Comprobé que:

- Solo podía visualizar la carpeta Admision.
- Podía entrar en ella correctamente.
- Podía crear un documento de texto.
- Podía modificarlo y guardar los cambios.
- Podía eliminar el archivo de prueba.

Con esto terminé de comprobar que tanto ABE como los permisos NTFS y los permisos del recurso compartido funcionaban correctamente.

Esta prueba me ha servido para entender mejor la diferencia entre los permisos de uso compartido y los permisos NTFS.

También he comprobado que Guardian puede ayudar a localizar una incidencia cuando el servidor sigue funcionando, pero un recurso concreto deja de estar disponible.

He guardado las capturas del funcionamiento normal, la incidencia y la recuperación en `docs/capturas`.

El código actualizado de Guardian v1.2 se encuentra en el historial de cambios de `scripts/Guardian.ps1`.

### Guardian v1.3: generación automática de informes

Después de terminar la segunda incidencia, he continuado mejorando Guardian para que no se limite a mostrar los resultados en PowerShell.

Quería que la herramienta también guardase un informe automáticamente después de cada diagnóstico.

La idea es que un técnico pueda ejecutar Guardian cuando tenga una incidencia y conservar un archivo con las comprobaciones realizadas, sin tener que copiar los resultados manualmente.

Para hacerlo he creado una carpeta llamada `Informes` dentro de Documentos del usuario que ejecuta Guardian.

Actualmente utilizo el usuario `andresferreiro` desde W11-CL01, que simula el ordenador de un técnico informático.

He decidido guardar los informes en el equipo cliente porque, si el servidor deja de funcionar, Guardian debe seguir pudiendo generar las evidencias del problema.

En esta nueva versión, Guardian v1.3, cada vez que ejecuto el script se genera automáticamente un archivo de texto con la fecha y la hora.

Por ejemplo:

```text
Documentos
├── Guardian.ps1
└── Informes
    └── Guardian_2026-11-22_21-34-28.txt
```

El informe contiene:

- Fecha y hora del diagnóstico.
- Nombre del equipo desde el que se ejecuta.
- Usuario que realiza las comprobaciones.
- Servidor analizado.
- Recurso compartido comprobado.
- Resultado de cada prueba.
- Resumen final de comprobaciones correctas, advertencias y errores.

De esta manera puedo conservar los resultados de diferentes ejecuciones y comparar lo que ocurría antes y después de solucionar una incidencia.

El código actualizado se encuentra en `scripts/Guardian.ps1`.

### Problema con los permisos de consulta de servicios

Durante las primeras pruebas de Guardian v1.3 apareció un problema que no tenía en las versiones anteriores.

Cuando ejecutaba el script con mi usuario `andresferreiro`, Guardian mostraba errores al comprobar los servicios DNS, NTDS y Netlogon.

Al principio parecía que los servicios no estaban funcionando, pero comprobé directamente desde SRV-AD01 que los tres estaban en ejecución.

Después ejecuté varias pruebas desde Windows 11 para localizar el problema.

Primero intenté consultar los servicios de forma remota mediante Get-Service y comprobé que no podía obtener sus estados correctamente.

También utilicé `sc.exe` para consultar el servicio DNS del servidor y recibí el mensaje de acceso denegado.

Finalmente probé con `Get-CimInstance`, pero también devolvía un error de permisos.

Con estas pruebas confirmé que el problema no estaba en los servicios, sino en que mi usuario no tenía autorización para consultarlos remotamente.

En lugar de convertir mi usuario en administrador del dominio, decidí mantener separados los permisos de administración de ficheros y los permisos del servidor.

Para solucionarlo modifiqué Guardian para que diferenciase tres situaciones:

- OK: la comprobación se ha realizado correctamente.
- ERROR: se ha podido confirmar un fallo.
- SIN PERMISOS: el usuario no tiene autorización suficiente para realizar la comprobación.

También se pueden mostrar alertas cuando hay un resultado inesperado que necesita revisión.

Después de modificar el script, los servicios DNS, NTDS y Netlogon dejaron de aparecer como errores y pasaron a mostrarse con el aviso SIN PERMISOS.

Esto me parece importante porque, si una herramienta no puede consultar un servicio, no debería indicar directamente que está detenido.

Al ejecutar nuevamente Guardian v1.3 obtuve cuatro comprobaciones correctas, tres advertencias por falta de permisos y ningún error.

Además, comprobé que estas advertencias también quedaban registradas en el informe automático.

He guardado capturas tanto de la ejecución como del archivo TXT generado.

### Tercera incidencia simulada: registro DNS incorrecto

Una vez que Guardian podía generar informes, decidí preparar una tercera incidencia para comprobar que también registraba los problemas detectados.

En este caso quería simular una resolución DNS incorrecta.

Antes de modificar nada, comprobé desde SRV-AD01 que el nombre `SRV-AD01.hosplab.local` resolvía únicamente a la dirección `10.10.10.10`.

Después añadí temporalmente un segundo registro DNS de tipo A con la dirección `10.10.10.99`.

La configuración quedó de esta manera:

- 10.10.10.10: dirección correcta del servidor.
- 10.10.10.99: dirección incorrecta añadida para simular la incidencia.

No cambié la dirección IP real de SRV-AD01, solamente añadí un registro DNS de prueba.

#### Detección de la incidencia

Después de añadir el registro incorrecto, ejecuté Guardian v1.3 desde W11-CL01.

La herramienta detectó que el DNS estaba devolviendo dos direcciones IP cuando solamente debería aparecer `10.10.10.10`.

Guardian mostró una alerta indicando que había encontrado registros DNS inesperados.

Mientras tanto, el servidor seguía respondiendo correctamente y el recurso compartido Hospital continuaba disponible.

También aparecían las tres advertencias habituales por falta de permisos para consultar los servicios del dominio.

Cuando terminó el diagnóstico, Guardian generó automáticamente un nuevo informe de texto.

Abrí el archivo y comprobé que la incidencia DNS también había quedado registrada.

De esta manera pude demostrar que Guardian no solamente muestra el problema en pantalla, sino que también guarda una evidencia con la fecha, el equipo y los resultados.

#### Recuperación del DNS

Después de guardar las capturas de la incidencia, volví a comprobar los registros DNS en SRV-AD01.

Al intentar eliminar el registro de prueba, PowerShell indicó que no encontraba el registro especificado.

Consulté nuevamente los registros y comprobé que solamente aparecía la dirección correcta `10.10.10.10`, por lo que no fue necesario realizar más cambios.

A continuación volví a ejecutar Guardian desde Windows 11.

Esta vez la comprobación DNS apareció correctamente y el script generó otro informe con el resultado de la recuperación.

Con esta prueba he podido comprobar que Guardian detecta una configuración DNS incorrecta y permite verificar que vuelve a funcionar correctamente.

Además, al guardar un informe de cada ejecución puedo conservar tanto el diagnóstico de la incidencia como el de su recuperación.

### Estado actual de Guardian

Actualmente he desarrollado Guardian hasta la versión 1.3.

La herramienta puede realizar las siguientes comprobaciones:

| Comprobación | Función |
|---|---|
| Conectividad | Comprobar si SRV-AD01 responde |
| DNS | Revisar si el nombre del servidor devuelve la IP correcta |
| Servicios | Consultar DNS, NTDS y Netlogon, diferenciando problemas de permisos |
| SMB | Comprobar si el puerto TCP 445 está disponible |
| Carpeta compartida | Comprobar si el usuario puede acceder al recurso Hospital |
| Informes | Guardar automáticamente los resultados en un archivo TXT |

Hasta el momento he realizado tres incidencias simuladas:

1. Caída completa del servidor SRV-AD01.
2. Eliminación temporal del recurso compartido Hospital.
3. Registro DNS incorrecto en SRV-AD01.

En las tres pruebas he comprobado cómo responde Guardian cuando aparece el problema y qué resultados muestra después de recuperar el funcionamiento normal.

Las capturas de las pruebas están guardadas en `docs/capturas` y el código de Guardian se encuentra en `scripts/Guardian.ps1`.

## Próximos pasos

Lo siguiente que quiero hacer es:

- Seguir mejorando Guardian para que los mensajes de diagnóstico sean más claros.
- Valorar la posibilidad de generar informes en otros formatos, además de TXT.
- Montar Ubuntu Server e instalar Zabbix.
- Configurar la monitorización de los equipos y servicios del laboratorio.
- Estudiar cómo relacionar los resultados de Guardian con las alertas de Zabbix.
- Continuar documentando los avances en GitHub y en la memoria del TFG.

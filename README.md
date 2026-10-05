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

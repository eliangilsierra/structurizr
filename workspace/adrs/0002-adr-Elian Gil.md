# 2. Elección del motor de base de datos relacional para el sistema CDA - Elian Gil

Date: 2025-08-22  

## Status  
Accepted  

## Context  
El sistema requiere almacenar información estructurada de propietarios, vehículos, citas, inspecciones y resultados. Los datos tienen **alta relacionalidad** (p. ej., un propietario puede tener varios vehículos, un vehículo puede tener múltiples inspecciones, cada inspección genera un checklist y pagos asociados).  

Se evaluaron opciones de almacenamiento:  
- **NoSQL (MongoDB/DynamoDB):** alta escalabilidad, pero complejidad en consultas relacionales.  
- **Relacional (PostgreSQL, MySQL, Aurora):** mejor soporte para transacciones ACID y relaciones entre entidades.  

Además, por requerimientos normativos (NTC 5375 y auditoría de procesos), es necesario garantizar **consistencia, trazabilidad y reportes normalizados**.  

## Decision  
Se optó por usar **PostgreSQL gestionado en Amazon RDS** como motor de base de datos relacional:  
- Cumple con los requerimientos de integridad y consistencia.  
- Permite consultas SQL complejas y reporting eficiente.  
- RDS aporta **alta disponibilidad** (multi-AZ), backups automáticos y seguridad administrada (KMS, IAM).  

## Consequences  
- Mayor facilidad para mantener relaciones complejas entre entidades.  
- Se asegura cumplimiento normativo y auditoría con menor esfuerzo.  
- Escalabilidad vertical/lateral gestionada por RDS.  
- Se introduce dependencia de un servicio cloud específico (AWS RDS).  

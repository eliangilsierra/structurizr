# 4. Estrategia multi-nube para el módulo de IA - Elian Gil

Date: 2025-06-06  

## Status  
Proposed  

## Context  
El sistema SIVIA utiliza IA para identificar defectos en vehículos. La primera opción fue entrenar y desplegar modelos en **AWS SageMaker**. Sin embargo, por costos y disponibilidad de modelos preentrenados, se evaluó usar **Google Cloud Vision AI/Vertex AI**.  

## Decision  
Se plantea una **estrategia multi-nube** en la cual el sistema orquesta la IA vía API, permitiendo interoperabilidad entre **SageMaker (AWS)** y **Vertex AI (Google)**. La decisión final se basará en criterios de costo, rendimiento y disponibilidad regional.  

## Consequences  
- Flexibilidad para elegir el proveedor más adecuado por caso de uso.  
- Complejidad adicional en integración y monitoreo multi-nube.  
- Evita dependencia total de un único proveedor cloud.  
- Posible aumento en latencia y costos de red por llamadas entre nubes.  

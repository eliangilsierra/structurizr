workspace "Automatizacion CDA" {


  model {
    propietario = person "Propietario del Vehículo" "Dueño del vehículo que agenda la cita" {
      tags "Propietario"
    }
    tecnico = person "Técnico del CDA" "Funcionario que realiza la revisión técnica" {
      tags "Tecnico"
    }

    sistema = softwareSystem "Sistema de Agendamiento RTM" {
      propietario -> this "Accede para agendar citas y subir documentos"
      tecnico -> this "Revisa información y resultados"
      
      gw = container "Api Gateway" "Punto de entrada de todas las solicitudes Web" "Aws Gw" {
          tag "Amazon Web Services - API Gateway"
      }

      webapp = container "Frontend Web" "Interfaz de usuario para agendamiento y seguimiento" "React" {
          tag "Amazon Web Services - CloudFront"
      }
      balanceador = container "Balanceador de Carga" "Balancea la carga de solicitudes en los diferentes endpoints" "Aws Load Balancer" {
          tag "Amazon Web Services - Elastic Load Balancing	"
      }
      api1 = container "API Backend 1" "Lógica de negocio, validación y conexión con IA" "Node.js + Express"{
          tag "Amazon Web Services - EKS Cloud"
      }
      
    api2 = container "API Backend 2" "Lógica de negocio, validación y conexión con IA" "Node.js + Express"{
          tag "Amazon Web Services - EKS Cloud"
      }
      
    api3 = container "API Backend 3" "Lógica de negocio, validación y conexión con IA" "Node.js + Express"{
          tag "Amazon Web Services - EKS Cloud"
      }
      
      
      db = container "Base de Datos" "Guarda citas, usuarios, documentos" "PostgreSQL" {
        tags "BD"
      }
      ia = container "SIVIA - Sistema de Inspección Visual Automatizado por IA" "Servicio de IA para validar fotos/documentos" "API externa (Python)"

      propietario -> webapp "Utiliza desde navegador"
        webapp -> gw "Enruta Solicitudes"
        gw -> balanceador "Balancea la carga de solicitudes"
                balanceador -> api1 "Balancea la carga de solicitudes"
                balanceador -> api2 "Balancea la carga de solicitudes"
                balanceador -> api3 "Balancea la carga de solicitudes"
      tecnico -> gw "Consulta información de citas"
      api1 -> db "Lee y guarda datos"
      api1 -> ia "Envía imágenes para validación"
            api2 -> db "Lee y guarda datos"
      api2 -> ia "Envía imágenes para validación"      
      api3 -> db "Lee y guarda datos"
      api3 -> ia "Envía imágenes para validación"
    }
  }

  views {
    systemContext sistema {
      include *
      autolayout lr
      description "Diagrama de contexto del sistema de agendamiento RTM"
    }

    container sistema {
      include *
      autolayout lr
      description "Diagrama de contenedores: estructura interna del sistema"
    }

    styles {
      element "Software System" {
        background #801515
        shape RoundedBox
        icon https://cdn-icons-png.flaticon.com/512/8759/8759069.png
      }

      element "Person" {
        background #d46a6a
        colour #000000
        shape Person
      }

      element "Propietario" {
        shape Person
        background #f4d03f
      }

      element "Tecnico" {
        shape Robot
        background #76d7c4
      }
      
    element "BD" {
        shape Cylinder
        background #3b5998
        color #ffffff
      }

      relationship "Relationship" {
        dashed false
      }
    }
    
    theme https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json

  }

}


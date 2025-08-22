workspace "Automatización Revision Tecnico Mecanica" "Modelo de arquitectura C4 para el sistema de automatización de la RTM en un CDA." {

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }

        actores = group "Actores del Sistema" {
            propietario = person "Propietario del Vehículo" "Dueño del vehículo que agenda y gestiona la revisión."
            tecnico = person "Técnico del CDA" "Funcionario que realiza la revisión y consulta resultados."
            director = person "Director CDA" "Valida el cumplimiento y la emisión de certificados."
        }
        
        sistema = softwareSystem "Plataforma central para el agendamiento y la inspección automatizada 'SIVIA'" {
            !docs docs
            !adrs adrs

            interfaces = group "Interfaces de Usuario" {
                webapp = container "Frontend Web" "Interfaz de usuario para agendamiento, pagos y seguimiento en tiempo real." "React" "Browser" {
                    propietario -> this "Usa para agendar, pagar y seguir la revisión"
                    tecnico -> this "Consulta información de citas" "HTTPS"
                    director -> this "Consulta reportes y resultados" "HTTPS"
                    
                    ClientView = component "Vista Cliente" "Componente de UI para gestión de citas, pagos y seguimiento." "React Component"
                    TechView = component "Vista Técnico" "Componente de UI para revisar vehículos agendados y monitorear inspección." "React Component"
                    DirectorView = component "Vista Director" "Componente de UI para visualizar y aprobar reportes." "React Component"
                    apiClient = component "Cliente API" "Encapsula la comunicación HTTP con el backend." "Axios"

                    ClientView -> apiClient "Usa"
                    TechView -> apiClient "Usa"
                    DirectorView -> apiClient "Usa"
                }
            }
            
            serviciosBackend = group "Servicios de Backend" {
                gw = container "API Gateway" "Punto de entrada único para todas las solicitudes del cliente." "Amazon API Gateway" {
                    apiClient -> this "Realiza solicitudes" "HTTPS"

                }

                balanceador = container "Balanceador de Carga" "Distribuye el tráfico entrante entre las instancias de la API." "AWS Elastic Load Balancer" {
                    gw -> this "Enruta tráfico"
                }

                IA = container "IA Procesamiento de imagenes" "IA entrenada para la identificación de defectos." "Google Cloud Vision AI / Vertex AI" {
                    gw -> this "Enruta tráfico"
                }                

                api = container "API de Negocio" "Provee la lógica de negocio, validaciones y orquestación de servicios." "Node.js + Express" {
                    balanceador -> this "Recibe solicitudes"

                    citasController = component "Controlador de Citas" "Gestiona las operaciones de agendamiento y pagos." "Express Controller"
                    inspeccionController = component "Controlador de Inspección" "Gestiona el flujo de la inspección y notificaciones." "Express Controller"
                    validacionService = component "Servicio de Validación" "Valida SOAT y otros documentos contra sistemas externos." "JavaScript"
                    comunicacionIA = component "Cliente SIVIA" "Se comunica con el sistema de IA para enviar imágenes y recibir resultados." "Axios"
                    repositorio = component "Repositorio de Datos" "Gestiona el acceso y la persistencia de datos." "Sequelize"

                    citasController -> validacionService "Usa para validar SOAT"
                    citasController -> repositorio "Persiste citas y pagos"
                    inspeccionController -> comunicacionIA "Envía datos a SIVIA"
                    inspeccionController -> repositorio "Guarda resultados de inspección"
                }

                database = container "Base de Datos" "Almacena datos de usuarios, citas, vehículos y resultados de la inspección." "PostgreSQL" "db" {
                    repositorio -> this "Lee y escribe" "JDBC"
                }
            }
        }
        
        sistemasExternos = group "Sistemas Externos" {
            entidadesRegulatorias = softwareSystem "Entidades Regulatorias" "Sistemas como RUNT para validación de documentos." "Existing System" {
                validacionService -> this "Consulta validez de SOAT" "SOAP/REST"
            }
            CamaraSET = softwareSystem "Set de Cámaras" "Set de Cámaras para inspección visual" "Existing System" {
                validacionService -> this "Capturan imágenes para procesamiento"
            }
        }

        deploymentEnvironment "Producción (Cloud AWS)" {
            deploymentNode "Amazon Web Services" "" "us-east-1" {
                tags "Amazon Web Services - Cloud"
                
                deploymentNode "Amazon CloudFront" "CDN para distribuir la interfaz de usuario." {
                    tags "Amazon Web Services - CloudFront"
                    containerInstance webapp
                }

                deploymentNode "Amazon API Gateway" "Servicio gestionado para APIs." {
                    tags "Amazon Web Services - API Gateway"
                    containerInstance gw
                }

                deploymentNode "Elastic Load Balancer" "Balanceador de carga de aplicación." {
                    tags "Amazon Web Services - Elastic Load Balancing"
                    containerInstance balanceador
                }

                deploymentNode "Amazon EKS" "Servicio de Kubernetes para orquestar los contenedores de la API." {
                    tags "Amazon Web Services - EKS"
                    deploymentNode "Nodo 1" "Instancia EC2" {
                        containerInstance api
                    }
                    deploymentNode "Nodo 2" "Instancia EC2" {
                        containerInstance api
                    }
                }

                deploymentNode "Amazon RDS" "Servicio de Base de Datos relacional gestionada." {
                    tags "Amazon Web Services - RDS"
                    deploymentNode "Instancia PostgreSQL" {
                        tags "Amazon Web Services - RDS PostgreSQL Instance"
                        containerInstance database
                    }
                }
            }
        }
    }
    

views {
    properties {
        "plantuml.url" "https://plantuml.com/plantuml"
    }

    systemContext sistema VistaContexto "Diagrama de contexto del SIVIA." {
        include *
        autoLayout tb
    }

    container sistema VistaContenedores "Diagrama de contenedores del sistema." {
        include *
        autoLayout tb
    }

    component webapp VistaFrontend "Componentes de la aplicación web." {
        include *
        autoLayout tb
    }

    component api VistaBackend "Componentes de la API de Negocio." {
        include *
        autoLayout tb
    }

    deployment * "Producción (Cloud AWS)" {
        include *
        autoLayout lr
    }

    image api SecuenciaAgendamiento {
        plantuml "seq.plant"
        title "Diagrama de Secuencia - Agendamiento (Placeholder)"
    }

    themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json

    styles {
        element "Component" {
            shape Component
        }
        element "db" {
            shape Cylinder
        }
        element "Browser" {
            shape WebBrowser
        }
        element "Existing System" {
            background #999999
            color #ffffff
        }
        element "Person" {
            shape Person
            background #f4d03f
        }
    }
}
}
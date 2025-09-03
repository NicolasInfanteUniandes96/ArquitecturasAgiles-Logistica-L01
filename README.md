# calculo de ruta 3-opt

El siguiente repositorio tiene como objetivo formar parte de un experimento para la clase de Arquitecturas Agiles de Software

Things you may want to cover:

* config/json -> matriz cargada simulando la bodega
* service/logistics/route_planner -> planificador de la ruta
* service/logistics/three_opt -> algoritmo para el calculo de la ruta
* app/controller/logistic_controller -> llama a los servicios y entrega respuesta

## Probar: 
curl -s -X POST http://localhost:3000/logistic/route -H 'Content-Type: application/json' -d '{"points":"P1, P3, P4, P6, P18, P5, P2, P11, P7, P10"}' | jq

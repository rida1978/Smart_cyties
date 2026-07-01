### Flujo de una transacción desde el sensor hasta el actuador

El proceso comienza cuando un sensor IoT basado en ESP32 detecta un cambio en una de las variables monitorizadas. Como consecuencia de este evento, el dispositivo actualiza el valor del sensor (0 o 1) y publica dicha información en un tópico MQTT previamente definido.

El mensaje es recibido por el broker MQTT, que actúa como intermediario entre los dispositivos IoT y el sistema de gestión. Posteriormente, Node-RED, suscrito al mismo tópico MQTT, recibe automáticamente el mensaje y extrae el identificador del sensor junto con su nuevo estado.

A continuación, Node-RED construye una transacción dirigida al contrato inteligente desplegado en la red Ethereum Sepolia. La transacción invoca la función `cambiarDatos()`, encargada de actualizar el array que almacena el estado de los diez sensores registrados en la blockchain.

Antes de ser enviada a la red Ethereum, la transacción es firmada criptográficamente utilizando la clave privada asociada a la cuenta autorizada. Esta firma garantiza la autenticidad del emisor y evita modificaciones no autorizadas sobre el contrato inteligente.

Una vez firmada, la transacción es transmitida mediante el protocolo JSON-RPC hacia un nodo de la red Ethereum Sepolia. La red valida la firma digital, verifica que la transacción cumple las reglas del contrato inteligente y la incorpora a un nuevo bloque tras el proceso de consenso.

Cuando la transacción queda confirmada, el contrato inteligente actualiza de forma permanente el estado del sensor correspondiente dentro del array almacenado en la blockchain y genera un evento (*event*) que registra la modificación realizada. Dicho evento incluye información como el identificador del sensor, el nuevo valor almacenado, la dirección de la cuenta que realizó la modificación y la marca temporal de la transacción, proporcionando trazabilidad e inmutabilidad sobre todas las operaciones efectuadas.

Finalmente, Node-RED detecta la confirmación de la transacción y consulta nuevamente el estado almacenado en el contrato inteligente mediante la función `consultarDatos()`. Si el nuevo valor requiere una actuación física, Node-RED publica un nuevo mensaje MQTT dirigido al actuador correspondiente. El actuador recibe la orden a través del broker MQTT y ejecuta la acción requerida, como activar un relé, encender una alarma o modificar el estado de un dispositivo conectado.

De esta forma, la arquitectura propuesta combina la baja latencia del protocolo MQTT para la comunicación entre dispositivos IoT con las propiedades de integridad, autenticidad, trazabilidad e inmutabilidad proporcionadas por la tecnología blockchain, garantizando que todas las modificaciones de los sensores quedan registradas de forma permanente y verificable.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartCitySensors {

    struct Sensor {
        string nombre;
        uint8 dato; // 4 bits (0-15)
    }

    Sensor[10] private sensores;

    // Evento que se genera cuando cambia un sensor
    event SensorActualizado(
        uint8 indexed sensorId,
        uint8 valorAnterior,
        uint8 valorNuevo,
        uint256 timestamp
    );

    constructor() {

        for (uint8 i = 0; i < 10; i++) {

            uint8 valorInicial;

            // Sensores 1,3,5,7,9 -> 0
            // Sensores 2,4,6,8,10 -> 1
            if ((i + 1) % 2 == 0) {
                valorInicial = 1;
            } else {
                valorInicial = 0;
            }

            sensores[i] = Sensor(
                string(
                    abi.encodePacked(
                        "sensor",
                        uint2str(i + 1)
                    )
                ),
                valorInicial
            );
        }
    }

    /**
     * Devuelve los valores de los 10 sensores
     */
    function consultarDatos()
        public
        view
        returns (uint8[10] memory valores)
    {
        for (uint8 i = 0; i < 10; i++) {
            valores[i] = sensores[i].dato;
        }
    }

    /**
     * Actualiza los 10 sensores
     * Genera un evento si un sensor cambia
     */
    function cambiarDatos(
        uint8[10] memory nuevosValores
    ) public {

        for (uint8 i = 0; i < 10; i++) {

            require(
                nuevosValores[i] <= 15,
                "Valor fuera de rango (4 bits)"
            );

            uint8 valorAnterior = sensores[i].dato;

            if (valorAnterior != nuevosValores[i]) {

                sensores[i].dato = nuevosValores[i];

                emit SensorActualizado(
                    i + 1,
                    valorAnterior,
                    nuevosValores[i],
                    block.timestamp
                );
            }
        }
    }

    /**
     * Devuelve nombre y valor de los sensores
     */
    function consultarSensores()
        public
        view
        returns (
            string[10] memory nombres,
            uint8[10] memory valores
        )
    {
        for (uint8 i = 0; i < 10; i++) {
            nombres[i] = sensores[i].nombre;
            valores[i] = sensores[i].dato;
        }
    }

    /**
     * Convierte uint a string
     */
    function uint2str(
        uint256 _i
    ) internal pure returns (
        string memory str
    ) {

        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 length;

        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);

        uint256 k = length;

        while (_i != 0) {
            k--;
            bstr[k] = bytes1(
                uint8(48 + _i % 10)
            );
            _i /= 10;
        }

        str = string(bstr);
    }
}
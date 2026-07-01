// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartCitySensors {

    struct Sensor {
        string nombre;
        uint8 dato;              // Solo 0 o 1
        address clavePublica;    // Dirección pública del sensor
        bool registrado;
    }

    Sensor[10] private sensores;

    event SensorRegistrado(
        uint8 indexed sensorId,
        string nombre,
        address clavePublica
    );

    event SensorActualizado(
        uint8 indexed sensorId,
        uint8 valorAnterior,
        uint8 valorNuevo,
        uint256 timestamp
    );

    event SensorAutenticado(
        uint8 indexed sensorId,
        address sensor
    );

    event SensorNoAutenticado(
        uint8 indexed sensorId,
        address remitente
    );

    constructor() {
        for (uint8 i = 0; i < 10; i++) {
            sensores[i].nombre = string(
                abi.encodePacked("Sensor", uint2str(i + 1))
            );
            sensores[i].dato = 0;
            sensores[i].registrado = false;
        }
    }

    /**
     * Registrar un sensor
     */
    function registrarSensor(
        uint8 sensorId,
        address clavePublica
    ) public {

        require(sensorId < 10, "Sensor inexistente");
        require(!sensores[sensorId].registrado, "Sensor ya registrado");

        sensores[sensorId].clavePublica = clavePublica;
        sensores[sensorId].registrado = true;
        sensores[sensorId].dato = 0;

        emit SensorRegistrado(
            sensorId,
            sensores[sensorId].nombre,
            clavePublica
        );
    }

    /**
     * Verifica la firma del sensor
     */
    function verificarSensor(
        uint8 sensorId,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {

        require(sensorId < 10, "Sensor inexistente");
        require(sensores[sensorId].registrado, "Sensor no registrado");

        address firmante = ecrecover(hash, v, r, s);

        if (firmante == sensores[sensorId].clavePublica) {
            emit SensorAutenticado(sensorId, firmante);
            return true;
        }

        emit SensorNoAutenticado(sensorId, firmante);
        return false;
    }

    /**
     * Actualiza el dato del sensor si la firma es válida
     */
    function escribirDatoFirmado(
        uint8 sensorId,
        uint8 nuevoDato,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(sensorId < 10, "Sensor inexistente");
        require(nuevoDato <= 1, "Solo 0 o 1");

        require(
            verificarSensor(sensorId, hash, v, r, s),
            "Firma no valida"
        );

        uint8 anterior = sensores[sensorId].dato;

        if (anterior != nuevoDato) {
            sensores[sensorId].dato = nuevoDato;

            emit SensorActualizado(
                sensorId,
                anterior,
                nuevoDato,
                block.timestamp
            );
        }
    }

    /**
     * Leer un sensor
     */
    function leerSensor(uint8 sensorId)
        public
        view
        returns (uint8)
    {
        require(sensorId < 10, "Sensor inexistente");
        return sensores[sensorId].dato;
    }

    /**
     * Leer todos los sensores
     */
    function consultarSensores()
        public
        view
        returns (
            string[10] memory nombres,
            uint8[10] memory datos,
            address[10] memory claves
        )
    {
        for (uint8 i = 0; i < 10; i++) {
            nombres[i] = sensores[i].nombre;
            datos[i] = sensores[i].dato;
            claves[i] = sensores[i].clavePublica;
        }
    }

    /**
     * Convierte uint a string
     */
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory str)
    {
        if (_i == 0) return "0";

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
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }

        str = string(bstr);
    }
}
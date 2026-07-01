#include <WiFi.h>
#include <EEPROM.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ===================== CONFIG =====================
const char* ssid = "WIFI_Casa";
const char* password = "Malaga_1978";

// Sepolia RPC (puedes usar Infura o Alchemy)
const char* rpc_url = "https://sepolia.infura.io/v3/*";

// Contrato
const char* contractAddress = "0xb2403044f296Bf4d3d6Dd95Ec3FB3197eA5C9875";

// EEPROM
#define EEPROM_SIZE 512

// ===================================================

// 🔐 Clave privada (NO en claro en producción)
String privateKey;

// ===================== ABI =========================
const char* abi = R"([
{"inputs":[{"internalType":"uint8[10]","name":"nuevosValores","type":"uint8[10]"}],
"name":"cambiarDatos","outputs":[],"stateMutability":"nonpayable","type":"function"},

{"inputs":[],"name":"consultarDatos",
"outputs":[{"internalType":"uint8[10]","name":"valores","type":"uint8[10]"}],
"stateMutability":"view","type":"function"}
])";

// ===================== EEPROM ======================
void savePrivateKey(String key) {
  for (int i = 0; i < key.length(); i++) {
    EEPROM.write(i, key[i]);
  }
  EEPROM.write(key.length(), '\0');
  EEPROM.commit();
}

String loadPrivateKey() {
  String key = "";
  char c;
  for (int i = 0; i < 66; i++) {
    c = EEPROM.read(i);
    if (c == '\0') break;
    key += c;
  }
  return key;
}

// ===================== WIFI ========================
void connectWiFi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

// ===================== ETH RPC =====================
// Enviar llamada JSON-RPC (base)
String sendRPC(String payload) {
  HTTPClient http;
  http.begin(rpc_url);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST(payload);
  String response = http.getString();
  http.end();

  return response;
}

// ===================== UPDATE SENSOR ===============
void updateSensor(uint8_t index, uint8_t value) {

  StaticJsonDocument<512> doc;

  doc["jsonrpc"] = "2.0";
  doc["method"] = "eth_sendRawTransaction";

  JsonArray params = doc.createNestedArray("params");

  // ⚠️ Aquí iría la transacción firmada
  String rawTx = "0xSIGNED_TRANSACTION";

  params.add(rawTx);
  doc["id"] = 1;

  String output;
  serializeJson(doc, output);

  String response = sendRPC(output);

  Serial.println("TX response:");
  Serial.println(response);
}

// ===================== READ SENSOR ================
void readSensors() {

  StaticJsonDocument<256> doc;
  doc["jsonrpc"] = "2.0";
  doc["method"] = "eth_call";

  JsonArray params = doc.createNestedArray("params");

  JsonObject tx = params.createNestedObject();
  tx["to"] = contractAddress;
  tx["data"] = "0x6b7fb95e"; // selector consultarSensores()

  params.add("latest");
  doc["id"] = 1;

  String output;
  serializeJson(doc, output);

  String response = sendRPC(output);

  Serial.println(response);
}

// ===================== SETUP =======================
void setup() {
  Serial.begin(115200);
  EEPROM.begin(EEPROM_SIZE);

  connectWiFi();

  // cargar clave privada desde EEPROM
  privateKey = loadPrivateKey();

  Serial.println("ESP32 Blockchain Node Ready");

  // ejemplo: leer sensores
  readSensors();

  // ejemplo: actualizar sensor 3 a 1
  updateSensor(3, 1);
}

// ===================== LOOP ========================
void loop() {
}
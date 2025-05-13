import random
import os
from io import BytesIO
from fastapi import FastAPI, HTTPException, UploadFile, Form
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

app = FastAPI()

# ✅ Enable CORS for all origins (for development only)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Use specific origins like ["http://localhost:3000"] in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------- BB84 Simulation ----------------------
def simulate_bb84(key_length=256, initial_bits=2048, eavesdrop_probability=0.3):
    alice_bits = [random.choice([0, 1]) for _ in range(initial_bits)]
    alice_bases = [random.choice([0, 1]) for _ in range(initial_bits)]
    bob_bases = [random.choice([0, 1]) for _ in range(initial_bits)]
    eve_bases = [random.choice([0, 1]) for _ in range(initial_bits)]
    bob_measurements = []

    backend = AerSimulator()
    for i in range(initial_bits):
        qc = QuantumCircuit(1, 1)
        if alice_bits[i] == 1:
            qc.x(0)
        if alice_bases[i] == 1:
            qc.h(0)

        # Eavesdrop simulation
        if random.random() < eavesdrop_probability:
            if eve_bases[i] == 1:
                qc.h(0)
            qc.measure(0, 0)
            new_qc = QuantumCircuit(1, 1)
            if eve_bases[i] == 1:
                new_qc.h(0)
            new_qc.measure(0, 0)
            job = backend.run(new_qc, shots=1)
            result = job.result()
            counts = result.get_counts()
            if counts:
                measured_bit = int(list(counts.keys())[0])
                if measured_bit == 1:
                    new_qc = QuantumCircuit(1, 1)
                    new_qc.x(0)
                    if eve_bases[i] == 1:
                        new_qc.h(0)
                qc = new_qc

        if bob_bases[i] == 1:
            qc.h(0)
        qc.measure(0, 0)
        job = backend.run(qc, shots=1)
        result = job.result()
        counts = result.get_counts()
        measured_bit = int(list(counts.keys())[0])
        bob_measurements.append(measured_bit)

    shared_indices = [i for i in range(initial_bits) if alice_bases[i] == bob_bases[i]]
    if len(shared_indices) < key_length + key_length // 10:
        raise ValueError("Not enough shared bits to generate the key")

    check_bits = random.sample(shared_indices, key_length // 10)
    error_count = sum(1 for i in check_bits if alice_bits[i] != bob_measurements[i])
    qber = error_count / len(check_bits)

    if qber > 0.2:
        raise ValueError(f"Possible eavesdropping detected (QBER: {qber:.2%})")

    key_indices = [i for i in shared_indices if i not in check_bits][:key_length]
    key = [alice_bits[i] for i in key_indices]
    return key, qber

# ---------------------- Helpers ----------------------
def bits_to_bytes(bits):
    byte_array = bytearray()
    for i in range(0, len(bits), 8):
        byte = bits[i:i+8]
        if len(byte) == 8:
            byte_val = int(''.join(map(str, byte)), 2)
            byte_array.append(byte_val)
    return bytes(byte_array)

def encrypt_data(key, data):
    iv = os.urandom(16)
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    padder = padding.PKCS7(128).padder()
    padded_data = padder.update(data) + padder.finalize()
    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    return iv + ciphertext


def decrypt_data(key, encrypted_data):
    iv = encrypted_data[:16]
    ciphertext = encrypted_data[16:]
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    padded_plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    unpadder = padding.PKCS7(128).unpadder()
    plaintext = unpadder.update(padded_plaintext) + unpadder.finalize()
    return plaintext

# ---------------------- Routes ----------------------

@app.post("/generate-key/")
async def generate_key():
    try:
        key, qber = simulate_bb84()
        key_str = ''.join(str(bit) for bit in key)
        return {"key": key_str}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/encrypt/")
async def encrypt_endpoint(file: UploadFile, key: str = Form(...)):
    try:
        data = await file.read()
        byte_key = bits_to_bytes([int(b) for b in key if b in '01'])
        if len(byte_key) not in [16, 24, 32]:
            raise ValueError("Invalid AES key length after conversion")
        encrypted = encrypt_data(byte_key, data)
        return StreamingResponse(BytesIO(encrypted), media_type="application/octet-stream")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Encryption failed: {e}")
    

@app.post("/decrypt/")
async def decrypt_endpoint(file: UploadFile, key: str = Form(...)):
    try:
        data = await file.read()
        byte_key = bits_to_bytes([int(b) for b in key if b in '01'])
        if len(byte_key) not in [16, 24, 32]:
            raise ValueError("Invalid AES key length after conversion")
        decrypted = decrypt_data(byte_key, data)
        return StreamingResponse(BytesIO(decrypted), media_type="application/octet-stream")

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Decryption failed: {e}")


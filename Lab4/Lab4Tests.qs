// QSD Lab 4 Tests
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace Lab4 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    @Test("QuantumSimulator")
    operation Exercise1Test () : Unit {
        let buffers = [
            [false, false],
            [false, true],
            [true, false],
            [true, true]
        ];

        for i in 1 .. 10 {
            for buffer in buffers {
                use qubits = Qubit[2];
                H(qubits[0]);
                CNOT(qubits[0], qubits[1]);

                Exercise1(buffer, qubits[0]);

                CNOT(qubits[0], qubits[1]);
                H(qubits[0]);

                EqualityFactB(
                    ResultAsBool(M(qubits[0])),
                    buffer[0],
                    "First qubit is incorrect."
                );
                EqualityFactB(
                    ResultAsBool(M(qubits[1])),
                    buffer[1],
                    "Second qubit is incorrect."
                );

                ResetAll(qubits);
            }
        }
    }


    @Test("QuantumSimulator")
    operation Exercise2Test () : Unit {
        let buffers = [
            [false, false],
            [false, true],
            [true, false],
            [true, true]
        ];

        for i in 1 .. 10 {
            for buffer in buffers {
                use qubits = Qubit[2];
                H(qubits[0]);
                CNOT(qubits[0], qubits[1]);
                if buffer[1] {
                    X(qubits[0]);
                }
                if buffer[0] {
                    Z(qubits[0]);
                }

                let result = Exercise2(qubits[0], qubits[1]);

                AllEqualityFactB(
                    result,
                    buffer,
                    "Exercise 2 result is incorrect."
                );

                ResetAll(qubits);
            }
        }
    }
}
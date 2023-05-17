// Solutions for Lab 2: Working with Qubit Registers
// Copyright 2023 The MITRE Corporation. All Rights Reserved.

namespace Lab2 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;


    operation Exercise1 (qubits : Qubit[]) : Unit {
        for i in 0 .. Length(qubits) - 1 {
            let angle = PI() / 12.0 * IntAsDouble(i);
            Ry(angle, qubits[i]);
        }
    }


    operation Exercise2 (qubits : Qubit[]) : Int[] {
        mutable resultArray = [];

        for qubit in qubits {
            let result = M(qubit);
            let resultInt = (result == One ? 1 | 0);
            set resultArray += [resultInt];
        }

        return resultArray;
    }


    operation Exercise3 (register : Qubit[]) : Unit {
        ApplyToEach(H, register);

        // Alternate Solution:
        // for qubit in register {
        //     H(qubit);
        // }
    }


    operation Exercise4 (register : Qubit[]) : Unit {
        Z(register[Length(register) - 1]);
    }
}
// Quantum Software Development
// Final Project Tests
// 
// Elizabeth Foster
//

namespace FinalProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;

    @Test("QuantumSimulator")
    operation TwosComplementTest () : Unit {

        for k in 2 .. 10 {
            let numQubits = k;
            use register = Qubit[numQubits];
            let maxSize = 2^(numQubits - 1) - 1;

            for i in 0 .. maxSize {
                mutable decimalNumber = i;
                for j in 0 .. decimalNumber {
                    if decimalNumber % 2 == 1 {
                        X(register[j]);
                    }
                    set decimalNumber = decimalNumber / 2;
                } 

                let secondRegister = TwosComplement(register);
                let thirdRegister = TwosComplement(secondRegister);
                set decimalNumber = i;

                for j in 0 .. decimalNumber {
                    if decimalNumber % 2 == 1 {
                        X(register[j]);
                    }
                    set decimalNumber = decimalNumber / 2;
                }
                AssertAllZero(thirdRegister);
            }
        }
    }
}




                // Message($"The negative version of {i}");
                // let result4 = M(secondRegister[3]);
                // Message($"3rd qubit = {result4}");
                // let result3 = M(secondRegister[2]);
                // Message($"2nd qubit = {result3}");
                // let result2 = M(secondRegister[1]);
                // Message($"1st qubit = {result2}");
                // let result1 = M(secondRegister[0]);
                // Message($"0th qubit = {result1}");
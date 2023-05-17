// Quantum Software Development
// Final Project
//
// Elizabeth Foster
//
// TODO: make the comments pretty

namespace FinalProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// For this assignment, I have chose to study, implement and, explain
    /// the two's complement algorithm. Two's complement is an integer 
    /// arithmetic operation that converts a positive binary number to a 
    /// negative binary number.
    /// 
    /// In binary, a signed number's left-most bit serves as a signed bit.
    /// When the signed bit is 0, the integer is positive. When the signed
    /// bit is 1, the integer is negative.
    /// 
    /// Representing and working with negative numbers is necessary on a
    /// quantum computer [quote examples in papers]
    /// [include why it is important that we are able to do this without measurement]
    /// include the choice to measure as a question and the process of comparing
    /// to the provided circuit
    /// 
    /// The following function takes a qubit register of unknown length in 
    /// an unknown state. This register represents an integer. The function
    /// then performs an in-place operation and the register of qubits now
    /// represents the negative version of the initial integer.
    /// 
    /// # Input
    /// ## register
    /// A qubit register with unknown length in an unknown state
    /// 
    /// # Output
    /// A qubit register holding a negative integer represented in binary
    ///

    operation TwosComplement (register: Qubit[]) : Qubit [] {
        
        let indexOfFinalQubit = Length(register) - 1;

        for i in 0 .. indexOfFinalQubit {
            X(register[i]);
        }

        for j in 0 .. indexOfFinalQubit - 1 {
            let index = indexOfFinalQubit - j - 1;
            if index == 0 {
                X(register[index]);
            } else {
                Controlled X(register[0 .. index - 1], register[index]);
            }
        }

        return register;
    }

}
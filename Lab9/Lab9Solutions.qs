// // Solutions for QSD Lab 9: Shor's Factorization Algorithm
// // Copyright 2023 The MITRE Corporation. All Rights Reserved.

// namespace Lab9 {

//     open Microsoft.Quantum.Arithmetic;
//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Convert;
//     open Microsoft.Quantum.Intrinsic;
//     open Microsoft.Quantum.Math;
//     open Microsoft.Quantum.Measurement;


//     operation Exercise1_ModExp (
//         a : Int,
//         b : Int,
//         input : Qubit[],
//         output : Qubit[]
//     ) : Unit {
//         X(output[Length(output) - 1]);              // output = |0...01>
//         let outputAsLE = LittleEndian(output);

//         let inputSize = Length(input);
//         for i in 0..inputSize - 1 {
//             let powerOfTwo = inputSize - 1 - i;     // n-i-1
//             let powerOfGuess = 2 ^ powerOfTwo;      // 2^(n-i-1)

//             let c = ExpModI(a, powerOfGuess, b);    // c = A^(2^(n-i-1)) mod B
//             Controlled MultiplyByModularInteger(    // |O> = |O> * c mod B
//                 [input[i]],
//                 (c, b, outputAsLE)
//             );
//         }
//     }


//     operation Exercise2_FindApproxPeriod (
//         numberToFactor : Int,
//         guess : Int
//     ) : (Int, Int) {
//         // Number of bits needed to represent NumberToFactor
//         let outputSize = Ceiling(Lg(IntAsDouble(numberToFactor + 1)));

//         use (input, output) = (Qubit[outputSize * 2], Qubit[outputSize]);
//         ApplyToEach(H, input); // Input = |+...+>, so all possible states at once
//         Exercise1_ModExp(guess, numberToFactor, input, output);
//         Adjoint QFT(BigEndian(input)); // IQFT
//         let result = MeasureInteger(BigEndianAsLittleEndian(BigEndian(input)));
//         ResetAll(output);

//         return (result, 2 ^ (outputSize * 2));
//     }


//     function Exercise3_FindPeriodCandidate (
//         numerator : Int,
//         denominator : Int,
//         denominatorThreshold : Int
//     ) : (Int, Int) {
//         mutable a_i = 0;            // Coefficient
//         mutable P_i = numerator;    // Numerator
//         mutable Q_i = denominator;  // Denominator
//         mutable r_i = 0;            // Remainder

//         mutable n_i = 0;            // Convergent numerator
//         mutable n_i1 = 1;           // Convergent numerator from previous iteration
//         mutable n_i2 = 0;           // Convergent numerator from 2 iterations previous

//         mutable d_i = 0;            // Convergent denominator
//         mutable d_i1 = 0;           // Convergent denominator from previous iteration
//         mutable d_i2 = 1;           // Convergent denominator from 2 iterations previous

//         while true {
//             // Calculate current coefficient, remainder, and convergent
//             set a_i = P_i / Q_i;
//             set r_i = P_i % Q_i;
//             set n_i = a_i * n_i1 + n_i2;
//             set d_i = a_i * d_i1 + d_i2;

//             // Return if d_i > threshold
//             if d_i > denominatorThreshold {
//                 return (n_i1, d_i1);
//             }

//             // Return if r_i == 0
//             if r_i == 0 {
//                 return (n_i, d_i);
//             }

//             set P_i = Q_i;
//             set Q_i = r_i;
//             set n_i2 = n_i1;
//             set n_i1 = n_i;
//             set d_i2 = d_i1;
//             set d_i1 = d_i;
//         }

//         // This should never happen
//         return (-1, -1);
//     }


//     operation Exercise4_FindPeriod (numberToFactor : Int, guess : Int) : Int {
//         mutable periodFactor = 1;
//         mutable remainder = 0;
//         Message($"Finding the period of {guess}^x mod {numberToFactor}...");

//         repeat {
//             let (specialState, numberOfStates) = Exercise2_FindApproxPeriod(numberToFactor, guess);
//             Message($"Measured {specialState} / {numberOfStates}");

//             if (specialState == 0) {
//                 Message("Measured 0 which won't help, have to try again.");
//             } else {
//                 let (n, d) = Exercise3_FindPeriodCandidate(specialState, numberOfStates, numberToFactor);
//                 Message($"Found a period factor of {d}");

//                 set periodFactor = d * periodFactor / GreatestCommonDivisorI(d, periodFactor);
//                 Message($"Current largest factor: {periodFactor}");

//                 set remainder = ExpModI(guess, periodFactor, numberToFactor);
//             }
//         }
//         until (remainder == 1)
//         fixup { }

//         Message($"Found the period: {periodFactor}");
//         return periodFactor;
//     }


//     function Exercise5_FindFactor (
//         numberToFactor : Int,
//         guess : Int,
//         period : Int
//     ) : Int {
//         if (period % 2 == 1) {
//             // Odd number, we can't use it
//             return -1;
//         }

//         let factorTermBase = ExpModI(guess, period / 2, numberToFactor);
//         if (factorTermBase == 1 or factorTermBase == numberToFactor - 1) {
//             // The factors are just be the number itself and 1
//             return -2;
//         }

//         let b0 = GreatestCommonDivisorI(numberToFactor, factorTermBase + 1);
//         let b1 = GreatestCommonDivisorI(numberToFactor, factorTermBase - 1);

//         if 2 > b0 or b0 > numberToFactor {
//             fail "$Found factor {b0} of {numberToFactor} but it was invalid.";
//         }
//         if 2 > b1 or b1 > numberToFactor {
//             fail "$Found factor {b1} of {numberToFactor} but it was invalid.";
//         }
//         if b0 * b1 != numberToFactor {
//             fail $"Found factors {b0} and {b1} of {numberToFactor} but their product is {b0 * b1}";
//         }

//         Message($"Found factors {b0} and {b1} of {numberToFactor}");
//         return b0;
//     }
// }
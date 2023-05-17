// Intro to Quantum Software Development
// Lab 9: Shor's Factorization Algorithm
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// Due 4/12 at 6:00PM ET:
//  - Attempted exercises and evidence of unit tests run uploaded to GitHub.
//
// This assignment is extremely challenging. Full credit will be given for each
// exercise attempted. (It must be a serious attempt.) 10% extra credit will be
// given for each exercise implemented correctly.

namespace Lab9 {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;


    /// # Summary
    /// In this exercise, you must implement the quantum modular
    /// exponentiation function: |o> = a^|x> mod b.
    /// |x> and |o> are input and output registers respectively, and a and b
    /// are classical integers.
    ///
    /// # Input
    /// ## a
    /// The base power of the term being exponentiated.
    ///
    /// ## b
    /// The modulus for the function.
    ///
    /// ## input
    /// The register containing a superposition of all of the exponent values
    /// that the user wants to calculate; this superposition is arbitrary.
    ///
    /// ## output
    /// This register must contain the output |o> of the modular
    /// exponentiation function. It will start in the |0...0> state.
    operation Exercise1_ModExp (
        a : Int,
        b : Int,
        input : Qubit[],
        output : Qubit[]
    ) : Unit {
        // Note: For convenience, you can use the
        // Microsoft.Quantum.Math.ExpModI() function to calculate a modular
        // exponent classically. You can use the
        // Microsoft.Quantum.Arithmetic.MultiplyByModularInteger() function to
        // do an in-place quantum modular multiplication.

        // TODO
        X(output[Length(output) - 1]);              // output = |0...01>
        let outputAsLE = LittleEndian(output);

        let inputSize = Length(input);
        for i in 0..inputSize - 1 {
            let powerOfTwo = inputSize - 1 - i;     // n-i-1
            let powerOfGuess = 2 ^ powerOfTwo;      // 2^(n-i-1)

            let c = ExpModI(a, powerOfGuess, b);    // c = A^(2^(n-i-1)) mod B
            Controlled MultiplyByModularInteger(    // |O> = |O> * c mod B
                [input[i]],
                (c, b, outputAsLE)
            );
        }
    }


    /// # Summary
    /// In this exercise, you must implement the quantum subroutine of Shor's
    /// algorithm. You will be given a number to factor and some guess to a
    /// possible factor - both of which are integers.
    /// You must set up, execute, and measure the quantum circuit.
    /// You should return the fraction that was produced by measuring the
    /// result at the end of the subroutine, in the form of a tuple:
    /// the first value should be the number you measured, and the second
    /// value should be 2^n, where n is the number of qubits you use in your
    /// input register.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number that the user wants to factor. This will become the modulus
    /// for the modular arithmetic used in the subroutine.
    ///
    /// ## guess
    /// The number that's being guessed as a possible factor. This will become
    /// the base of exponentiation for the modular arithmetic used in the 
    /// subroutine.
    ///
    /// # Output
    /// A tuple representing the continued fraction approximation that the
    /// subroutine measured. The first value should be the numerator (the
    /// value that was measured from the qubits), and the second value should
    /// be the denominator (the total size of the input space, which is 2^n
    /// where n is the size of your input register).
    operation Exercise2_FindApproxPeriod (
        numberToFactor : Int,
        guess : Int
    ) : (Int, Int) {
        // Hint: you can use the Microsoft.Quantum.Arithmetic.MeasureInteger()
        // function to measure a whole set of qubits and transform them into
        // their integer representation.

        // NOTE: This is a *probablistic* test. There is a chance that the
        // unit test fails, even if you have the correct answer. If you think
        // you do, run the test again. Also, look at the output of the test to
        // see what values you came up with versus what the system expects.

        // TODO
        // Number of bits needed to represent NumberToFactor
        let outputSize = Ceiling(Lg(IntAsDouble(numberToFactor + 1)));

        use (input, output) = (Qubit[outputSize * 2], Qubit[outputSize]);
        ApplyToEach(H, input); // Input = |+...+>, so all possible states at once
        Exercise1_ModExp(guess, numberToFactor, input, output);
        Adjoint QFT(BigEndian(input)); // IQFT
        let result = MeasureInteger(BigEndianAsLittleEndian(BigEndian(input)));
        ResetAll(output);

        return (result, 2 ^ (outputSize * 2));
    }


    /// # Summary
    /// In this exercise, you will be given an arbitrary numerator and
    /// denominator for a fraction, along with some threshold value for the
    /// denominator.
    /// Your goal is to return the largest convergent of the continued
    /// fraction that matches the provided number, with the condition that the
    /// denominator of your convergent must be less than the threshold value.
    ///
    /// # Input
    /// ## numerator
    /// The numerator of the original fraction
    ///
    /// ## denominator
    /// The denominator of the original fraction
    ///
    /// ## denominatorThreshold
    /// A threshold value for the denominator. The continued fraction
    /// convergent that you find must be less than this value. If it's higher,
    /// you must return the previous convergent.
    ///
    /// # Output
    /// A tuple representing the convergent that you found. The first element
    /// should be the numerator, and the second should be the denominator.
    function Exercise3_FindPeriodCandidate (
        numerator : Int,
        denominator : Int,
        denominatorThreshold : Int
    ) : (Int, Int) {
        // TODO
mutable a_i = 0;            // Coefficient
        mutable P_i = numerator;    // Numerator
        mutable Q_i = denominator;  // Denominator
        mutable r_i = 0;            // Remainder

        mutable n_i = 0;            // Convergent numerator
        mutable n_i1 = 1;           // Convergent numerator from previous iteration
        mutable n_i2 = 0;           // Convergent numerator from 2 iterations previous

        mutable d_i = 0;            // Convergent denominator
        mutable d_i1 = 0;           // Convergent denominator from previous iteration
        mutable d_i2 = 1;           // Convergent denominator from 2 iterations previous

        while true {
            // Calculate current coefficient, remainder, and convergent
            set a_i = P_i / Q_i;
            set r_i = P_i % Q_i;
            set n_i = a_i * n_i1 + n_i2;
            set d_i = a_i * d_i1 + d_i2;

            // Return if d_i > threshold
            if d_i > denominatorThreshold {
                return (n_i1, d_i1);
            }

            // Return if r_i == 0
            if r_i == 0 {
                return (n_i, d_i);
            }

            set P_i = Q_i;
            set Q_i = r_i;
            set n_i2 = n_i1;
            set n_i1 = n_i;
            set d_i2 = d_i1;
            set d_i1 = d_i;
        }

        // This should never happen
        return (-1, -1);
    }


    /// # Summary
    /// In this exercise, you are given two integers - a number that you want
    /// to find the factors of, and an arbitrary guess as to one of the
    /// factors of the number. This guess was already checked to see if it was
    /// a factor of the number, so you know that it *isn't* a factor. It is
    /// guaranteed to be co-prime with numberToFactor.
    ///
    /// Your job is to find the period of the modular exponentation function
    /// using these two values as the arguments. That is, you must find the
    /// period of the equation y = guess^x mod numberToFactor.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number that the user wants to find the factors for
    ///
    /// ## guess
    /// Some co-prime integer that is smaller than numberToFactor
    ///
    /// # Output
    /// The period of y = guess^x mod numberToFactor.
    operation Exercise4_FindPeriod (numberToFactor : Int, guess : Int) : Int
    {
        // Note: you can't use while loops in operations in Q#.
        // You'll have to use a repeat loop if you want to run
        // something several times.

        // Hint: you can use the
        // Microsoft.Quantum.Math.GreatestCommonDivisorI()
        // function to calculate the GCD of two numbers.

mutable periodFactor = 1;
        mutable remainder = 0;
        Message($"Finding the period of {guess}^x mod {numberToFactor}...");

        repeat {
            let (specialState, numberOfStates) = Exercise2_FindApproxPeriod(numberToFactor, guess);
            Message($"Measured {specialState} / {numberOfStates}");

            if (specialState == 0) {
                Message("Measured 0 which won't help, have to try again.");
            } else {
                let (n, d) = Exercise3_FindPeriodCandidate(specialState, numberOfStates, numberToFactor);
                Message($"Found a period factor of {d}");

                set periodFactor = d * periodFactor / GreatestCommonDivisorI(d, periodFactor);
                Message($"Current largest factor: {periodFactor}");

                set remainder = ExpModI(guess, periodFactor, numberToFactor);
            }
        }
        until (remainder == 1)
        fixup { }

        Message($"Found the period: {periodFactor}");
        return periodFactor;
    }


    /// # Summary
    /// In this exercise, you are given a number to find the factors of,
    /// a guess of a factor (which is guaranteed to be co-prime), and the
    /// period of the modular exponentiation function that you found in
    /// Exercise 4.
    ///
    /// Your goal is to use the period to find a factor of the number if
    /// possible.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number to find a factor of
    ///
    /// ## guess
    /// A co-prime number that is *not* a factor
    ///
    /// ## period
    /// The period of the function y = guess^x mod numberToFactor.
    ///
    /// # Output
    /// - If you can find a factor, return that factor.
    /// - If the period is odd, return -1.
    /// - If the period doesn't work for factoring, return -2.
    function Exercise5_FindFactor (
        numberToFactor : Int,
        guess : Int,
        period : Int
    ) : Int {
        if (period % 2 == 1) {
            // Odd number, we can't use it
            return -1;
        }

        let factorTermBase = ExpModI(guess, period / 2, numberToFactor);
        if (factorTermBase == 1 or factorTermBase == numberToFactor - 1) {
            // The factors are just be the number itself and 1
            return -2;
        }

        let b0 = GreatestCommonDivisorI(numberToFactor, factorTermBase + 1);
        let b1 = GreatestCommonDivisorI(numberToFactor, factorTermBase - 1);

        if 2 > b0 or b0 > numberToFactor {
            fail "$Found factor {b0} of {numberToFactor} but it was invalid.";
        }
        if 2 > b1 or b1 > numberToFactor {
            fail "$Found factor {b1} of {numberToFactor} but it was invalid.";
        }
        if b0 * b1 != numberToFactor {
            fail $"Found factors {b0} and {b1} of {numberToFactor} but their product is {b0 * b1}";
        }

        Message($"Found factors {b0} and {b1} of {numberToFactor}");
        return b0;    }
}


   assign O = I ;

    `ifndef SYNTHESIS  
        `ifdef TIMED_SIM
            specify
            specparam T1 = 0.5;

                (I => O) = (T1);

            endspecify
        `endif // `ifdef TIMED_SIM  
    `endif //  `ifndef SYNTHESIS

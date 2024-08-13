
    assign O_P = I;
    assign O_N = ~I;
    
    `ifndef SYNTHESIS
        specify
            (I => O_P) = (0, 0);
            (I => O_N) = (0, 0);
        endspecify
    `endif //  `ifndef SYNTHESIS


    